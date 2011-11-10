From: Joe Perches <joe@perches.com>
Date: Thu, 10 Nov 2011 09:41:41 +0000
Subject: [PATCH 0/5] treewide: __attribute__ neatening
Message-Id: <cover.1320917551.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@google.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org

Use the more current __<foo> styles for compiler attributes.
NORET_TYPE is #defined to a null comment, so just remove it.

Joe Perches (5):
  kernel.h: Neaten panic prototype
  linkage: Remove unused NORET_AND macro
  treewide: Remove useless NORET_TYPE macro and uses
  treewide: Convert uses of ATTRIB_NORETURN to __noreturn
  linkage: Remove unused ATTRIB_NORET macro

 arch/avr32/include/asm/system.h        |    2 +-
 arch/avr32/kernel/traps.c              |    2 +-
 arch/ia64/kernel/machine_kexec.c       |    4 ++--
 arch/m68k/amiga/config.c               |    4 ++--
 arch/mips/include/asm/ptrace.h         |    2 +-
 arch/mips/kernel/traps.c               |    2 +-
 arch/mn10300/include/asm/exceptions.h  |    2 +-
 arch/powerpc/kernel/machine_kexec_32.c |    4 ++--
 arch/powerpc/kernel/machine_kexec_64.c |    6 +++---
 arch/s390/include/asm/processor.h      |    2 +-
 arch/s390/kernel/nmi.c                 |    2 +-
 arch/sh/kernel/process_32.c            |    2 +-
 arch/sh/kernel/process_64.c            |    2 +-
 arch/tile/kernel/machine_kexec.c       |    6 +++---
 include/linux/kernel.h                 |   13 +++++++------
 include/linux/linkage.h                |    4 ----
 include/linux/sched.h                  |    2 +-
 kernel/exit.c                          |    6 +++---
 kernel/panic.c                         |    2 +-
 19 files changed, 33 insertions(+), 36 deletions(-)

-- 
1.7.6.405.gc1be0

