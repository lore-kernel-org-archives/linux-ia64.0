From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Mar 2006 18:42:52 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200603301842.k2UIgquM013762@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/gate.lds.S         |    1 
 arch/ia64/kernel/iosapic.c          |  279 +++++++++++++++++++++---------------
 arch/ia64/kernel/vmlinux.lds.S      |   18 +-
 arch/ia64/mm/init.c                 |    8 -
 arch/ia64/mm/ioremap.c              |    6 
 arch/ia64/mm/tlb.c                  |   12 -
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    8 -
 include/asm-ia64/asmmacro.h         |    4 
 8 files changed, 206 insertions(+), 130 deletions(-)

Bjorn Helgaas:
      [IA64] ioremap() should prefer WB over UC

Chen, Kenneth W:
      [IA64] optimize flush_tlb_range on large numa box

Dean Roe:
      [IA64-SGI] fix for-loop in sn_hwperf_geoid_to_cnode()

hawkes@sgi.com:
      [IA64-SGI] sn_hwperf use of num_online_cpus()

Jes Sorensen:
      [IA64] Add __mca_table to the DISCARD list in gate.lds

Russ Anderson:
      [IA64] Move __mca_table out of the __init section

Satoru Takeuchi:
      [IA64] correct some messages and fixes some minor things
      [IA64] simplify some condition checks in iosapic_check_gsi_range

Zhang, Yanmin:
      [IA64] lazy_mmu_prot_update needs to be aware of huge pages
