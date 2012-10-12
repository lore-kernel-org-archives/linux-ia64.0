From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 12 Oct 2012 22:52:21 +0000
Subject: [GIT PULL] ia64 uapi include file moves
Message-Id: <50789f25154775aeee@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 9e2d8656f5e8aa214e66b462680cf86b210b74a8:

  Merge branch 'akpm' (Andrew's patch-bomb) (2012-10-09 16:23:15 +0900)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-dhowells-uapi

for you to fetch changes up to d536e0db2433686238ec97c517e4fc691000ee6f:

  Merge tag 'disintegrate-ia64-20121009' of git://git.infradead.org/users/dhowells/linux-headers into next (2012-10-09 16:09:57 -0700)

----------------------------------------------------------------

ia64 pieces of David Howells great UAPI include file move

----------------------------------------------------------------
David Howells (1):
      UAPI: (Scripted) Disintegrate arch/ia64/include/asm

Tony Luck (1):
      Merge tag 'disintegrate-ia64-20121009' of git://git.infradead.org/users/dhowells/linux-headers into next

 arch/ia64/include/asm/Kbuild                       |  14 -
 arch/ia64/include/asm/gcc_intrin.h                 | 615 +-------------------
 arch/ia64/include/asm/intrinsics.h                 | 120 +---
 arch/ia64/include/asm/kvm_para.h                   |  10 +-
 arch/ia64/include/asm/mman.h                       |  12 +-
 arch/ia64/include/asm/param.h                      |  22 +-
 arch/ia64/include/asm/perfmon.h                    | 171 +-----
 arch/ia64/include/asm/ptrace.h                     | 236 +-------
 arch/ia64/include/asm/siginfo.h                    | 118 +---
 arch/ia64/include/asm/signal.h                     | 122 +---
 arch/ia64/include/asm/termios.h                    |  46 +-
 arch/ia64/include/asm/types.h                      |  19 +-
 arch/ia64/include/asm/unistd.h                     | 324 +----------
 arch/ia64/include/asm/ustack.h                     |  11 +-
 arch/ia64/include/uapi/asm/Kbuild                  |  45 ++
 arch/ia64/include/{ => uapi}/asm/auxvec.h          |   0
 arch/ia64/include/{ => uapi}/asm/bitsperlong.h     |   0
 arch/ia64/include/{ => uapi}/asm/break.h           |   0
 arch/ia64/include/{ => uapi}/asm/byteorder.h       |   0
 arch/ia64/include/{ => uapi}/asm/cmpxchg.h         |   0
 arch/ia64/include/{ => uapi}/asm/errno.h           |   0
 arch/ia64/include/{ => uapi}/asm/fcntl.h           |   0
 arch/ia64/include/{ => uapi}/asm/fpu.h             |   0
 arch/ia64/include/uapi/asm/gcc_intrin.h            | 618 +++++++++++++++++++++
 arch/ia64/include/{ => uapi}/asm/ia64regs.h        |   0
 arch/ia64/include/{ => uapi}/asm/intel_intrin.h    |   0
 arch/ia64/include/uapi/asm/intrinsics.h            | 124 +++++
 arch/ia64/include/{ => uapi}/asm/ioctl.h           |   0
 arch/ia64/include/{ => uapi}/asm/ioctls.h          |   0
 arch/ia64/include/{ => uapi}/asm/ipcbuf.h          |   0
 arch/ia64/include/{ => uapi}/asm/kvm.h             |   0
 arch/ia64/include/uapi/asm/mman.h                  |  16 +
 arch/ia64/include/{ => uapi}/asm/msgbuf.h          |   0
 arch/ia64/include/uapi/asm/param.h                 |  29 +
 arch/ia64/include/uapi/asm/perfmon.h               | 177 ++++++
 .../include/{ => uapi}/asm/perfmon_default_smpl.h  |   0
 arch/ia64/include/{ => uapi}/asm/poll.h            |   0
 arch/ia64/include/{ => uapi}/asm/posix_types.h     |   0
 arch/ia64/include/uapi/asm/ptrace.h                | 247 ++++++++
 arch/ia64/include/{ => uapi}/asm/ptrace_offsets.h  |   0
 arch/ia64/include/{ => uapi}/asm/resource.h        |   0
 arch/ia64/include/{ => uapi}/asm/rse.h             |   0
 arch/ia64/include/{ => uapi}/asm/sembuf.h          |   0
 arch/ia64/include/{ => uapi}/asm/setup.h           |   0
 arch/ia64/include/{ => uapi}/asm/shmbuf.h          |   0
 arch/ia64/include/{ => uapi}/asm/sigcontext.h      |   0
 arch/ia64/include/uapi/asm/siginfo.h               | 121 ++++
 arch/ia64/include/uapi/asm/signal.h                | 127 +++++
 arch/ia64/include/{ => uapi}/asm/socket.h          |   0
 arch/ia64/include/{ => uapi}/asm/sockios.h         |   0
 arch/ia64/include/{ => uapi}/asm/stat.h            |   0
 arch/ia64/include/{ => uapi}/asm/statfs.h          |   0
 arch/ia64/include/{ => uapi}/asm/swab.h            |   0
 arch/ia64/include/{ => uapi}/asm/termbits.h        |   0
 arch/ia64/include/uapi/asm/termios.h               |  50 ++
 arch/ia64/include/uapi/asm/types.h                 |  31 ++
 arch/ia64/include/{ => uapi}/asm/ucontext.h        |   0
 arch/ia64/include/uapi/asm/unistd.h                | 328 +++++++++++
 arch/ia64/include/uapi/asm/ustack.h                |  12 +
 59 files changed, 1961 insertions(+), 1804 deletions(-)
 rename arch/ia64/include/{ => uapi}/asm/auxvec.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/bitsperlong.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/break.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/byteorder.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/cmpxchg.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/errno.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/fcntl.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/fpu.h (100%)
 create mode 100644 arch/ia64/include/uapi/asm/gcc_intrin.h
 rename arch/ia64/include/{ => uapi}/asm/ia64regs.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/intel_intrin.h (100%)
 create mode 100644 arch/ia64/include/uapi/asm/intrinsics.h
 rename arch/ia64/include/{ => uapi}/asm/ioctl.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/ioctls.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/ipcbuf.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/kvm.h (100%)
 create mode 100644 arch/ia64/include/uapi/asm/kvm_para.h
 create mode 100644 arch/ia64/include/uapi/asm/mman.h
 rename arch/ia64/include/{ => uapi}/asm/msgbuf.h (100%)
 create mode 100644 arch/ia64/include/uapi/asm/param.h
 create mode 100644 arch/ia64/include/uapi/asm/perfmon.h
 rename arch/ia64/include/{ => uapi}/asm/perfmon_default_smpl.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/poll.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/posix_types.h (100%)
 create mode 100644 arch/ia64/include/uapi/asm/ptrace.h
 rename arch/ia64/include/{ => uapi}/asm/ptrace_offsets.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/resource.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/rse.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/sembuf.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/setup.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/shmbuf.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/sigcontext.h (100%)
 create mode 100644 arch/ia64/include/uapi/asm/siginfo.h
 create mode 100644 arch/ia64/include/uapi/asm/signal.h
 rename arch/ia64/include/{ => uapi}/asm/socket.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/sockios.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/stat.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/statfs.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/swab.h (100%)
 rename arch/ia64/include/{ => uapi}/asm/termbits.h (100%)
 create mode 100644 arch/ia64/include/uapi/asm/termios.h
 create mode 100644 arch/ia64/include/uapi/asm/types.h
 rename arch/ia64/include/{ => uapi}/asm/ucontext.h (100%)
 create mode 100644 arch/ia64/include/uapi/asm/unistd.h
 create mode 100644 arch/ia64/include/uapi/asm/ustack.h
