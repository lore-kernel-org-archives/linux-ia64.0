From: Erich Focht <focht@ess.nec.de>
Date: Wed, 17 Apr 2002 00:33:57 +0000
Subject: [Linux-ia64] O(1) scheduler for 2.4.18 IA64
Message-Id: <marc-linux-ia64-105590701905466@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

A patch for Ingo's scheduler (including the migration_threads) for 2.4.18
kernels and IA64 can be found at:
http://home.arcor.de/efocht/sched/MQO1_ia64a-kdb-k3z-all-2.4.18.patch.bz2

To get a running IA64 kernel one should apply it over:
  1: linux-2.4.18
  2: kdb-v2.1-2.4.18-common-2.bz2
  3: linux-2.4.18-ia64-020410.diff.bz2
  4: kdb-v2.1-2.4.18-ia64-020226-1.bz2

Leaving out kdb leads to a running kernel, too, just ignore the failed
hunks.

The patch is primarilly made for IA64 but one can get running i386
kernels, too. Applied over the vanilla linux-2.4.18 should lead to a
working i386 kernel if you apply the failed hunk for kernel/timer.c
manually. Just ignore the failed ia64 hunks.

Regards,
Erich



