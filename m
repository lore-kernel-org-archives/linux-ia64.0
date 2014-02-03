From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 03 Feb 2014 21:09:23 +0000
Subject: [GIT PULL] ia64 - new syscalls for 3.14
Message-Id: <52f0058310755d9635@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 54c0a4b46150db1571d955d598cd342c9f1d9657:

  Merge branch 'akpm' (incoming from Andrew) (2014-01-27 21:17:55 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-ia64-syscalls

for you to fetch changes up to 7de8246eba58c6f4c315b8c69fb29e445ccf3c80:

  [IA64] Wire up new sched_setattr and sched_getattr syscalls (2014-01-28 09:52:53 -0800)

----------------------------------------------------------------
Wire up new sched_setattr and sched_getattr syscalls

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Wire up new sched_setattr and sched_getattr syscalls

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 2 ++
 arch/ia64/kernel/entry.S            | 2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)
