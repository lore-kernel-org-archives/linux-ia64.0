From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 May 2007 20:28:11 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A0171A272@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

[Possible duplicate ... but this is the second "please pull" that I've
sent
 that hasn't shown up on the linux-ia64 mailing list, so I assume that
the
 copy to Linus got lost too ... I need to re-look at my outgoing e-mail
 configuration to see what I broke]

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/ia32/ia32_entry.S        |   39 --------------------
 arch/ia64/ia32/ia32_signal.c       |   65
+++++++--------------------------
 arch/ia64/kernel/entry.S           |   30 +--------------
 arch/ia64/kernel/iosapic.c         |    2 -
 arch/ia64/kernel/irq_ia64.c        |   27 +++++++++++---
 arch/ia64/kernel/process.c         |    8 ++--
 arch/ia64/kernel/relocate_kernel.S |   11 -----
 arch/ia64/kernel/setup.c           |    2 -
 arch/ia64/kernel/sigframe.h        |    2 -
 arch/ia64/kernel/signal.c          |   71
+++++++++++--------------------------
 arch/ia64/kernel/smp.c             |   68
+++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/traps.c           |    6 +--
 arch/ia64/kernel/unwind.c          |    9 ++--
 arch/ia64/mm/tlb.c                 |    6 +--
 arch/ia64/sn/kernel/irq.c          |   58
++++++++++++++++++++++--------
 arch/ia64/sn/kernel/sn2/sn2_smp.c  |   65
+++++++++++++++++++++++++++++++--
 drivers/char/mmtimer.c             |    4 --
 include/asm-ia64/hw_irq.h          |    1 
 include/asm-ia64/iosapic.h         |    2 -
 include/asm-ia64/sn/sn_sal.h       |    1 
 include/asm-ia64/thread_info.h     |    4 +-
 include/asm-ia64/tlbflush.h        |   11 +++++
 include/asm-ia64/unistd.h          |    5 ++
 23 files changed, 276 insertions(+), 221 deletions(-)

Alexey Dobriyan (1):
      [IA64] Add TIF_RESTORE_SIGMASK

Alexey Kuznetsov (1):
      [IA64] wire up pselect, ppoll

Jack Steiner (1):
      [IA64] Optional method to purge the TLB on SN systems

John Keller (1):
      [IA64] - Altix: hotplug after intr redirect can crash system

Kirill Korotaev (1):
      [IA64] unwind did not work for processes born with CLONE_STOPPED

Markus F.X.J. Oberhumer (1):
      [IA64] fix stack alignment for ia32 signal handlers

Milind Arun Choudhary (1):
      [IA64] SPIN_LOCK_UNLOCKED macro cleanup in arch/ia64

Siddha, Suresh B (1):
      [IA64] save and restore cpus_allowed in cpu_idle_wait

Tony Luck (2):
      [IA64] Fix some section mismatch errors
      [IA64] Removal of percpu TR cleanup in kexec code

vignesh babu (1):
      [IA64-SN2][KJ] mmtimer.c-kzalloc
