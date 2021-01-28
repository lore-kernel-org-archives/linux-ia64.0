From: Arnd Bergmann <arnd@kernel.org>
Date: Thu, 28 Jan 2021 15:35:55 +0000
Subject: [GIT PULL] asm-generic/ia64 fixes, mark as orphaned
Message-Id: <CAK8P3a2+tvr6O7LxF8M6sJ-e-NmbijAmXt13FPEvOXtY_PSgPQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, linux-arch <linux-arch@vger.kernel.org>

The following changes since commit 5c8fe583cce542aa0b84adc939ce85293de36e5e:

  Linux 5.11-rc1 (2020-12-27 15:30:22 -0800)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/arnd/asm-generic.git
tags/asm-generic-fixes-v5.11

for you to fetch changes up to 96ec72a3425d1515b69b7f9dc34a4a6ce5862a37:

  ia64: Mark architecture as orphaned (2021-01-12 17:03:04 +0100)

----------------------------------------------------------------
asm-generic/ia64 fixes, mark as orphaned

Commit 2b49ddcef297 ("ia64: convert to legacy_timer_tick") from my timer
series I merged through the asm-generic tree caused a regression on all
ia64 machines, as bisected by Adrian Glaubitz.

Tony Luck is no longer really working on ia64, so instead of merging the
fix through his tree, we ended up deciding that I'd merge the fix myself
along a patch to mark the architecture as Orphaned and a compile time
warning fix I made while working on the regression.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

----------------------------------------------------------------
Arnd Bergmann (3):
      ia64: fix timer cleanup regression
      ia64: fix xchg() warning
      ia64: Mark architecture as orphaned

 MAINTAINERS                          |  5 +----
 arch/ia64/include/uapi/asm/cmpxchg.h |  2 +-
 arch/ia64/kernel/time.c              | 31 ++++++++++++++++++-------------
 3 files changed, 20 insertions(+), 18 deletions(-)
