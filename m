From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 18 Mar 2005 06:38:10 +0000
Subject: [patch] fix syscall-optimization goof
Message-Id: <200503180638.j2I6cAhP000415@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Resend with list-addres corrected...]

Sadly, I goofed in this syscall-tuning patch:

ChangeSet 1.1966.1.40 2005/01/22 13:31:05 davidm@hpl.hp.com
  [IA64] Improve ia64_leave_syscall() for McKinley-type cores.

  Optimize ia64_leave_syscall() a bit better for McKinley-type cores.
  The patch looks big, but that's mostly due to renaming r16/r17 to r2/r3.
  Good for a 13 cycle improvement.

The problem is that the size of the physical stacked registers was
loaded into the wrong register (r3 instead of r17).  Since r17 by
coincidence always had the value 1, this had the effect of turning
rse_clear_invalid into a no-op.  That poses the risk of leaking kernel
state back to user-land and is hence not acceptable.

The fix below is simple, but unfortunately it costs us about 28 cycles
in syscall overhead. ;-(

Unfortunately, there isn't much we can do about that since those
registers have to be cleared one way or another.

	--david

=== arch/ia64/kernel/entry.S 1.80 vs edited ==--- 1.80/arch/ia64/kernel/entry.S	2005-01-28 16:37:04 -08:00
+++ edited/arch/ia64/kernel/entry.S	2005-03-17 22:30:15 -08:00
@@ -759,8 +759,8 @@
 	ld8.fill r15=[r3]	// restore r15
 	addl r3=THIS_CPU(ia64_phys_stacked_size_p8),r0
 	;;
-(pUStk)	ld4 r3=[r3]		// r3 = cpu_data->phys_stacked_size_p8
 (pUStk) st1 [r14]=r17
+(pUStk)	ld4 r17=[r3]		// r17 = cpu_data->phys_stacked_size_p8
 	mov b6=r18		// I0  restore b6
 	;;
 	mov r14=r0		// clear r14
