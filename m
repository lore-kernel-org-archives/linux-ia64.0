From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Aug 2014 14:55:28 +0000
Subject: [GIT PULL] ia64 getrandom(2) syscall
Message-Id: <53e4e4e012783c7ca4@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit c6e9d6f38894798696f23c8084ca7edbf16ee895:

  random: introduce getrandom(2) system call (2014-08-05 16:41:22 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-getrandom

for you to fetch changes up to 5e467e27b7c7a11ef47068138248003e873674a1:

  [IA64] Wire up getrandom() system call (2014-08-06 14:37:12 -0700)

----------------------------------------------------------------
Wire up getrandom system call for ia64

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Wire up getrandom() system call

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 1 +
 arch/ia64/kernel/entry.S            | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)
