From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 20 Nov 2003 22:48:24 +0000
Subject: Re: long format VHPT
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050200040409040508040404"
Message-Id: <marc-linux-ia64-106936890413775@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106516182428089@msgid-missing>
In-Reply-To: <marc-linux-ia64-106516182428089@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050200040409040508040404
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Here's an incremental patch that adds Huge TLB support.

	-Arun

On 10/03/2003 05:05 PM, Arun Sharma wrote:
> Darren Williams wrote:
> 
>> Hi
>> This is an updated version of the long format VHPT patch
>> posted earlier.
>> Changes:
>> Added #ifdef to allow compile without long format
>> Updated compute_vhpt_size(void) to remove compiler warnings
> 
> 
> Actually, I moved compute_vhpt_size() to arch/ia64/mm/init.c, where I 
> think it belongs and added lvhpt_adjust to let the user override 
> whatever "intellligent" algorithm we come up with. This required adding 
> parse_early_cmdline().
> 
>     -Arun
> 
> 

--------------050200040409040508040404
Content-Type: text/plain;
 name="lvhpt-huge2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lvhpt-huge2.patch"

Index: linux-2.6-vhpt/include/asm-ia64/asmmacro.h
===================================================================
--- linux-2.6-vhpt/include/asm-ia64/asmmacro.h	(revision 36)
+++ linux-2.6-vhpt/include/asm-ia64/asmmacro.h	(working copy)
@@ -98,18 +98,38 @@
 /*
  * Find a page table entry with the long format VHPT walker
  */
+#define eva r22			/* effective va after accounting for hugepages */
 #define temp r24
 #define rgn r25
-#define mbz r26
+#define tir r26
+#define mbz r27
+
+#ifdef CONFIG_HUGETLB_PAGE
+#define HUGETLB_GET_ITIR(tir) mov tir=cr.itir
+#define HUGETLB_GET_EVA(tir, temp, va, eva)							\
+        extr.u temp=tir,2,6			/* extract the default page size bits */	\
+        ;;											\
+        cmp.eq p6,p7=HPAGE_SHIFT,temp		/* default page size is huge page size ? */	\
+        ;;											\
+(p6)    shr eva=va,HPAGE_SHIFT-PAGE_SHIFT;							\
+(p7)    mov eva=va										\
+	;;
+#else  /* !CONFIG_HUGETLB_PAGE */
+#define HUGETLB_GET_ITIR(tir)
+#define HUGETLB_GET_EVA(tir, temp, va, eva) mov eva=va;;
+#endif /* !CONFIG_HUGETLB_PAGE */
+
 /* va=r16 ppte=r19 fail=p6 ok=p7 */
 #define FIND_PTE(va, ppte, fail, ok)								\
+	HUGETLB_GET_ITIR(tir);									\
 	rsm psr.dt;				/* switch to using physical data addressing */	\
 	mov ppte=IA64_KR(PT_BASE);		/* get the page table base address */		\
 	shl mbz=va,3;				/* shift bit 60 into sign bit	*/		\
 	shr.u rgn=va,61;			/* get the region number into 'rgn' */		\
 	;;											\
+	HUGETLB_GET_EVA(tir, temp, va, eva)							\
 	cmp.eq p6,p7=5,rgn;			/* is faulting address in region 5? */		\
-	shr.u temp=va,PGDIR_SHIFT;		/* get bits 33-63 of faulting address */	\
+	shr.u temp=eva,PGDIR_SHIFT;		/* get bits 33-63 of faulting address */	\
 	;;											\
 (p7)	dep ppte=rgn,ppte,(PAGE_SHIFT-3),3;	/* put region number bits in place */		\
 	srlz.d;											\
@@ -122,7 +142,7 @@
 (p6)	dep ppte=temp,ppte,3,(PAGE_SHIFT-3);	/* ppte=PTA + IFA(33,42)*8 */			\
 (p7)	dep ppte=temp,ppte,3,(PAGE_SHIFT-6);	/* ppte=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8) */ \
 	cmp.eq ok,fail=0,mbz;			/* unused address bits all zeroes? */		\
-	shr.u temp=va,PMD_SHIFT;			/* shift L2 index into position	*/		\
+	shr.u temp=eva,PMD_SHIFT;			/* shift L2 index into position	*/		\
 	;;											\
 	ld8 ppte=[ppte];			/* fetch the L1 entry (may be 0)*/		\
 	;;											\
@@ -130,7 +150,7 @@
 	dep ppte=temp,ppte,3,(PAGE_SHIFT-3);	/* compute address of L2 page table entry*/	\
 	;;											\
 (ok)	ld8 ppte=[ppte];			/* fetch the L2 entry (may be 0)*/		\
-	shr.u temp=va,PAGE_SHIFT;		/* shift L3 index into position*/		\
+	shr.u temp=eva,PAGE_SHIFT;		/* shift L3 index into position*/		\
 	;;											\
 (ok)	cmp.eq.or.andcm fail,ok=ppte,r0;		/* was L2 entry NULL?*/				\
 	dep ppte=temp,ppte,3,(PAGE_SHIFT-3);	/* compute address of L3 page table entry*/

--------------050200040409040508040404--

