From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 04 Nov 2004 00:22:30 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200411040022.iA40MUF29941@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.10

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/configs/generic_defconfig     | 1123 --------------------------------
 arch/ia64/configs/sn2_defconfig         |   58 +
 arch/ia64/configs/tiger_defconfig       |   59 +
 arch/ia64/defconfig                     |  651 +++++++++---------
 arch/ia64/hp/common/sba_iommu.c         |    4 
 arch/ia64/kernel/time.c                 |   17 
 arch/ia64/pci/pci.c                     |   90 +-
 arch/ia64/sn/kernel/io_init.c           |    4 
 arch/ia64/sn/kernel/setup.c             |   25 
 arch/ia64/sn/pci/pcibr/pcibr_dma.c      |    4 
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    2 
 include/asm-ia64/pci.h                  |    9 
 include/asm-ia64/sn/arch.h              |   11 
 include/asm-ia64/sn/sn_sal.h            |    3 
 include/asm-ia64/sn/types.h             |    4 
 15 files changed, 510 insertions(+), 1554 deletions(-)

through these ChangeSets:

<nigel.croxon@hp.com> (04/11/03 1.2453)
   [IA64-HP] Fix for bits_wanted in sba_iommu.c
   
   bits_wanted is expanded to bytes using the wrong shift value
   (when iovp_shift != PAGE_SHIFT), resulting in an explosion of
   used iommu resources.
   
   This potentially results in mistakenly running out of DMA mapping
   resources when the system is under *heavy* i/o load.
   
   Signed-off-by: Nigel Croxon <nigel.croxon@hp.com>
   Signed-off by: Alex Williamson <alex.williamson@hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/11/03 1.2452)
   [IA64-SGI] Do not disable interrupts in ia64_sn_plat_specific_err_print
   
   ia64_sn_plat_specific_err_print() ends up calling vfree() which
   requires IPI which can deadlock if interrupts are disabled.  Do not
   disable interrupts in ia64_sn_plat_specific_err_print().
    
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/11/03 1.2451)
   [IA64] implement pcibios_resource_to_bus and pcibios_bus_to_resource
   
   Patch from Matthew Wilcox:
     Since some ia64 platforms have non-identity-mapped PCI busses, we need
     to implement pcibios_resource_to_bus and pcibios_bus_to_resource.
     Also clean up some >80 column comments and delete an unnecessary parameter
     to pcibios_fixup_device_resources().
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/11/02 1.2424.1.47)
   [IA64] promote configs/generic_defconfig to defconfig
   
   arch/ia64/defconfig should be one that is usable by the
   largest cross-section of the ia64 community.  Replace
   old version with an updated version of generic_defconfig.
   Change suggested by Jesse Barnes.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/11/02 1.2424.1.46)
   [IA64] tiger_defconfig update for 2.6.10-rc1
   
   Enable MCA_RECOVERY, TMPFS_XATTR, and other
   miscellaneous config options.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/11/02 1.2424.1.45)
   [IA64-SGI] update sn2_defconfig
   
   Update sn2_defconfig to reflect some new options:
   o enable MCA debugging of more than just TLB errors
   o enable tmpfs xattr support
   o enable kernel userspace events
   o defaults for other new options
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<t-kochi@bq.jp.nec.com> (04/11/02 1.2424.1.44)
   [IA64] cleanup CPU drift print
   
   This patch skips printing drift information of a cpu where
   ITC drift information is not supported by SAL.  Without this,
   bogus value (-1ppm) is printed on boot.
    
    CPU 1: base freq 0.007MHz, ITC ratio/2, ITC freq00.035MHz+/--1ppm
     
   is now
      
    CPU 1: base freq 0.007MHz, ITC ratio/2, ITC freq00.035MHz
       
   Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (04/11/02 1.2424.1.43)
   [IA64-SGI] Delete unused variable (master_node_bedrock_address)
   
   Delete master_node_bedrock_address. It is no longer needed.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/11/02 1.2424.1.42)
   [IA64-SGI] move nic_t to asm/sn/types.h
   
   Somehow nic_t crept into arch.h.  Move it to types.h where it belongs (it
   depends on u64, so pull in linux/types.h too).
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/11/02 1.2424.1.41)
   [IA64-SGI] remove redundant macros
   
   This patch removes some redundant nasid conversion macros from arch.h and
   updates callers to use the version they were defined to instead.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/11/02 1.2424.1.40)
   [IA64-SGI] remove duplicate INVALID_* defines from arch.h
   
   When I did the sparse stuff, I noticed some duplicate INVALID_* defines.  This
   patch removes one set of them and adds the proper include file to sn_sal.h.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

