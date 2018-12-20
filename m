From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 20 Dec 2018 18:54:05 +0000
Subject: [GIT PULL] ia64 update for v4.21/v5.0/whatever
Message-Id: <20181220185405.GA17602@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 651022382c7f8da46cb4872a545ee1da6d097d2a:

  Linux 4.20-rc1 (2018-11-04 15:37:52 -0800)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git please-pull-y2038prep

for you to fetch changes up to c51836246f9772dfab8ca7bb945f4a566fe502d5:

  ia64: generate uapi header and system call table files (2018-11-13 08:56:25 -0800)

----------------------------------------------------------------
Change ia64 to make it easier to update system call tables
(in line with some other architectures). This is in preparation
for y2038 changes which are forecasted to add several new system
calls.

----------------------------------------------------------------
Firoz Khan (5):
      ia64: add __NR_old_getpagesize in uapi header file
      ia64: add __NR_syscalls along with NR_syscalls
      ia64: add an offset for system call number
      ia64: add system call table generation support
      ia64: generate uapi header and system call table files

 arch/ia64/Makefile                      |   3 +
 arch/ia64/include/asm/Kbuild            |   1 +
 arch/ia64/include/asm/unistd.h          |   4 +-
 arch/ia64/include/uapi/asm/Kbuild       |   1 +
 arch/ia64/include/uapi/asm/unistd.h     | 332 +------------------------------
 arch/ia64/kernel/entry.S                | 331 +------------------------------
 arch/ia64/kernel/syscalls/Makefile      |  40 ++++
 arch/ia64/kernel/syscalls/syscall.tbl   | 337 ++++++++++++++++++++++++++++++++
 arch/ia64/kernel/syscalls/syscallhdr.sh |  36 ++++
 arch/ia64/kernel/syscalls/syscalltbl.sh |  32 +++
 10 files changed, 458 insertions(+), 659 deletions(-)
 create mode 100644 arch/ia64/kernel/syscalls/Makefile
 create mode 100644 arch/ia64/kernel/syscalls/syscall.tbl
 create mode 100644 arch/ia64/kernel/syscalls/syscallhdr.sh
 create mode 100644 arch/ia64/kernel/syscalls/syscalltbl.sh
