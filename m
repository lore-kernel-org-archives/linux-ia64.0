From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 28 Sep 2004 18:34:14 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409281834.i8SIYEA08022@unix-os.sc.intel.com>
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

 arch/ia64/configs/sn2_defconfig   |    4 
 arch/ia64/configs/tiger_defconfig | 1028 ++++++++++++++++++++++++++++++++++++++
 arch/ia64/configs/zx1_defconfig   |  662 ++++++++++++------------
 arch/ia64/mm/contig.c             |    4 
 arch/ia64/mm/discontig.c          |    4 
 include/asm-ia64/mmzone.h         |    6 
 include/asm-ia64/page.h           |   19 
 7 files changed, 1385 insertions(+), 342 deletions(-)

through these ChangeSets:

<tony.luck@intel.com> (04/09/28 1.1955)
   [IA64] add default config file for intel tiger
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<Nanhai.zou@intel.com> (04/09/28 1.1954)
   [IA64] discontig.c: remove max_gap and related call to efi_memmap_walk
   
   max_gap is not used in discontig.c.
   This patch is to remove it and the related efi_memmap_walk.
    
   Signed-off-by: Zou Nan hai <Nanhai.zou@intel.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/09/28 1.1953)
   [IA64] zx1_defconfig: bring zx1_defconfig up to date

<jbarnes@sgi.com> (04/09/28 1.1952)
   [IA64] sn2_defconfig: disable hotplug cpu
   
   Looks like there are some bugs that won't be fixed before 2.6.9 in the
   scheduling domain code wrt HOTPLUG_CPU, so I'm disabling it in sn2_defconfig
   (we don't support CPU hotplug just yet anyway).
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/09/28 1.1951)
   [IA64] cleanup contig/discontig/virt_mem_map macros
   
   I got this patch from Zou Nan hai to resolve the problem that
   Andrew Morton has been having booting his ia64 system.  The code
   is quite a bit cleaner as he has reduced the number of different
   definitions of pfn_valid/page_to_pfn/pfn_to_page, and left the
   only remaining ones next to each other in page.h ... so this
   should be easier to maintain going forward.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

