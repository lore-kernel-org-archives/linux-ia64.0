From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2014 17:36:02 +0000
Subject: [GIT PULL] Miscellaneous ia64 specific cleanup for 3.17
Message-Id: <53dfc4825355de32e@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 64aa90f26c06e1cb2aacfb98a7d0eccfbd6c1a91:

  Linux 3.16-rc7 (2014-07-27 12:41:55 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.17

for you to fetch changes up to 6b15075c2c3662dbe1ac41404c6a2013b24efa1d:

  [IA64] sn: Do not needlessly convert between pointers and integers (2014-07-29 16:28:15 -0700)

----------------------------------------------------------------
Miscellaneous ia64 specific cleanup

----------------------------------------------------------------
Thierry Reding (2):
      [IA64] sn: Fix zeroing of PDAs
      [IA64] sn: Do not needlessly convert between pointers and integers

 arch/ia64/sn/kernel/bte.c   | 4 ++--
 arch/ia64/sn/kernel/setup.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)
