From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Mon, 25 Feb 2008 18:32:11 +0000
Subject: RE: [kvm-ia64-devel] [PATCH 0/4] ia64/xen: paravirtualization ofhand written assembly code
Message-Id: <10EA09EFD8728347A513008B6B0DA77A02CFD32D@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12039094061834-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12039094061834-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> Isaku Yamahata (on Mon, 25 Feb 2008 12:16:42 +0900) wrote:
>> Hi. The patch I send before was too large so that it was dropped from
>> the maling list. I'm sending again with smaller size.
>> This patch set is the xen paravirtualization of hand written assenbly
>> code. And I expect that much clean up is necessary before merge.
>> We really need the feed back before starting actual clean up as
>> Eddie already said before. 
>> 
>> Eddie discussed how to clean up and suggested several ways.
>>  1: Dual IVT source code, dual IVT table. (The way this patch set
>>  adopted) 2: Same IVT source code, but dual/mulitple compile to
>>     generate dual/multiple IVT table using assembler macro.
>>  3: Single IVT table, using indirect function call for pv_ops using 
>> branch/binary patching. 
>> 
>> At this moment my preference is the option 2. Please comment.
> 
> A combination of options (2) and (3) would work.  Have a single source
> file for the IVT, using conditional macros.  Use that source file to
> build (at least) two copies of the IVT, for native and any virtualized

Thanks, we are getting more comments now:)
I would like to take this chance to go into a little bit more details
now for sub-alternatives. 

For all of above, we need replace IVT source code like following
example:
@@ -102,7 +116,7 @@ 	 *	- the faulting virtual address uses
unimplemented address bits 	 *	- the faulting virtual address
has no valid page table mapping 	 */
-	mov r16=cr.ifa		// get address that caused the TLB miss
+	_READ_IFA(r16, r24, r25)
 #ifdef CONFIG_HUGETLB_PAGE
 	movl r18=PAGE_SHIFT 	mov r25=cr.itir

For #2 (Dual compile, Dual IVT instance),  now we have following 
sub-alternatives:

A) Generate code in place like following:
+#ifdef CONFIG_XEN
+#define _READ_IFA(regr, clob1, clob2)	\
+	movl clob1=XSI_IFA;;		\
+	ld8 regr=[clob1];;
+#endif

+#ifdef CONFIG_NATIVE
+#define _READ_IFA(regr, clob1, clob2)	\
+	mov regr=cr.ifa;
+#endif

In this approach, we don't do function call/jump, all the codes
for different hypervisor are generated in place. To be more
important, it doesn't require any fixed clobber registers, i.e.
any registers found spare can be used as clob registers.

If we go with this apporach, the coding effort is minized and
current Xen code can be simply merged into this model.

Cons:  No explicit pv_asm_ops function table, diversity to X86's
is bigger.

B) Directly jump
This model use function call (actually jump) in those primitive
pv MACROs.


+GLOBAL_ENTRY(xen_read_ifa)
+	mov b0=r24;
+	movl r25=XSI_IFA;;
+	ld8 r24=[r25];;
+	br.cond.sptk b0
+END(xen_read_ifa)

+#ifdef CONFIG_XEN
+#define _READ_IFA(regr, clob1, clob2)	\
+	movl r24;			\
+	br.sptk.many xen_read_ifa;;	\
+1:					\
+	mov regr=r24;;
+#endif

Pros: less code size generated in place, 
Cons: need clob registers and probably fixed
clob registers.

C) Indirect function call
This model is mostly close to what pv_ops mean. Previous 
solution actually doesn't refer to the function table.

possible for C & ASM to share same pv_ops code with wrapper
in C side, and could support single IVT table solution.

Cons: Need more clobber registers and change IVT source code.

+#define _READ_IFA(regr, clob1, clob2)	\
+	mov r24=_READ_IFA_OPS_INDEX;	\
+	movl r25=pv_cpu_asm_ops;;	\
+	add r25=r24,r25;;		\
+	ld8 r25=[r25];			\
+	movl r24;;			\
+	mov b0=r25;;			\
+	br.sptk.many b0;;		\
+1:					\
+	mov regr=r24;;
+


Binary patching at boot ime can convert C to B or A, or convert B to A
if certain condition is met such as clob registers & code size. So run
time
performance degradation to native is minimized. The only difference is
we
get more "nop" ops in native IVT table (patching will convert those
non-used
 code space to nop instructions, or maybe use a relative jump to skip
those
 spare code).

#A is easiest from effort point of view (no need to re-org mass IVT
code), and
#A doesn;t need binary patching. 
but the code quality may be not that good in current Xen such as:

@@ -192,7 +235,17 @@
 	 */
 	adds r24=__DIRTY_BITS_NO_ED|_PAGE_PL_0|_PAGE_AR_RW,r23
 	;;
+#ifdef CONFIG_XEN
+(p7)	mov r25=r8
+(p7)	mov r8=r24
+	;;
+(p7)	XEN_HYPER_ITC_D
+	;;
+(p7)	mov r8=r25
+	;;
+#else
 (p7)	itc.d r24
+#endif
 	;;
 #ifdef CONFIG_SMP




#C(also #B) need massive IVT source code change to find clob registers.


> modes.  The native copy of the IVT starts at label ia64_ivt in section
> .text.ivt, as it does now.  Any IVT versions for virtualized mode are
> defined as __cpuinitdata, so they are discarded after boot, unless

Looks like you prefer #A of above dual compiler option, right?
If most people agree with this, we can go quickly :)

> CONFIG_HOTPLUG_CPU=y.  arch/ia64/kernel/head.S copies the relevant
> virtualized version over ia64_ivt when necessary, before initializing
> cr.iva.
> 
> Single source for maintenance.  No indirect function overhead at run
> time.  Binary patching at boot time for the right mode.  No wasted
> space in the kernel.

Yes, each apporach can do this.

Thanks, eddie

