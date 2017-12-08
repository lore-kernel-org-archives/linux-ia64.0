From: David Howells <dhowells@redhat.com>
Date: Fri, 08 Dec 2017 15:51:22 +0000
Subject: [PATCH 0/5] Consolidate init_task handling and expand macros
Message-Id: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org


It doesn't seem useful to have the init_task in a header file rather than
in a normal source file.  We could consolidate init_task handling instead and
expand out various macros.

Here's a series of patches that consolidate init_task handling:

 (1) Alter the INIT_TASK_DATA linker script macro to set init_thread_union
     and init_stack rather than defining these in C.

     Insert init_task and init_thread_into into the init_stack area in the
     linker script as appropriate to the configuration, with different
     section markers so that they end up correctly ordered.

     We can then get merge ia64's init_task.c into the main one.

We then have a bunch of single-use INIT_*() macros that seem only to be
macros because they used to be used per-arch.  We can then expand these in
place of the user and get rid of a few lines and a lot of backslashes.

 (2) Expand INIT_TASK() in place.

 (3) Expand in place various small INIT_*() macros that are defined
     conditionally.  Expand them and surround them by #if[n]def/#endif in
     the .c file as it takes fewer lines.

 (4) Expand INIT_SIGNALS() and INIT_SIGHAND() in place.

 (5) Expand INIT_STRUCT_PID in place.

These macros can then be discarded.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=init_task

David
---
David Howells (5):
      Construct init thread stack in the linker script rather than by union
      Expand INIT_TASK() in init/init_task.c and remove
      Expand various INIT_* macros and remove
      Expand the INIT_SIGNALS and INIT_SIGHAND macros and remove
      Expand INIT_STRUCT_PID and remove


 arch/Kconfig                              |    4 
 arch/alpha/include/asm/thread_info.h      |    3 
 arch/arc/include/asm/thread_info.h        |    3 
 arch/arm/include/asm/thread_info.h        |    3 
 arch/arm64/include/asm/thread_info.h      |    2 
 arch/blackfin/include/asm/thread_info.h   |    2 
 arch/c6x/include/asm/thread_info.h        |    3 
 arch/cris/include/asm/processor.h         |    2 
 arch/cris/include/asm/thread_info.h       |    2 
 arch/frv/include/asm/thread_info.h        |    3 
 arch/h8300/include/asm/thread_info.h      |    3 
 arch/hexagon/include/asm/thread_info.h    |    3 
 arch/ia64/Kconfig                         |    2 
 arch/ia64/Makefile                        |    2 
 arch/ia64/include/asm/thread_info.h       |    4 
 arch/ia64/kernel/Makefile                 |    2 
 arch/ia64/kernel/init_task.c              |   44 -----
 arch/ia64/kernel/vmlinux.lds.S            |    1 
 arch/m32r/include/asm/thread_info.h       |    3 
 arch/m68k/include/asm/thread_info.h       |    4 
 arch/metag/include/asm/thread_info.h      |    3 
 arch/microblaze/include/asm/thread_info.h |    3 
 arch/mips/include/asm/thread_info.h       |    3 
 arch/mn10300/include/asm/thread_info.h    |    2 
 arch/nios2/include/asm/thread_info.h      |    3 
 arch/openrisc/include/asm/processor.h     |    2 
 arch/openrisc/include/asm/thread_info.h   |    2 
 arch/parisc/include/asm/thread_info.h     |    3 
 arch/powerpc/include/asm/thread_info.h    |    3 
 arch/s390/include/asm/thread_info.h       |    2 
 arch/score/include/asm/thread_info.h      |    3 
 arch/sh/include/asm/thread_info.h         |    3 
 arch/sparc/include/asm/thread_info_32.h   |    3 
 arch/sparc/include/asm/thread_info_64.h   |    3 
 arch/tile/include/asm/thread_info.h       |    3 
 arch/um/include/asm/processor-generic.h   |    5 -
 arch/um/include/asm/thread_info.h         |    9 -
 arch/um/include/asm/vmlinux.lds.h         |    2 
 arch/um/kernel/dyn.lds.S                  |    3 
 arch/um/kernel/um_arch.c                  |    2 
 arch/um/kernel/uml.lds.S                  |    2 
 arch/unicore32/include/asm/thread_info.h  |    3 
 arch/x86/include/asm/thread_info.h        |    2 
 arch/xtensa/include/asm/thread_info.h     |    3 
 include/asm-generic/vmlinux.lds.h         |    4 
 include/linux/ftrace.h                    |   12 -
 include/linux/init_task.h                 |  258 +----------------------------
 include/linux/irqflags.h                  |    2 
 include/linux/lockdep.h                   |    3 
 include/linux/sched.h                     |    9 +
 init/Makefile                             |    2 
 init/init_task.c                          |  170 ++++++++++++++++++-
 kernel/pid.c                              |   14 +-
 53 files changed, 219 insertions(+), 422 deletions(-)
 delete mode 100644 arch/ia64/kernel/init_task.c
 create mode 100644 arch/um/include/asm/vmlinux.lds.h

