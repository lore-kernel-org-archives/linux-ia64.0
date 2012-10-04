From: David Howells <dhowells@redhat.com>
Date: Thu, 04 Oct 2012 19:51:22 +0000
Subject: [GIT PULL] Disintegrate UAPI for ia64
Message-Id: <17377.1349380282@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: dhowells@redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Can you merge the following branch into the ia64 tree please.

This is to complete part of the UAPI disintegration for which the preparatory
patches were pulled recently.

Note that there are some fixup patches which are at the base of the branch
aimed at you, plus all arches get the asm-generic branch merged in too.

The following changes since commit 612a9aab56a93533e76e3ad91642db7033e03b69:

  Merge branch 'drm-next' of git://people.freedesktop.org/~airlied/linux (2012-10-03 23:29:23 -0700)

are available in the git repository at:


  git://git.infradead.org/users/dhowells/linux-headers.git disintegrate-ia64

for you to fetch changes up to f68301fee71510300140990c4e7a2769801fbd70:

  UAPI: (Scripted) Disintegrate arch/ia64/include/asm (2012-10-04 18:20:49 +0100)

----------------------------------------------------------------
David Howells (6):
      UAPI: Fix the guards on various asm/unistd.h files
      UAPI: Split compound conditionals containing __KERNEL__ in Arm64
      Merge remote-tracking branch 'c6x/for-linux-next' into uapi-prep
      UAPI: Fix conditional header installation handling (notably kvm_para.h on m68k)
      UAPI: (Scripted) Disintegrate include/asm-generic
      UAPI: (Scripted) Disintegrate arch/ia64/include/asm

