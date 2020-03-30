From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 30 Mar 2020 18:39:12 +0000
Subject: [GIT PULL] ia64 for v5.7
Message-Id: <20200330183912.GA27085@agluck-desk2.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The following changes since commit 98d54f81e36ba3bf92172791eba5ca5bd813989b:

  Linux 5.6-rc4 (2020-03-01 16:38:46 -0600)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git please-pull-ia64_for_5.7

for you to fetch changes up to 172e7890406d6183b9b39271ffb434ff0a97ce72:

  tty/serial: cleanup after ioc*_serial driver removal (2020-03-13 16:12:17 -0700)

----------------------------------------------------------------
Couple of cleanup patches

----------------------------------------------------------------
Lukas Bulwahn (1):
      tty/serial: cleanup after ioc*_serial driver removal

afzal mohammed (1):
      ia64: replace setup_irq() by request_irq()

 MAINTAINERS                    |  9 +---
 arch/ia64/include/asm/hw_irq.h |  2 -
 arch/ia64/kernel/irq.h         |  3 ++
 arch/ia64/kernel/irq_ia64.c    | 43 +++++++------------
 arch/ia64/kernel/mca.c         | 50 +++++++----------------
 arch/ia64/kernel/perfmon.c     | 10 ++---
 arch/ia64/kernel/time.c        | 11 ++---
 include/linux/ioc3.h           | 93 ------------------------------------------
 8 files changed, 40 insertions(+), 181 deletions(-)
 create mode 100644 arch/ia64/kernel/irq.h
 delete mode 100644 include/linux/ioc3.h
