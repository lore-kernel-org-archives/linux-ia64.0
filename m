From: Erich Focht <focht@ess.nec.de>
Date: Wed, 16 May 2001 16:55:20 +0000
Subject: [Linux-ia64] hanging process cannot be killed
Message-Id: <marc-linux-ia64-105590693005594@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

how can it happen that a process isn't killable with kill -9 any more? I
have encountered this a few times and from within kdb two processes seem
to be in "run" state on the same CPU! The one marked as "current" shows
the following traceback:
   __ia64_save_fpu+0x20
   schedule+0xa40
   invoke_schedule+0x20
   ia64_leave_kernel+0x30

This process sits on the CPU, eats up cycles and the scheduler doesn't
seem to touch it any more. I only can get rid of it by rebooting.

Another traceback of a similar situation (with the same executable) was:
   __ia64_save_fpu+0x280
   schedule+0xa40
   ia64_do_signal+0x670
   handle_signal_delivery+0x30
   ia64_leave_kernel+0x30

I've seen this with 2.4.0 and 2.4.4 kernels, with B1 stepping CPUs. With
2.4.4 in single dispersal mode the problem doesn't seem to occur...

Thanks in advance for any help, ideas, comments...

Best regards,
Erich

---
Erich Focht                                    <efocht@ess.nec.de>
NEC European Supercomputer Systems, European HPC Technology Center
Hessbruehlstr. 21B, 70565 Stuttgart, Germany
phone: +49-711-78055-15                    fax  : +49-711-78055-25



