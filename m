From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 12 Jul 2007 00:04:57 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A01E6CFAE@scsmsx411.amr.corp.intel.com>
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

 Documentation/ia64/aliasing-test.c      |   26 ++++++++---
 Documentation/ia64/aliasing.txt         |   12 +++++
 arch/ia64/kernel/gate.S                 |    1 
 arch/ia64/kernel/mca.c                  |   60 +++++++++++++++++++++++---
 arch/ia64/kernel/mca_asm.S              |   12 -----
 arch/ia64/kernel/mca_drv_asm.S          |    6 ++
 arch/ia64/kernel/process.c              |    3 -
 arch/ia64/mm/tlb.c                      |    2 
 arch/ia64/pci/pci.c                     |   22 +++++++--
 arch/ia64/sn/kernel/io_acpi_init.c      |   17 +++----
 arch/ia64/sn/kernel/io_init.c           |   20 +++++++-
 arch/ia64/sn/kernel/tiocx.c             |    2 
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    2 
 drivers/pci/rom.c                       |   73 +++++++++++++++++++-------------
 include/asm-ia64/mca.h                  |    1 
 include/asm-ia64/sn/sn_sal.h            |   20 ++++++++
 include/linux/pci.h                     |    1 
 17 files changed, 203 insertions(+), 77 deletions(-)

Alex Chiang (1):
      [IA64] prevent MCA when performing MMIO mmap to PCI config space

Christian Kandeler (1):
      [IA64] Stop bit for brl instruction

Dean Nelson (1):
      [IA64] add sn_register_pmi_handler oemcall

Jes Sorensen (1):
      [IA64] silence GCC ia64 unused variable warnings

John Keller (1):
      [IA64] SN: Correct ROM resource length for BIOS copy

Russ Anderson (1):
      [IA64] Support multiple CPUs going through OS_MCA

Tony Luck (1):
      [IA64] Don't set psr.ic and psr.i simultaneously
