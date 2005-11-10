From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 10 Nov 2005 23:54:37 +0000
Subject: RE: [Patch 1/1] 4-level page tables v4.
Message-Id: <200511102354.jAANsbg21726@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Thursday, November 10, 2005 8:19 AM
> --- linux-2.6.orig/arch/ia64/kernel/ivt.S	2005-11-10 06:49:03.399350630 -0600
> +++ linux-2.6/arch/ia64/kernel/ivt.S	2005-11-10 10:06:49.272116003 -0600
> @@ -114,7 +114,7 @@ ENTRY(vhpt_miss)
> @@ -192,14 +207,23 @@ ENTRY(vhpt_miss)
>  	 * between reading the pagetable and the "itc".  If so, flush the entry we
>  	 * inserted and retry.
>  	 */
> -	ld8 r25=[r21]				// read L3 PTE again
> -	ld8 r26=[r17]				// read L2 entry again
> +	ld8 r26=[r30]				// read L3 entry again
> +#ifdef CONFIG_PGTABLE_4
> +	ld8 r30=[r28]				// read L2 entry again
>  	;;
> -	cmp.ne p6,p7=r26,r20			// did L2 entry change
> +	cmp.ne p6,p7=r30,r29			// did L2 entry change
>  	mov r27=PAGE_SHIFT<<2
>  	;;
> +(p7)	cmp.ne.or.andcm p6,p7=r26,r20		// did L3 entry change
> +#else


You can shave off one cycle here by using parallel cmp.  Initialize
p6,p7 in the load bundle.  Something like:


+#ifdef CONFIG_PGTABLE_4
+	ld8 r30=[r28]				// read L2 entry again
+	cmp.ne p6,p7=r0,r0
 	;;
-	cmp.ne p6,p7=r26,r20			// did L2 entry change
+	cmp.ne.or.andcm p6,p7=r30,r29
+	cmp.ne.or.andcm p6,p7=r26,r20
 	mov r27=PAGE_SHIFT<<2
+#else

