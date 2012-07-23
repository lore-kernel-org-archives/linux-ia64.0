From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Jul 2012 22:20:40 +0000
Subject: [GIT PULL] ia64 3.6 merge window patches
Message-Id: <500dce382997371339@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit cfaf025112d3856637ff34a767ef785ef5cf2ca9:

  Linux 3.5-rc2 (2012-06-08 18:40:09 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.6

for you to fetch changes up to e9c31b32f1cc6d3aa190119103622fb8e4c257b1:

  debug: Do not permit CONFIG_DEBUG_STACK_USAGE=y on IA64 or PARISC (2012-07-19 10:36:45 -0700)

----------------------------------------------------------------
Misc Itanium fixes for 3.6 merge window

----------------------------------------------------------------
Kautuk Consul (1):
      [IA64] Port OOM changes to ia64_do_page_fault

Tony Luck (1):
      debug: Do not permit CONFIG_DEBUG_STACK_USAGE=y on IA64 or PARISC

 arch/ia64/mm/fault.c | 46 ++++++++++++++++++++++++++++++++++------------
 lib/Kconfig.debug    |  2 +-
 2 files changed, 35 insertions(+), 13 deletions(-)
