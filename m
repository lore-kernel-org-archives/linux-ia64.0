From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 06 Sep 2013 19:00:30 +0000
Subject: [GIT PULL] ia64 fixes for 3.12
Message-Id: <522a264e1762d54a3@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit b36f4be3de1b123d8601de062e7dbfc904f305fb:

  Linux 3.11-rc6 (2013-08-18 14:36:53 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.12

for you to fetch changes up to 44fd81fe7eb8029a37ec83f15d4ef3585dd81bb6:

  [IA64] Use asm-generic/bitops/builtin-ffs.h (2013-08-26 14:22:58 -0700)

----------------------------------------------------------------
Couple of small cleanups for ia64

----------------------------------------------------------------
Akinobu Mita (1):
      [IA64] Use asm-generic/bitops/builtin-ffs.h

Joe Perches (1):
      [IA64] dmi.h: Make dmi_alloc use kzalloc

 arch/ia64/include/asm/bitops.h | 8 +-------
 arch/ia64/include/asm/dmi.h    | 2 +-
 2 files changed, 2 insertions(+), 8 deletions(-)
