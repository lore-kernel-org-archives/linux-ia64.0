From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 07 May 2007 16:54:56 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A016DA2B4@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Repost ... this seems to have been eaten by the internet, it
didn't show up on the mailing list either].

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
release

This will update the files shown below.

Thanks!

-Tony

 Documentation/ia64/aliasing-test.c |  247 ++++++++
 Documentation/ia64/aliasing.txt    |   71 +-
 Documentation/ia64/err_inject.txt  | 1070
++++++++++++++++++++++++++++++++++++-
 arch/ia64/Kconfig                  |   10 
 arch/ia64/defconfig                |    1 
 arch/ia64/kernel/Makefile          |    1 
 arch/ia64/kernel/efi.c             |   46 +
 arch/ia64/kernel/entry.S           |    7 
 arch/ia64/kernel/err_inject.c      |  293 ++++++++++
 arch/ia64/kernel/ivt.S             |   19 
 arch/ia64/kernel/mca_asm.S         |   24 
 arch/ia64/kernel/patch.c           |   20 
 arch/ia64/kernel/setup.c           |    7 
 arch/ia64/kernel/vmlinux.lds.S     |    7 
 arch/ia64/mm/init.c                |   11 
 arch/ia64/mm/ioremap.c             |   86 ++
 arch/ia64/pci/pci.c                |    2 
 include/asm-ia64/asmmacro.h        |   10 
 include/asm-ia64/io.h              |    6 
 include/asm-ia64/kregs.h           |    3 
 include/asm-ia64/pal.h             |   33 +
 include/asm-ia64/patch.h           |    1 
 include/asm-ia64/processor.h       |    1 
 include/asm-ia64/sections.h        |    1 
 24 files changed, 1866 insertions(+), 111 deletions(-)

Bjorn Helgaas (5):
      [IA64] rename ioremap variables to match i386
      [IA64] make ioremap avoid unsupported attributes
      [IA64] allow WB /sys/.../legacy_mem mmaps
      [IA64] fail mmaps that span areas with incompatible attributes
      [IA64] update memory attribute aliasing documentation & test cases

Fenghua Yu (5):
      [IA64] Itanium MC Error Injection Tool: Kernel configuration
      [IA64] Itanium MC Error Injection Tool: Doc and sample application
      [IA64] Itanium MC Error Injection Tool: Driver sysfs interface
      [IA64] Itanium MC Error Injection Tool: Makefile changes
      [IA64] Itanium MC Error Injection Tool: pal_mc_error_inject()
interface

Kenneth W Chen (2):
      [IA64] remove per-cpu ia64_phys_stacked_size_p8
      [IA64] relax per-cpu TLB requirement to DTC

Tony Luck (1):
      [IA64] Fix example error injection program
