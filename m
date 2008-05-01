From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 01 May 2008 22:57:11 +0000
Subject: [git pull] ia64 changes
Message-Id: <1FE6DD409037234FAB833C420AA843EC013F7630@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/ia32/ia32_signal.c   |    2 +-
 arch/ia64/kernel/acpi.c        |    2 +-
 arch/ia64/kernel/irq.c         |    4 +-
 arch/ia64/kernel/palinfo.c     |    2 +-
 arch/ia64/kernel/perfmon.c     |  199 +++++++++++++++++----------------------
 arch/ia64/kernel/signal.c      |   15 ++--
 arch/ia64/kernel/smp.c         |   68 +++++++-------
 arch/ia64/kernel/time.c        |    5 -
 arch/ia64/kernel/topology.c    |   16 ++-
 include/asm-ia64/cpu.h         |    2 +-
 include/asm-ia64/thread_info.h |   13 ++-
 11 files changed, 157 insertions(+), 171 deletions(-)

Al Viro (1):
      [IA64] fix file and descriptor handling in perfmon

Hidetoshi Seto (5):
      [IA64] fix section mismatch in arch/ia64/kernel/acpi.c
      [IA64] fix section mismatch in arch/ia64/kernel/irq.c
      [IA64] fix section mismatch in arch/ia64/kernel/palinfo.c
      [IA64] fix section mismatch in arch/ia64/kernel/topology.c
      [IA64] smp.c coding style fix

Roland McGrath (1):
      [IA64] TS_RESTORE_SIGMASK



