From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Date: Fri, 23 Feb 2018 16:58:46 +0000
Subject: [PATCH 0/3] ARM: Implement MODULE_PLT support in FTRACE
Message-Id: <20180223165849.16388-1-alexander.sverdlin@nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

FTRACE's function tracer currently doesn't always work on ARM with
MODULE_PLT option enabled. If the module is loaded too far, FTRACE's
code modifier cannot cope with introduced veneers and turns the
function tracer off globally.

ARM64 already has a solution for the problem, refer to the following
patches:

arm64: ftrace: emit ftrace-mod.o contents through code
arm64: module-plts: factor out PLT generation code for ftrace
arm64: ftrace: fix !CONFIG_ARM64_MODULE_PLTS kernels
arm64: ftrace: fix building without CONFIG_MODULES
arm64: ftrace: add support for far branches to dynamic ftrace
arm64: ftrace: don't validate branch via PLT in ftrace_make_nop()

But the presented ARM variant has just a half of the footprint in terms of
the changed LoCs. It also retains the code validation-before-modification
instead of switching it off.

Alexander Sverdlin (3):
  ftrace: Add module to ftrace_make_call() parameters
  ARM: PLT: Move struct plt_entries definition to header
  ftrace: Add MODULE_PLTS support

 arch/arm/include/asm/module.h      | 10 ++++++
 arch/arm/kernel/ftrace.c           | 73 ++++++++++++++++++++++++++++++++------
 arch/arm/kernel/module-plts.c      | 58 +++++++++++++++++++-----------
 arch/arm64/kernel/ftrace.c         |  3 +-
 arch/blackfin/kernel/ftrace.c      |  3 +-
 arch/ia64/kernel/ftrace.c          |  3 +-
 arch/metag/kernel/ftrace.c         |  3 +-
 arch/microblaze/kernel/ftrace.c    |  3 +-
 arch/mips/kernel/ftrace.c          |  3 +-
 arch/powerpc/kernel/trace/ftrace.c |  3 +-
 arch/s390/kernel/ftrace.c          |  3 +-
 arch/sh/kernel/ftrace.c            |  3 +-
 arch/sparc/kernel/ftrace.c         |  3 +-
 arch/tile/kernel/ftrace.c          |  3 +-
 arch/x86/kernel/ftrace.c           |  3 +-
 include/linux/ftrace.h             |  4 ++-
 kernel/trace/ftrace.c              |  6 ++--
 17 files changed, 140 insertions(+), 47 deletions(-)

-- 
2.4.6

