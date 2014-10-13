From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Oct 2014 20:15:57 +0000
Subject: [GIT PULL] Wire up bpf syscall for ia64
Message-Id: <543c32fd17368efe51@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit b4fc1a460f3017e958e6a8ea560ea0afd91bf6fe:

  Merge branch 'bpf-next' (2014-09-26 15:05:40 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-sys_bpf

for you to fetch changes up to 5dab4b73c736c2cb8e35148f9ee2365ee48bad79:

  [IA64] Enable bpf syscall for ia64 (2014-10-09 13:36:10 -0700)

----------------------------------------------------------------
Wire up bpf syscall for ia64

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Enable bpf syscall for ia64

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 1 +
 arch/ia64/kernel/entry.S            | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)
