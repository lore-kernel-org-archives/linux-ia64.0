From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 29 Jun 2015 15:08:16 +0000
Subject: [GIT PULL] misc ia64 changes for 4.2
Message-Id: <55915f602226465110@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 0f57d86787d8b1076ea8f9cbdddda2a46d534a27:

  Linux 4.1-rc8 (2015-06-14 15:51:10 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-4.2

for you to fetch changes up to 2587dc65e1b70617a1a369b26eb824ab1af1b9df:

  ia64: Use setup_timer (2015-06-15 15:45:18 -0700)

----------------------------------------------------------------
Pair of ia64 cleanups

----------------------------------------------------------------
Luis R. Rodriguez (1):
      ia64: export flush_icache_range for module use

Vaishali Thakkar (1):
      ia64: Use setup_timer

 arch/ia64/kernel/ia64_ksyms.c | 3 +++
 arch/ia64/kernel/mca.c        | 6 ++----
 2 files changed, 5 insertions(+), 4 deletions(-)
