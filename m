From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 25 Mar 2016 22:02:44 +0000
Subject: [GIT PULL] ia64: wire up p{read,write}v2
Message-Id: <56f5b584264704c0ad@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 1701f680407c6cc05121566cef5293d33881fe71:

  Revert "ppdev: use new parport device model" (2016-03-25 09:02:13 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-preadv2

for you to fetch changes up to 2d5ae5c2c7025b3bac264545f88b4d958fbdccc8:

  [IA64] Enable preadv2 and pwritev2 syscalls for ia64 (2016-03-25 14:37:32 -0700)

----------------------------------------------------------------
Wire up new system calls p{read,write}v2 for ia64

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Enable preadv2 and pwritev2 syscalls for ia64

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 2 ++
 arch/ia64/kernel/entry.S            | 2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)
