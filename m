From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 20 Aug 2012 20:43:25 +0000
Subject: [GIT PULL] config cleanup for ia64
Message-Id: <5032a16d2274d91bf@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit d9875690d9b89a866022ff49e3fcea892345ad92:

  Linux 3.6-rc2 (2012-08-16 14:51:24 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-ia64-fixes

for you to fetch changes up to 7c3ea4859ae132d61594320e148b0348f03c0edc:

  [IA64] defconfig: Remove CONFIG_MISC_DEVICES (2012-08-20 13:04:29 -0700)

----------------------------------------------------------------
Clean out references to dead CONFIG_MISC_DEVICES option

----------------------------------------------------------------
Fabio Estevam (1):
      [IA64] defconfig: Remove CONFIG_MISC_DEVICES

 arch/ia64/configs/generic_defconfig   | 1 -
 arch/ia64/configs/gensparse_defconfig | 1 -
 2 files changed, 2 deletions(-)