Mark Salter (2):
      c6x: make dsk6455 the default config
      c6x: remove c6x signal.h

 arch/arm64/include/asm/hwcap.h                     |   4 +-
 arch/arm64/include/asm/stat.h                      |   4 +-
 arch/arm64/include/asm/unistd.h                    |   8 +-
 arch/arm64/include/asm/unistd32.h                  |   4 -
 arch/c6x/Makefile                                  |   2 +
 arch/c6x/include/asm/Kbuild                        |   1 +
 arch/c6x/include/asm/signal.h                      |  17 -
 arch/c6x/include/asm/unistd.h                      |   4 -
 arch/hexagon/include/asm/unistd.h                  |   5 -
 arch/ia64/include/asm/Kbuild                       |  15 -
 arch/ia64/include/asm/gcc_intrin.h                 | 615 +-------------
 arch/ia64/include/asm/intrinsics.h                 | 120 +--
 arch/ia64/include/asm/kvm_para.h                   |  10 +-
 arch/ia64/include/asm/mman.h                       |  12 +-
 arch/ia64/include/asm/param.h                      |  22 +-
 arch/ia64/include/asm/perfmon.h                    | 171 +---
 arch/ia64/include/asm/ptrace.h                     | 236 +-----
 arch/ia64/include/asm/siginfo.h                    | 118 +--
 arch/ia64/include/asm/signal.h                     | 122 +--
 arch/ia64/include/asm/termios.h                    |  46 +-
 arch/ia64/include/asm/types.h                      |  19 +-
 arch/ia64/include/asm/unistd.h                     | 324 +-------
 arch/ia64/include/asm/ustack.h                     |  11 +-
 arch/ia64/include/uapi/asm/Kbuild                  |  45 +
 arch/ia64/include/{ => uapi}/asm/auxvec.h          |   0
 arch/ia64/include/{ => uapi}/asm/bitsperlong.h     |   0
 arch/ia64/include/{ => uapi}/asm/break.h           |   0
 arch/ia64/include/{ => uapi}/asm/byteorder.h       |   0
 arch/ia64/include/{ => uapi}/asm/cmpxchg.h         |   0
 arch/ia64/include/{ => uapi}/asm/errno.h           |   0
 arch/ia64/include/{ => uapi}/asm/fcntl.h           |   0
 arch/ia64/include/{ => uapi}/asm/fpu.h             |   0
 arch/ia64/include/uapi/asm/gcc_intrin.h            | 618 ++++++++++++++
 arch/ia64/include/{ => uapi}/asm/ia64regs.h        |   0
 arch/ia64/include/{ => uapi}/asm/intel_intrin.h    |   0
 arch/ia64/include/uapi/asm/intrinsics.h            | 124 +++
 arch/ia64/include/{ => uapi}/asm/ioctl.h           |   0
 arch/ia64/include/{ => uapi}/asm/ioctls.h          |   0
 arch/ia64/include/{ => uapi}/asm/ipcbuf.h          |   0
 arch/ia64/include/{ => uapi}/asm/kvm.h             |   0
 arch/ia64/include/uapi/asm/mman.h                  |  16 +
 arch/ia64/include/{ => uapi}/asm/msgbuf.h          |   0
 arch/ia64/include/uapi/asm/param.h                 |  29 +
 arch/ia64/include/uapi/asm/perfmon.h               | 177 ++++
 .../include/{ => uapi}/asm/perfmon_default_smpl.h  |   0
 arch/ia64/include/{ => uapi}/asm/poll.h            |   0
 arch/ia64/include/{ => uapi}/asm/posix_types.h     |   0
 arch/ia64/include/uapi/asm/ptrace.h                | 247 ++++++
 arch/ia64/include/{ => uapi}/asm/ptrace_offsets.h  |   0
 arch/ia64/include/{ => uapi}/asm/resource.h        |   0
 arch/ia64/include/{ => uapi}/asm/rse.h             |   0
 arch/ia64/include/{ => uapi}/asm/sembuf.h          |   0
 arch/ia64/include/{ => uapi}/asm/setup.h           |   0
 arch/ia64/include/{ => uapi}/asm/shmbuf.h          |   0
 arch/ia64/include/{ => uapi}/asm/sigcontext.h      |   0
 arch/ia64/include/uapi/asm/siginfo.h               | 121 +++
 arch/ia64/include/uapi/asm/signal.h                | 127 +++
 arch/ia64/include/{ => uapi}/asm/socket.h          |   0
 arch/ia64/include/{ => uapi}/asm/sockios.h         |   0
 arch/ia64/include/{ => uapi}/asm/stat.h            |   0
 arch/ia64/include/{ => uapi}/asm/statfs.h          |   0
 arch/ia64/include/{ => uapi}/asm/swab.h            |   0
 arch/ia64/include/{ => uapi}/asm/termbits.h        |   0
 arch/ia64/include/uapi/asm/termios.h               |  50 ++
 arch/ia64/include/uapi/asm/types.h                 |  31 +
 arch/ia64/include/{ => uapi}/asm/ucontext.h        |   0
 arch/ia64/include/uapi/asm/unistd.h                | 328 ++++++++
 arch/ia64/include/uapi/asm/ustack.h                |  12 +
 arch/openrisc/include/asm/unistd.h                 |   5 -
 arch/score/include/asm/unistd.h                    |   5 -
 arch/tile/include/asm/unistd.h                     |   5 -
 arch/unicore32/include/asm/unistd.h                |   4 -
 include/asm-generic/Kbuild                         |  35 -
 include/asm-generic/bitsperlong.h                  |  13 +-
 include/asm-generic/int-l64.h                      |  26 +-
 include/asm-generic/int-ll64.h                     |  31 +-
 include/asm-generic/ioctl.h                        |  95 +--
 include/asm-generic/kvm_para.h                     |   5 +-
 include/asm-generic/param.h                        |  17 +-
 include/asm-generic/resource.h                     |  66 +-
 include/asm-generic/siginfo.h                      | 297 +------
 include/asm-generic/signal.h                       | 117 +--
 include/asm-generic/statfs.h                       |  81 +-
 include/asm-generic/termios.h                      |  49 +-
 include/asm-generic/unistd.h                       | 911 +--------------------
 include/linux/Kbuild                               |   9 +-
 include/uapi/asm-generic/Kbuild                    |  35 +
 include/{ => uapi}/asm-generic/auxvec.h            |   0
 include/uapi/asm-generic/bitsperlong.h             |  15 +
 include/{ => uapi}/asm-generic/errno-base.h        |   0
 include/{ => uapi}/asm-generic/errno.h             |   0
 include/{ => uapi}/asm-generic/fcntl.h             |   0
 include/uapi/asm-generic/int-l64.h                 |  34 +
 include/uapi/asm-generic/int-ll64.h                |  39 +
 include/uapi/asm-generic/ioctl.h                   |  98 +++
 include/{ => uapi}/asm-generic/ioctls.h            |   0
 include/{ => uapi}/asm-generic/ipcbuf.h            |   0
 include/{ => uapi}/asm-generic/mman-common.h       |   0
 include/{ => uapi}/asm-generic/mman.h              |   0
 include/{ => uapi}/asm-generic/msgbuf.h            |   0
 include/uapi/asm-generic/param.h                   |  19 +
 include/{ => uapi}/asm-generic/poll.h              |   0
 include/{ => uapi}/asm-generic/posix_types.h       |   0
 include/uapi/asm-generic/resource.h                |  68 ++
 include/{ => uapi}/asm-generic/sembuf.h            |   0
 include/{ => uapi}/asm-generic/setup.h             |   0
 include/{ => uapi}/asm-generic/shmbuf.h            |   0
 include/{ => uapi}/asm-generic/shmparam.h          |   0
 include/uapi/asm-generic/siginfo.h                 | 298 +++++++
 include/{ => uapi}/asm-generic/signal-defs.h       |   0
 include/uapi/asm-generic/signal.h                  | 123 +++
 include/{ => uapi}/asm-generic/socket.h            |   0
 include/{ => uapi}/asm-generic/sockios.h           |   0
 include/{ => uapi}/asm-generic/stat.h              |   0
 include/uapi/asm-generic/statfs.h                  |  83 ++
 include/{ => uapi}/asm-generic/swab.h              |   0
 include/{ => uapi}/asm-generic/termbits.h          |   0
 include/uapi/asm-generic/termios.h                 |  50 ++
 include/{ => uapi}/asm-generic/types.h             |   0
 include/{ => uapi}/asm-generic/ucontext.h          |   0
 include/uapi/asm-generic/unistd.h                  | 902 ++++++++++++++++++++
 security/apparmor/Makefile                         |   2 +-
 122 files changed, 3754 insertions(+), 3598 deletions(-)
 delete mode 100644 arch/c6x/include/asm/signal.h
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
 rename include/{ => uapi}/asm-generic/auxvec.h (100%)
 create mode 100644 include/uapi/asm-generic/bitsperlong.h
 rename include/{ => uapi}/asm-generic/errno-base.h (100%)
 rename include/{ => uapi}/asm-generic/errno.h (100%)
 rename include/{ => uapi}/asm-generic/fcntl.h (100%)
 create mode 100644 include/uapi/asm-generic/int-l64.h
 create mode 100644 include/uapi/asm-generic/int-ll64.h
 create mode 100644 include/uapi/asm-generic/ioctl.h
 rename include/{ => uapi}/asm-generic/ioctls.h (100%)
 rename include/{ => uapi}/asm-generic/ipcbuf.h (100%)
 create mode 100644 include/uapi/asm-generic/kvm_para.h
 rename include/{ => uapi}/asm-generic/mman-common.h (100%)
 rename include/{ => uapi}/asm-generic/mman.h (100%)
 rename include/{ => uapi}/asm-generic/msgbuf.h (100%)
 create mode 100644 include/uapi/asm-generic/param.h
 rename include/{ => uapi}/asm-generic/poll.h (100%)
 rename include/{ => uapi}/asm-generic/posix_types.h (100%)
 create mode 100644 include/uapi/asm-generic/resource.h
 rename include/{ => uapi}/asm-generic/sembuf.h (100%)
 rename include/{ => uapi}/asm-generic/setup.h (100%)
 rename include/{ => uapi}/asm-generic/shmbuf.h (100%)
 rename include/{ => uapi}/asm-generic/shmparam.h (100%)
 create mode 100644 include/uapi/asm-generic/siginfo.h
 rename include/{ => uapi}/asm-generic/signal-defs.h (100%)
 create mode 100644 include/uapi/asm-generic/signal.h
 rename include/{ => uapi}/asm-generic/socket.h (100%)
 rename include/{ => uapi}/asm-generic/sockios.h (100%)
 rename include/{ => uapi}/asm-generic/stat.h (100%)
 create mode 100644 include/uapi/asm-generic/statfs.h
 rename include/{ => uapi}/asm-generic/swab.h (100%)
 rename include/{ => uapi}/asm-generic/termbits.h (100%)
 create mode 100644 include/uapi/asm-generic/termios.h
 rename include/{ => uapi}/asm-generic/types.h (100%)
 rename include/{ => uapi}/asm-generic/ucontext.h (100%)
 create mode 100644 include/uapi/asm-generic/unistd.h
.
