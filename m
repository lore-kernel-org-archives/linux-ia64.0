From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Aug 2016 21:52:18 +0000
Subject: [GIT PULL] ia64 changes for 4.8
Message-Id: <579fc49224172d1de6@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 5edb56491d4812c42175980759da53388e5d86f5:

  Linux 4.7-rc3 (2016-06-12 07:20:35 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-4.8

for you to fetch changes up to fbb0e4da96f4503e65bc4fb627cf4e1d7c8c64e6:

  ia64: salinfo: use a waitqueue instead a sema down/up combo (2016-07-25 09:55:32 -0700)

----------------------------------------------------------------
Miscellaneous ia64 cleanups

----------------------------------------------------------------
Arnd Bergmann (1):
      ia64: efi: use timespec64 for persistent clock

Sebastian Andrzej Siewior (1):
      ia64: salinfo: use a waitqueue instead a sema down/up combo

 arch/ia64/kernel/efi.c     |  4 ++--
 arch/ia64/kernel/salinfo.c | 38 ++++++++++----------------------------
 arch/ia64/kernel/time.c    |  2 +-
 include/linux/efi.h        |  2 +-
 4 files changed, 14 insertions(+), 32 deletions(-)
