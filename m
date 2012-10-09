From: David Howells <dhowells@redhat.com>
Date: Tue, 09 Oct 2012 09:15:29 +0000
Subject: [GIT PULL] Disintegrate UAPI for ia64 [ver #2]
Message-Id: <21137.1349774129@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: dhowells@redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Can you merge the following branch into the ia64 tree please.

This is to complete part of the UAPI disintegration for which the preparatory
patches were pulled recently.

Now that the fixups and the asm-generic chunk have been merged, I've
regenerated the patches to get rid of those dependencies and to take account of
any changes made so far in the merge window.  If you have already pulled the
older version of the branch aimed at you, then please feel free to ignore this
request.

The following changes since commit 9e2d8656f5e8aa214e66b462680cf86b210b74a8:

  Merge branch 'akpm' (Andrew's patch-bomb) (2012-10-09 16:23:15 +0900)

are available in the git repository at:


  git://git.infradead.org/users/dhowells/linux-headers.git tags/disintegrate-ia64-20121009

for you to fetch changes up to 43e40f25d2c090392fc36cb900b42972e88cc2e2:

  UAPI: (Scripted) Disintegrate arch/ia64/include/asm (2012-10-09 09:47:00 +0100)

----------------------------------------------------------------
UAPI Disintegration 2012-10-09

----------------------------------------------------------------
David Howells (1):
      UAPI: (Scripted) Disintegrate arch/ia64/include/asm

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
.
