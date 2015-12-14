From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Dec 2015 19:16:49 +0000
Subject: [GIT PULL] ia64: wire up mlock2 syscall
Message-Id: <566f15a114877a0aa2@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 9f9499ae8e6415cefc4fe0a96ad0e27864353c89:

  Linux 4.4-rc5 (2015-12-13 17:42:58 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-mlock2

for you to fetch changes up to 27801885151d3c187719f082a0ef54e05b9c9a16:

  [IA64] Enable mlock2 syscall for ia64 (2015-12-14 10:30:02 -0800)

----------------------------------------------------------------
Wire up mlock2() syscall for ia64

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Enable mlock2 syscall for ia64

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 1 +
 arch/ia64/kernel/entry.S            | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)
