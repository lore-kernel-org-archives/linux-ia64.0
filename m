From: Russ Anderson <rja@sgi.com>
Date: Wed, 26 Jan 2005 21:40:47 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200501262140.j0QLelDm12268221@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger-Tang wrote:
>
> The patch has been compile- and boot-tested for zx1 UP and SMP.  I
> think it should be OK for discontig configs, too, but I haven't tested
> that (and if anybody wanted to build discontig for UP, then
> discontig.c:per_cpu_init() would have to be updated like the contig.c
> version.
>
> Also, I verified that the kernel can still do an INIT dump.  Other
> than that, I can't really test the MCA-path.

There is one small problem.  In mca_asm.S, r23 was used without being set 
and the hardcoded value 40 is no longer valid (patch below).

With linux-ia64-test-2.6.11 plus David's patch plus the patch
below, 1024 memory uncorectable errors were injected and sucessfully
recovered on an SGI Altix test machine.  1024 is the number of entries 
in the page_isolate[] array in arch/ia64/kernel/mca_drv.c.  When the 
array is full, the recovery code says the error is not recoverable 
and the system reboots.

Test output:
------------------------------------
./test.script: line 10: 17343 Killed                  ./errit -d 3
ERR_INJ: type = 2, addr = 6000000000002480, bits = 3, paddr = 0x00000b300abda480
OS_MCA: process [pid: 17343](errit) encounters MCA.
Page isolation: ( b300abda480 ) success.
pass 1024
------------------------------------


Signed-off-by: Russ Anderson <rja@sgi.com>

----------------------------------------------------------------
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-01-26 10:20:55.140112553 -0600
+++ linux/arch/ia64/kernel/mca_asm.S	2005-01-26 14:47:19.878566832 -0600
@@ -203,9 +203,9 @@
 	srlz.d
 	;;
 	// 3. Purge ITR for PAL code.
-	adds r17@,r23
+	GET_THIS_PADDR(r2, ia64_mca_pal_base)
 	;;
-	ld8 r16=[r17]
+	ld8 r16=[r2]
 	mov r18=IA64_GRANULE_SHIFT<<2
 	;;
 	ptr.i r16,r18
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
