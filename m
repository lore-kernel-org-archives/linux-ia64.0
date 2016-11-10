From: Hari Bathini <hbathini@linux.vnet.ibm.com>
Date: Thu, 10 Nov 2016 11:57:40 +0000
Subject: [PATCH 0/3] kexec/fadump: remove dependency with CONFIG_KEXEC and reuse crashkernel parameter for fa
Message-Id: <147877899077.31483.3740501843050856595.stgit@hbathini.in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dyoung@redhat.com, kexec@lists.infradead.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, ebiederm@xmission.com, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

Traditionally, kdump is used to save vmcore in case of a crash. Some
architectures like powerpc can save vmcore using architecture specific
support instead of kexec/kdump mechanism. Such architecture specific
support also needs to reserve memory, to be used by dump capture kernel.
crashkernel parameter can be a reused, for memory reservation, by such
architecture specific infrastructure.

This patchset removes dependency with CONFIG_KEXEC for crashkernel parameter
and vmcoreinfo related code as it can be reused without kexec support. Also,
crashkernel parameter is reused instead of fadump_reserve_mem to reserve
memory for fadump.

The first patch moves crashkernel parameter parsing and vmcoreinfo related
code under CONFIG_CRASH_CORE instead of CONFIG_KEXEC_CORE to reuse without
depending on it. The second patch reuses crashkernel for reserving memory
for fadump instead of fadump_reserve_mem. This has the advantage of using
all the syntaxes crashkernel supports, for fadump as well. The third patch
updates fadump kernel documentation about use of crashkernel parameter.

---

Hari Bathini (3):
      crash: move crashkernel parsing and vmcore related code under CONFIG_CRASH_CORE
      powerpc/fadump: reuse crashkernel parameter for fadump memory reservation
      powerpc/fadump: update documentation about crashkernel parameter reuse


 Documentation/powerpc/firmware-assisted-dump.txt |   23 +
 arch/Kconfig                                     |    4 
 arch/ia64/kernel/crash.c                         |   22 -
 arch/powerpc/Kconfig                             |   10 
 arch/powerpc/include/asm/fadump.h                |    2 
 arch/powerpc/kernel/crash.c                      |    2 
 arch/powerpc/kernel/fadump.c                     |   57 +--
 arch/powerpc/kernel/setup-common.c               |    5 
 include/linux/crash_core.h                       |   75 ++++
 include/linux/kexec.h                            |   63 ---
 kernel/Makefile                                  |    1 
 kernel/crash_core.c                              |  450 ++++++++++++++++++++++
 kernel/kexec_core.c                              |  435 ---------------------
 13 files changed, 575 insertions(+), 574 deletions(-)
 create mode 100644 include/linux/crash_core.h
 create mode 100644 kernel/crash_core.c

