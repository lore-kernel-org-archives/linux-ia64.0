From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 23 Sep 2014 18:47:37 +0000
Subject: [GIT PULL] Fix ia64 defconfig files to fix boot problems
Message-Id: <5421c049393013903@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit f3670394c29ff3730638762c1760fd2f624e6d7b:

  Revert "x86/efi: Fixup GOT in all boot code paths" (2014-09-22 23:05:49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-defconfig

for you to fetch changes up to e8ee39e227d72823461907156f0046269d72ff15:

  [IA64] refresh arch/ia64/configs/* using "make savedefconfig" (2014-09-23 11:09:29 -0700)

----------------------------------------------------------------
Need to rebuild defconfig files to cope with removal of
"select NET" in drivers/scsi/Kconfig

----------------------------------------------------------------
Tony Luck (1):
      [IA64] refresh arch/ia64/configs/* using "make savedefconfig"

 arch/ia64/configs/bigsur_defconfig    | 13 +++----------
 arch/ia64/configs/generic_defconfig   | 29 +++++++----------------------
 arch/ia64/configs/gensparse_defconfig | 23 ++++++-----------------
 arch/ia64/configs/sim_defconfig       |  8 ++------
 arch/ia64/configs/tiger_defconfig     | 25 +++++++------------------
 arch/ia64/configs/zx1_defconfig       | 14 ++++----------
 6 files changed, 29 insertions(+), 83 deletions(-)
