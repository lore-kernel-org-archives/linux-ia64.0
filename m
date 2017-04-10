From: David Howells <dhowells@redhat.com>
Date: Mon, 10 Apr 2017 12:15:51 +0000
Subject: [RFC PATCH 0/5] Consolidate init_task handling
Message-Id: <149182655182.9959.4421578108754243877.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org


Here are some patches that consolidate init_task handling:

 (1) Alter the INIT_TASK_DATA linker script macro to set init_thread_union
     and init_stack rather than defining these in C.

     Insert init_task and init_thread_into into the init_stack area in the
     linker script as appropriate to the configuration, with different
     section markers so that they end up correctly ordered.

     We can then get merge ia64's init_task.c into the main one.

We then have a bunch of single-use INIT_*() macros that seem only to be
macros because they used to be used per-arch.  We can then unroll these in
place of the user and get rid of a few lines and a lot of backslashes.

 (2) Unroll INIT_TASK().

 (3) Unroll various small INIT_*() macros that are defined conditionally.
     Unroll them and surround them by #if[n]def/#endif in the .c file as it
     takes fewer lines.

 (4) Unroll INIT_SIGNALS() and INIT_SIGHAND().

 (5) Unroll INIT_STRUCT_PID.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=init_task

David
---
David Howells (5):
      Construct init thread stack in the linker script rather than by union
      Unroll INIT_TASK() in init/init_task.c
      Unroll various INIT_* macros
      Unroll the INIT_SIGNALS and INIT_SIGHAND macros
      Unroll INIT_STRUCT_PID


 arch/Kconfig                              |    4 
 arch/alpha/include/asm/thread_info.h      |    3 
 arch/arc/include/asm/thread_info.h        |    3 
 arch/arm/include/asm/thread_info.h        |    3 
 arch/arm64/include/asm/thread_info.h      |    2 
 arch/avr32/include/asm/thread_info.h      |    3 
 arch/blackfin/include/asm/thread_info.h   |    2 
 arch/c6x/include/asm/thread_info.h        |    3 
 arch/cris/include/asm/processor.h         |    2 
 arch/frv/include/asm/thread_info.h        |    3 
 arch/h8300/include/asm/thread_info.h      |    3 
 arch/hexagon/include/asm/thread_info.h    |    3 
 arch/ia64/Kconfig                         |    2 
 arch/ia64/Makefile                        |    2 
 arch/ia64/include/asm/thread_info.h       |    4 
 arch/ia64/kernel/Makefile                 |    2 
 arch/ia64/kernel/init_task.c              |   43 -----
 arch/ia64/kernel/vmlinux.lds.S            |    1 
 arch/m32r/include/asm/thread_info.h       |    3 
 arch/m68k/include/asm/thread_info.h       |    2 
 arch/metag/include/asm/thread_info.h      |    3 
 arch/microblaze/include/asm/thread_info.h |    3 
 arch/mips/include/asm/thread_info.h       |    3 
 arch/mn10300/include/asm/thread_info.h    |    2 
 arch/nios2/include/asm/thread_info.h      |    3 
 arch/openrisc/include/asm/processor.h     |    2 
 arch/parisc/include/asm/thread_info.h     |    3 
 arch/powerpc/include/asm/thread_info.h    |    3 
 arch/s390/include/asm/thread_info.h       |    2 
 arch/score/include/asm/thread_info.h      |    3 
 arch/sh/include/asm/thread_info.h         |    3 
 arch/sparc/include/asm/thread_info_32.h   |    3 
 arch/sparc/include/asm/thread_info_64.h   |    3 
 arch/tile/include/asm/thread_info.h       |    3 
 arch/um/include/asm/processor-generic.h   |    2 
 arch/um/include/asm/thread_info.h         |    3 
 arch/unicore32/include/asm/thread_info.h  |    3 
 arch/x86/include/asm/thread_info.h        |    2 
 arch/xtensa/include/asm/thread_info.h     |    3 
 include/asm-generic/vmlinux.lds.h         |    4 
 include/linux/init_task.h                 |  247 +----------------------------
 include/linux/sched.h                     |    9 +
 init/Makefile                             |    2 
 init/init_task.c                          |  158 ++++++++++++++++++-
 kernel/pid.c                              |   15 ++
 45 files changed, 196 insertions(+), 384 deletions(-)
 delete mode 100644 arch/ia64/kernel/init_task.c

