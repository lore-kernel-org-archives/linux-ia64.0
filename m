From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 24 Mar 2006 22:57:15 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200603242257.k2OMvFfx019705@agluck-lia64.sc.intel.com>
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

 arch/ia64/Kconfig                       |    9 ++
 arch/ia64/configs/gensparse_defconfig   |    1 
 arch/ia64/configs/sn2_defconfig         |    1 
 arch/ia64/defconfig                     |    1 
 arch/ia64/dig/setup.c                   |    5 -
 arch/ia64/kernel/acpi.c                 |   35 +++++++++-
 arch/ia64/kernel/ivt.S                  |    1 
 arch/ia64/kernel/machvec.c              |   19 ++++-
 arch/ia64/kernel/mca.c                  |  110 ++++++++++++++++++++++----------
 arch/ia64/kernel/mca_drv.c              |   22 ++++--
 arch/ia64/kernel/mca_drv.h              |    7 ++
 arch/ia64/kernel/mca_drv_asm.S          |   13 +--
 arch/ia64/kernel/numa.c                 |    2 
 arch/ia64/kernel/patch.c                |    8 +-
 arch/ia64/kernel/setup.c                |   60 ++++++-----------
 arch/ia64/kernel/smpboot.c              |  109 +------------------------------
 arch/ia64/kernel/vmlinux.lds.S          |   60 ++++++++++-------
 arch/ia64/mm/contig.c                   |    8 +-
 arch/ia64/mm/discontig.c                |    2 
 arch/ia64/mm/hugetlbpage.c              |    7 --
 arch/ia64/mm/init.c                     |   16 ++--
 arch/ia64/sn/kernel/io_init.c           |   29 ++++++++
 arch/ia64/sn/kernel/irq.c               |   21 ------
 arch/ia64/sn/kernel/tiocx.c             |   10 ++
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |   17 ++++
 include/asm-ia64/acpi.h                 |    4 +
 include/asm-ia64/asmmacro.h             |   11 +++
 include/asm-ia64/machvec_dig.h          |    2 
 include/asm-ia64/numa.h                 |    2 
 include/asm-ia64/numnodes.h             |   13 ++-
 include/asm-ia64/page.h                 |    2 
 include/asm-ia64/pal.h                  |    3 
 include/asm-ia64/processor.h            |    1 
 include/asm-ia64/sn/l1.h                |    3 
 include/asm-ia64/sn/pcibr_provider.h    |    1 
 include/asm-ia64/sn/pcidev.h            |    1 
 include/asm-ia64/sn/sn_feature_sets.h   |    3 
 include/asm-ia64/sn/sn_sal.h            |   24 ++++--
 38 files changed, 349 insertions(+), 294 deletions(-)

Bjorn Helgaas:
      [IA64] sn_check_intr: use ia64_get_irr()

Chen, Kenneth W:
      [IA64] fix ia64 is_hugepage_only_range
      [IA64] add __init declaration to mca functions
      [IA64] add init declaration to cpu initialization functions
      [IA64] add init declaration to memory initialization functions
      [IA64] add init declaration - gate page functions
      [IA64] add init declaration - nolwsys
      [IA64] move patchlist and machvec into init section
      [IA64] cleanup dig_irq_init

Fenghua Yu:
      [IA64] New IA64 core/thread detection patch

Horms:
      IA64: Use early_parm to handle mvec_name and nomca

Jack Steiner:
      [IA64] Increase max node count on SN platforms
      [IA64] Increase max node count on SN platforms
      [IA64] Increase max node count on SN platforms
      [IA64] Increase max node count on SN platforms

Kenji Kaneshige:
      [IA64] Ignore disabled Local SAPIC Affinity Structure in SRAT

Prarit Bhargava:
      [IA64] Tollhouse HP: IA64 arch changes

Russ Anderson:
      [IA64] MCA recovery: kernel context recovery table

