From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 12 Oct 2020 20:01:49 +0000
Subject: [PLEASE PULL] ia64 for v5.10
Message-Id: <20201012200149.GA27228@agluck-desk2.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

The following changes since commit f4d51dffc6c01a9e94650d95ce0104964f8ae822:

  Linux 5.9-rc4 (2020-09-06 17:11:40 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/ia64_for_5.10

for you to fetch changes up to c331649e637152788b0ca1c857d0c2eaf34fcbc3:

  ia64: Use libata instead of the legacy ide driver in defconfigs (2020-09-11 09:38:00 -0700)

----------------------------------------------------------------
Cleanups by Christoph
1) Switch to libata instead of legacy ide driver
2) Drop ia64 perfmon (it's been broken for a while)

----------------------------------------------------------------
Christoph Hellwig (2):
      ia64: Remove perfmon
      ia64: Use libata instead of the legacy ide driver in defconfigs

 arch/ia64/Kconfig                     |    9 -
 arch/ia64/configs/bigsur_defconfig    |    8 +-
 arch/ia64/configs/generic_defconfig   |   10 +-
 arch/ia64/configs/gensparse_defconfig |   10 +-
 arch/ia64/configs/tiger_defconfig     |   10 +-
 arch/ia64/configs/zx1_defconfig       |    8 +-
 arch/ia64/include/asm/processor.h     |   10 -
 arch/ia64/include/asm/switch_to.h     |   10 +-
 arch/ia64/kernel/Makefile             |    3 +-
 arch/ia64/kernel/irq_ia64.c           |    7 -
 arch/ia64/kernel/perfmon.c            | 6703 ---------------------------------
 arch/ia64/kernel/process.c            |   53 -
 arch/ia64/kernel/ptrace.c             |   24 -
 arch/ia64/kernel/smpboot.c            |    8 -
 arch/ia64/kernel/syscalls/syscall.tbl |    2 +-
 arch/ia64/lib/Makefile                |    1 -
 arch/ia64/lib/carta_random.S          |   55 -
 arch/ia64/oprofile/Makefile           |    1 -
 arch/ia64/oprofile/init.c             |   12 +-
 arch/ia64/oprofile/perfmon.c          |   99 -
 20 files changed, 22 insertions(+), 7021 deletions(-)
 delete mode 100644 arch/ia64/kernel/perfmon.c
 delete mode 100644 arch/ia64/lib/carta_random.S
 delete mode 100644 arch/ia64/oprofile/perfmon.c
