From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 17 Apr 2003 22:50:02 +0000
Subject: [Linux-ia64] [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705548@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, is something like this ok with you?  On our systems, elilo
won't load the kernel where head.S expects it, so we look at the ip to
figure it out.

Thanks,
Jesse

--- linux-2.5.67-ia64/arch/ia64/kernel/head.S	Wed Apr 16 13:54:24 2003
+++ linux-2.5.67-ia64-sn/arch/ia64/kernel/head.S	Thu Apr 17 15:48:15 2003
@@ -66,16 +66,20 @@
 	 */
 	rsm psr.i | psr.ic
 	mov r16=((ia64_rid(IA64_REGION_ID_KERNEL, PAGE_OFFSET) << 8) | (IA64_GRANULE_SHIFT << 2))
+	mov r3=ip		// used to figure out which physical addr we loaded at
 	;;
 	srlz.i
 	mov r18=KERNEL_TR_PAGE_SHIFT<<2
 	movl r17=KERNEL_START
+	dep r2=0,r3,0,12	// drop the low 12 bits, they're used later for pte info
 	;;
 	mov rr[r17]=r16
 	mov cr.itir=r18
 	mov cr.ifa=r17
 	mov r16=IA64_TR_KERNEL
-	movl r18=((1 << KERNEL_TR_PAGE_SHIFT) | PAGE_KERNEL)
+	movl r18=PAGE_KERNEL	// rwx kernel text & data
+	;;
+	or r18=r2,r18		// put the pte bits in with the physical page number from r2
 	;;
 	srlz.i
 	;;

