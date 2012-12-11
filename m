From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Dec 2012 17:04:26 +0000
Subject: [GIT PULL] ia64 fix for 3.8 merge window
Message-Id: <50c7679a43784f87@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 3d70f8c617a436c7146ecb81df2265b4626dfe89:

  Linux 3.7-rc4 (2012-11-04 11:07:39 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.8

for you to fetch changes up to 4fafc8c21487f6b5259d462e9bee98661a02390d:

  [IA64] Resolve name space collision for cache_show() (2012-11-07 15:51:04 -0800)

----------------------------------------------------------------
Miscellaneous ia64 fix for 3.8. Just need to avoid a pending
namespace collision from other work being merged.

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Resolve name space collision for cache_show()

 arch/ia64/kernel/topology.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
