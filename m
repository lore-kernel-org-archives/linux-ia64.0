From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 23 Jun 2006 22:24:28 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200606232224.k5NMOSoi021612@agluck-lia64.sc.intel.com>
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

 Documentation/ia64/aliasing.txt     |  208 ++++++++++++++++++++++++++++++++++++
 arch/ia64/Kconfig                   |    2 
 arch/ia64/Makefile                  |    2 
 arch/ia64/kernel/acpi.c             |    4 
 arch/ia64/kernel/asm-offsets.c      |   16 ++
 arch/ia64/kernel/efi.c              |  156 +++++++++++++++++----------
 arch/ia64/kernel/efi_stub.S         |    2 
 arch/ia64/kernel/entry.h            |    1 
 arch/ia64/kernel/mca_asm.S          |   28 ++--
 arch/ia64/kernel/sal.c              |    6 -
 arch/ia64/kernel/setup.c            |    1 
 arch/ia64/mm/ioremap.c              |   27 +++-
 arch/ia64/pci/pci.c                 |   17 ++
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |   50 ++++----
 arch/ia64/sn/pci/tioce_provider.c   |    4 
 include/asm-ia64/io.h               |    1 
 include/asm-ia64/mca.h              |    9 +
 include/asm-ia64/pgtable.h          |   22 +--
 include/asm-ia64/sn/sn_sal.h        |    2 
 include/linux/efi.h                 |    1 
 20 files changed, 434 insertions(+), 125 deletions(-)

Alex Williamson:
      [IA64] add vmlinuz target
      [IA64] sanity check reserved region usage

Bjorn Helgaas:
      [IA64] rework memory attribute aliasing

David Mosberger-Tang:
      [IA64] make efi_stub.S fit in 80 cols

Ian Wienand:
      [IA64] SKI Simulator boot

Jack Steiner:
      [IA64-SGI] SN topology fix for large systems

Keith Owens:
      [IA64] Sanitize assembler code for ia64_sal_os_state

Kenji Kaneshige:
      [IA64] Make PCI Express support selectable

Mike Habeck:
      [IA64-SGI] fix SGI Altix tioce_bus_fixup() bug

Russ Anderson:
      [IA64-SGI] Remove SN SAL error handling feature bit that is no longer needed

Tony Luck:
      Pull rework-memory-attribute-aliasing into release branch
      Auto-update from upstream
      [IA64] fix ia64 build (fadt_descriptor)
