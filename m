From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Oct 2004 03:58:51 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200410270358.i9R3wpS27056@unix-os.sc.intel.com>
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

 arch/ia64/ia32/elfcore32.h           |    1 
 arch/ia64/kernel/efi.c               |   35 ++++++++----
 arch/ia64/kernel/perfmon.c           |   32 ++++-------
 arch/ia64/mm/discontig.c             |    4 -
 arch/ia64/sn/kernel/idle.c           |   12 +---
 arch/ia64/sn/kernel/io_init.c        |    4 +
 arch/ia64/sn/kernel/irq.c            |    8 +-
 arch/ia64/sn/kernel/mca.c            |   28 +++++-----
 arch/ia64/sn/kernel/setup.c          |   51 ++++++++++++++++--
 arch/ia64/sn/kernel/sn2/sn2_smp.c    |   19 ++++---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c  |   51 ++++++++----------
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c |    3 -
 drivers/ide/pci/sgiioc4.c            |   12 ++--
 drivers/serial/sn_console.c          |   79 +----------------------------
 include/asm-ia64/pgtable.h           |    8 +-
 include/asm-ia64/sn/intr.h           |    2 
 include/asm-ia64/sn/nodepda.h        |   10 +++
 include/asm-ia64/sn/sn2/sn_hwperf.h  |   10 +++
 include/asm-ia64/sn/sn_cpuid.h       |   95 ++++++++++-------------------------
 include/asm-ia64/sn/sn_sal.h         |   32 +++++++++++
 20 files changed, 239 insertions(+), 257 deletions(-)

through these ChangeSets:

<tony.luck@intel.com> (04/10/26 1.2185.1.12)
   [IA64] Need <asm/meminit.h> for GRANULEROUNDDOWN
   
   Alex's change for mem=/max_addr= now needs to include meminit.h
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/26 1.2185.1.11)
   [IA64-SGI] only allocate irq if the device can interrupt
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Acked-by: Mike Habeck <habeck@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (04/10/26 1.2185.1.10)
   [IA64-SGI] Delete simulator support from SN idle loop
   
   Delete hack for supporting simulator for SN platforms. This capability
   has been moved into the simulator environment & is no longer required
   in the kernel.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (04/10/26 1.2185.1.9)
   [IA64-SGI] Update asm-ia64/sn/sn_cpuid.h macros
   
   SGI SN code currently makes assumptions about the bits in the LID
   register. These assumptions do not conform to the bit specifications
   from Intel. For example, SN currently assumes that bits [28:16] of
   the LID contain the physical node ID of a node.
    
   This patch eliminates these assumptions. A SAL call is now used to translate
   LID values to the NASID/subnode/slice values that are needed for SN
   platforms. The results of the SAL call are saved in the SN nodepda.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (04/10/26 1.2185.1.8)
   [IA64] Delete obsolete code from SGI console driver
   
   Delete obsolete code that supports the SGI simulator. This
   support code has been moved into the fakeprom and is no
   longer required in the kernel.
    
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jasonuhl@sgi.com> (04/10/26 1.2185.1.7)
   [IA64] fix pgtable.h comments
   
   Remove some statements from comments in <asm-ia64/pgtable.h> whose
   correctness is page size dependent ... and based on using an 8k
   page size, which almost nobody actually uses.
    
   Signed-off-by: Jason Uhlenkott <jasonuhl@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kaos@sgi.com> (04/10/26 1.2185.1.6)
   [IA64] Correct references from text/data to init.text/data.
   
   These errors were found by 'make buildcheck'.
    
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<markgw@sgi.com> (04/10/26 1.2185.1.5)
   [IA64] sn_hwperf correctly handle bricks with multiple slabs
   
   The procfs handler for /proc/sgi_sn/sn_topology did
   not correctly handle multiple slabs in the same brick,
   e.g. a brick containing a compute node and an ionode.
    
   Signed-off-by: Mark Goodwin <markgw@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kaos@sgi.com> (04/10/26 1.2185.1.4)
   [IA64] Correct bit test for salinfo oem decode
   
   The valid.oem_data bit is in different positions in each section.  Make
   the test for valid oem data a section specific test.
    
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<eranian@hpl.hp.com> (04/10/26 1.2185.1.3)
   [IA64] misc small patches for perfmon
   
   change-log:
   - update comment for pfm_do_fasync()
   - fix return value for pfm_smpl_buffer_alloc(). Now
     return ENOMEM instead of EAGAIN when buffer too big
     for RLIMIT_MEMLOCK.
   - added missing vm_pgoff initialization in pfm_smpl_buffer_alloc()
   - added flags tro debug print in pfm_write_pmcs
   - added seed and mask to debug print in pfm_write_pmds
   - shorten some of the debug prints
   - remove bogus sanity check from pfm_save_regs() in SMP.
     this could cause invalid PMU state restore
   
   signed-off-by: eranian@hpl.hp.com
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<alex.williamson@hp.com> (04/10/26 1.2185.1.2)
   [IA64] efi.c: fix mem= & max_addr   
   With this change, there's some extra fuzz introduced that a max_addr
   specification will get rounded down to a granule boundary and memory
   quantity, when using mem=, will be within a granule size of the
   requested amount.  Let me know if anyone finds more problems with it.
   
   Signed-off-by: Alex Williamson <alex.williamson@hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<akpm@osdl.org> (04/10/26 1.2000.10.2)
   [IA64] Need <asm/uaccess.h> for KERNEL_DS & set_fs() definitions.
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

