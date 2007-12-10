From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 10 Dec 2007 21:37:46 +0000
Subject: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843EC0FD421@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Makefile                   |    2 +-
 arch/ia64/hp/sim/boot/Makefile       |    2 +-
 arch/ia64/hp/sim/boot/bootloader.lds |    3 ++-
 arch/ia64/kernel/acpi.c              |    2 +-
 arch/ia64/kernel/efi.c               |   10 +++++-----
 arch/ia64/kernel/gate.lds.S          |    2 +-
 arch/ia64/kernel/ia64_ksyms.c        |    3 +++
 arch/ia64/kernel/iosapic.c           |   21 ++++-----------------
 arch/ia64/kernel/kprobes.c           |   29 ++++++++++++++++++++++-------
 arch/ia64/kernel/setup.c             |    3 +--
 arch/ia64/kernel/signal.c            |    8 ++++----
 arch/ia64/kernel/vmlinux.lds.S       |    3 ++-
 arch/ia64/lib/Makefile               |    4 ++--
 arch/ia64/mm/tlb.c                   |    2 +-
 arch/ia64/sn/kernel/io_common.c      |   13 ++++++-------
 include/asm-ia64/iosapic.h           |    2 --
 16 files changed, 56 insertions(+), 53 deletions(-)

Andrew Morton (3):
      [IA64] increase .data.patch offset
      [IA64] don't assume that unwcheck.py is executable
      [IA64] export copy_page() to modules

Bernhard Walle (1):
      [IA64] rename _bss to __bss_start

Joe Perches (1):
      [IA64] Add missing "space" to concatenated strings

Kenji Kaneshige (1):
      [IA64] Fix iosapic interrupt delivery mode for CPE

Li Zefan (1):
      [IA64] make full use of macro efi_md_size

Mike Habeck (1):
      [IA64] SGI Altix : fix bug in sn_io_late_init()

Roel Kluin (1):
      [IA64] operator priority fix in acpi_map_lsapic()

Shaohua Li (1):
      [IA64] kprobe: make kreturn probe handler stack unwind correct

Shi Weihua (1):
      [IA64] signal : fix missing error checkings

Simon Horman (1):
      [IA64] iosapic cleanup
