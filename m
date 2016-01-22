From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 22 Jan 2016 23:07:04 +0000
Subject: [GIT PULL] ia64 - wire up copy_file_range syscall
Message-Id: <56a2b6184155e133f@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 3e1e21c7bfcfa9bf06c07f48a13faca2f62b3339:

  Merge branch 'for-4.5/nvme' of git://git.kernel.dk/linux-block (2016-01-21 19:58:02 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-copy_file_range

for you to fetch changes up to 884a12a5972fc867a93f7adf7a8ac2ade5d38fff:

  [IA64] Enable copy_file_range syscall for ia64 (2016-01-22 14:20:01 -0800)

----------------------------------------------------------------
Another release, another new syscall to wire up.

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Enable copy_file_range syscall for ia64

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 1 +
 arch/ia64/kernel/entry.S            | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)
