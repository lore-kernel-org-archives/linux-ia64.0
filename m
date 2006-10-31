From: Keith Owens <kaos@sgi.com>
Date: Tue, 31 Oct 2006 06:18:25 +0000
Subject: Re: [PATCH] IA64 trap code 16 bytes atomic copy on montecito
Message-Id: <21344.1162275505@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546E55E.3050207@intel.com>
In-Reply-To: <4546E55E.3050207@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"bibo,mao" (on Tue, 31 Oct 2006 13:55:42 +0800) wrote:
>hi,
>  On IA64 kprobe can not insert trap code on slot 1 because
>opcode of slot 1 crosses over two consecutive 8-bytes. On
>montecito machine 16 bytes atomic operation is avaiable,
>This patch implements 16 bytes atomic copy on montecito
>machine, so that kprobe can probe any slot on montecito
>machine.
>  Any comments is welcome.
>
>Signed-off-by: bibo, mao <bibo.mao@intel.com>
>  
>thanks
>bibo,mao 
>
> arch/ia64/kernel/jprobes.S |   38 +++++++++++++++++++++++++++
> arch/ia64/kernel/kprobes.c |   16 ++++++++++++----
> include/asm-ia64/kprobes.h |    1 +
> 3 files changed, 51 insertions(+), 4 deletions(-)
>-------------------------------------------------------------
>
>diff -Nruap -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/arch/ia64/kernel/jprobes.S 2.6.19-rc2/arch/ia64/kernel/jprobes.S
>--- 2.6.19-rc2.org/arch/ia64/kernel/jprobes.S	2006-03-27 14:41:20.000000000 +0800
>+++ 2.6.19-rc2/arch/ia64/kernel/jprobes.S	2006-10-31 12:29:14.000000000 +0800
>@@ -87,3 +87,41 @@ GLOBAL_ENTRY(flush_register_stack)
> 	br.ret.sptk.many rp
> END(flush_register_stack)
> 
>+/* this function uses st16/ld16 to atomically copy one bundle
>+ * to code area, it requires src address and dest address is
>+ * not in UC/UCE/WC area. Currently kernel physical memory
>+ * identified map is cachable and WB, so there is no such check.
>+ *  input0: represents whether this cpu supports atomic
>+ *	    st16/ld16 instruction
>+ *  input1: destionation address of bundle copy
>+ *  input2: source address of bundle copy
>+ *  return: -1 failed, 0 succeed  

Trailing whitspace in patch, on the end of the 'return:' comment..

>+ */
>+GLOBAL_ENTRY(kprobe_update_inst_bundle)
>+	alloc loc0=ar.pfs,3,1,0,0
>+
>+	and r15,r34
>+	and r14,r33

Use in0, in1, in2, not r32-34.

>+	mov r8=-1
>+	;;
>+	cmp.eq p9,p8=0,r15
>+	cmp.eq p7,p6=0,r14

"cmp.ne p8,p0=0,r15" is more readable.  You are testing for a non-zero
value, but using cmp.eq then testing the second predicate is harder to
read.

I have never understood why people code two predicates on cmp when they
only ever use one of them, it makes other coders stop and check "where
is the other predicate used?".  p0 makes it explicit that the second
predicate is not used.

>+(p6) 	br.ret.dptk.many b0
>+	;;
>+	cmp4.eq p7,p6=0,r32
>+(p8)	br.ret.dpnt.many b0
>+	;;
>+(p7)	ld8  r14=[r34],8
>+	mov  r8=r0
>+(p6)	ld16 r14=[r34]
>+	;;
>+(p7)	st8  [r33]=r14,8

That st8 is not an atomic operation on an instruction slot, which
conflicts with the function's specification.  It is probably cleaner to
do any non-atomic updates in C, so this routine only does ld16/st16.
That also removes the atomic input and conditional code from the
assembler function.  The less that is coded in assembler, the better.

>+(p6)	st16 [r33]=r14
>+	;;
>+(p7)	ld8  r14=[r34]
>+	;;
>+(p7)	st8 [r33]=r14
>+	nop.i 0x0

Why insert an explicit nop?  The assembler does that for you.

>+	br.ret.sptk.many b0
>+	;;	

Trailing whitespace again.

>+END(kprobe_update_inst_bundle)

