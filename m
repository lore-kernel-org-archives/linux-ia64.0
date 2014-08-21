From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 21 Aug 2014 17:16:58 +0000
Subject: [GIT PULL] Add memfd_create syscall to ia64
Message-Id: <53f6298a10338bc27d@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 7d1311b93e58ed55f3a31cc8f94c4b8fe988a2b9:

  Linux 3.17-rc1 (2014-08-16 10:40:26 -0600)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-memfd_create

for you to fetch changes up to 703e6a6ed6088705e48ca9d0e4567962ebddca36:

  [IA64] Wire up memfd_create() system call (2014-08-18 10:29:52 -0700)

----------------------------------------------------------------
Add memfd_create syscall to ia64

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Wire up memfd_create() system call

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 1 +
 arch/ia64/kernel/entry.S            | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)
