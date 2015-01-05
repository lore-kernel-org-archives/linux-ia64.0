From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 05 Jan 2015 21:22:24 +0000
Subject: [GIT PULL] Add execveat syscall for ia64
Message-Id: <54ab0090287432ac67@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 693a30b8f19a964087a3762d09fb2e1cbad6b0d4:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/rw/uml (2015-01-04 11:46:43 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-syscall

for you to fetch changes up to b739896dd262ca523497913b0ea232da56d6ee69:

  [IA64] Enable execveat syscall for ia64 (2015-01-05 11:25:19 -0800)

----------------------------------------------------------------
Add execveat syscall

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Enable execveat syscall for ia64

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 1 +
 arch/ia64/kernel/entry.S            | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)
