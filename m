From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 02 Jun 2015 17:40:22 +0000
Subject: [GIT PULL] Fix ia64 build warnings
Message-Id: <556dea867147dc8c5@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit c65b99f046843d2455aa231747b5a07a999a9f3d:

  Linux 4.1-rc6 (2015-05-31 19:01:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-rusty

for you to fetch changes up to 5eda7861e347ffe927ecde5abd74d7b13ae938fa:

  ia64: make cpu_callin_map non-volatile. (2015-06-02 10:07:03 -0700)

----------------------------------------------------------------
Fix some build warnings for ia64 - cpu_callin_map doesn't need to be volatile

----------------------------------------------------------------
Rusty Russell (1):
      ia64: make cpu_callin_map non-volatile.

 arch/ia64/kernel/smpboot.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
