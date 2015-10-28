From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 28 Oct 2015 22:12:45 +0000
Subject: [GIT PULL] Add kcmp() syscall for ia64
Message-Id: <5631485d20491d50e7@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The following changes since commit 32b88194f71d6ae7768a29f87fbba454728273ee:

  Linux 4.3-rc7 (2015-10-25 10:39:47 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-=
pull-syscalls

for you to fetch changes up to d305c4773458fdd6ff9c52bfdea8c67fbd3b2072:

  [IA64] Wire up kcmp syscall (2015-10-28 14:22:59 -0700)

----------------------------------------------------------------
Missed adding the kcmp() syscall a long time ago. Now it seems
that it is essential to build systemd.

----------------------------------------------------------------
=C3=89meric MASCHINO (1):
      [IA64] Wire up kcmp syscall

 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 1 +
 arch/ia64/kernel/entry.S            | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)
