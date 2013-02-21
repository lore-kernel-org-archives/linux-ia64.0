From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 21 Feb 2013 22:11:43 +0000
Subject: [GIT PULL] ia64 miscellany
Message-Id: <51269b9f22645bb744@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit d1c3ed669a2d452cacfb48c2d171a1f364dae2ed:

  Linux 3.8-rc2 (2013-01-02 18:13:21 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.9

for you to fetch changes up to cc883afcc02e1c9c8ab64d20f0288355b857f966:

  MAINTAINERS: update SGI & ia64 Altix stuff (2013-02-06 15:04:05 -0800)

----------------------------------------------------------------
Misc ia64 bits for 3.9

----------------------------------------------------------------
Bjorn Helgaas (1):
      MAINTAINERS: update SGI & ia64 Altix stuff

Vineet Gupta (1):
      sysctl: Enable IA64 "ignore-unaligned-usertrap" to be used cross-arch

 MAINTAINERS       | 11 ++---------
 arch/ia64/Kconfig |  1 +
 init/Kconfig      |  7 +++++++
 kernel/sysctl.c   |  9 +++++++--
 4 files changed, 17 insertions(+), 11 deletions(-)
