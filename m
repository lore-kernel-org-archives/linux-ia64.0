From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 22 Sep 2004 23:14:53 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409222314.i8MNErR05567@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.9

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/common/sba_iommu.c |   80 +++++++++++++++++++++++++++++++++++++++-
 arch/ia64/kernel/acpi.c         |   67 +++++++++++++++++++++++++++++++++
 arch/ia64/kernel/iosapic.c      |   55 ++++++++++++++++++++++++++-
 arch/ia64/mm/discontig.c        |   35 ++++++++++++-----
 arch/ia64/pci/pci.c             |    5 ++
 include/asm-ia64/iosapic.h      |    3 +
 6 files changed, 230 insertions(+), 15 deletions(-)

through these ChangeSets:

<alex.williamson@hp.com> (04/09/09 1.1803.153.3)
   [IA64] iosapic.h, pci.c, iosapic.c, acpi.c: iosapic NUMA interrupt locality
   
   This patch associates IOSAPICs with NUMA nodes such that interrupts
   gets assigned to a reasonably good default CPU.  The patch does not
   depend on the pxm_to_nid_map fixup, but results will be strange in some
   configurations without it.  This should work on any NUMA box that
   exposes IOSAPICs with _MAT & _PXM methods, but it's only been tested on
   an rx8620.  There should be no change in behavior for boxes that don't
   export both of these in ACPI namespace.
    
   Signed-off-by: Alex Williamson <alex.williamson@hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<alex.williamson@hp.com> (04/09/09 1.1803.153.2)
   [IA64] sba_iommu.c: sba_iommu NUMA locality
   
   This patch adds NUMA locality info to sba_iommu, allowing coherent
   DMA mappings to be allocated from the node nearest to the I/O.  This
   patch isn't dependent on the previous pxm_to_nid_map fixup, but may be
   sub-optimal in some cases without it.  Thanks
    
   Signed-off-by: Alex Williamson <alex.williamson@hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<alex.williamson@hp.com> (04/09/09 1.1803.153.1)
   [IA64] discontig.c: fixup pxm_to_nid_map
   
   I'd like to be able to use pxm_to_nid_map in several places to
   discover proximity domain to node id associations.  Unfortunately, after
   reassign_cpu_only_nodes() plays with the node space, the pxm_to_nid_map
   doesn't necessarily reflect reality.  This fixes up the table so it's
   still valid.  Note that nid_to_pxm_map is still potentially broken, but
   has a one-to-many problem if the above function combines several
   proximity domains into a single node.  Thanks to Bob Picco for the base
   patch.
    
   Signed-off-by: Alex Williamson <alex.williamson@hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

