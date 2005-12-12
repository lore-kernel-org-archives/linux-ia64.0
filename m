From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 12 Dec 2005 18:20:17 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200512121820.jBCIKHL8010574@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Last few fixes for ia64 for 2.6.15.  Please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/configs/sn2_defconfig        |  152 +++++++++++++++++++++++---------
 arch/ia64/configs/tiger_defconfig      |   74 ++++++++++-----
 arch/ia64/ia32/binfmt_elf32.c          |    2 
 arch/ia64/ia32/ia32priv.h              |    1 
 arch/ia64/kernel/process.c             |    5 -
 arch/ia64/kernel/salinfo.c             |    2 
 arch/ia64/mm/discontig.c               |    4 
 arch/ia64/sn/kernel/io_init.c          |  153 ++++++++++++++++++++++++++++-----
 arch/ia64/sn/kernel/sn2/ptc_deadlock.S |    8 +
 include/asm-ia64/ia32.h                |    2 
 include/asm-ia64/local.h               |    4 
 include/asm-ia64/sn/pcidev.h           |   20 +++-
 include/asm-ia64/spinlock.h            |   12 ++
 13 files changed, 336 insertions(+), 103 deletions(-)

Christoph Lameter:
      [IA64] Fix missing parameter for local_add/sub

Jack Steiner:
      [IA64] Limit the maximum NODEDATA_ALIGN() offset
      [IA64-SGI] Fix SN PTC deadlock recovery

John Keller:
      [IA64-SGI] altix: pci_window fixup

Keith Owens:
      [IA64] Allow salinfo_decode to detect signals on read
      [IA64] Define an ia64 version of __raw_read_trylock

Robin Holt:
      [IA64] Updates to the sn2_defconfig for 2.6.15.
      [IA64] Change SET_PERSONALITY to comply with comment in binfmt_elf.c.

Tony Luck:
      [IA64] refresh tiger_defconfig ready for 2.6.15

Full "git whatchanged -p" output follows:

diff-tree bf7ececa9b68f4720f1ce344f442435660bcdae7 (from f64fa6772aa874e5cad02a9d87e6b0d99ced3d48)
Author: Keith Owens <kaos@sgi.com>
Date:   Sat Dec 10 14:24:28 2005 +1100

    [IA64] Define an ia64 version of __raw_read_trylock
    
    IA64 is using the generic version of __raw_read_trylock, which always
    waits for the lock to be free instead of returning when the lock is in
    use.  Define an ia64 version of __raw_read_trylock which behaves
    correctly, and drop the generic one.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/spinlock.h b/include/asm-ia64/spinlock.h
index 5b78611..0c91a76 100644
--- a/include/asm-ia64/spinlock.h
+++ b/include/asm-ia64/spinlock.h
@@ -201,6 +201,16 @@ static inline void __raw_write_unlock(ra
 
 #endif /* !ASM_SUPPORTED */
 
-#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
+static inline int __raw_read_trylock(raw_rwlock_t *x)
+{
+	union {
+		raw_rwlock_t lock;
+		__u32 word;
+	} old, new;
+	old.lock = new.lock = *x;
+	old.lock.write_lock = new.lock.write_lock = 0;
+	++new.lock.read_counter;
+	return (u32)ia64_cmpxchg4_acq((__u32 *)(x), new.word, old.word) = old.word;
+}
 
 #endif /*  _ASM_IA64_SPINLOCK_H */

diff-tree f64fa6772aa874e5cad02a9d87e6b0d99ced3d48 (from 590711b7dd731bb04e7892c0451566d788985e79)
Author: Christoph Lameter <clameter@engr.sgi.com>
Date:   Wed Dec 7 11:24:42 2005 -0800

    [IA64] Fix missing parameter for local_add/sub
    
    Local add/sub macros need to have a parameter to specify
    the addend/subtrahend respectively.
    
    Signed-off-by: Christoph Lameter <clameter@sgi.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/local.h b/include/asm-ia64/local.h
index 1dbd584..dc51909 100644
--- a/include/asm-ia64/local.h
+++ b/include/asm-ia64/local.h
@@ -17,8 +17,8 @@ typedef struct {
 #define local_set(l, i)	atomic64_set(&(l)->val, i)
 #define local_inc(l)	atomic64_inc(&(l)->val)
 #define local_dec(l)	atomic64_dec(&(l)->val)
-#define local_add(l)	atomic64_add(&(l)->val)
-#define local_sub(l)	atomic64_sub(&(l)->val)
+#define local_add(i, l)	atomic64_add((i), &(l)->val)
+#define local_sub(i, l)	atomic64_sub((i), &(l)->val)
 
 /* Non-atomic variants, i.e., preemption disabled and won't be touched in interrupt, etc.  */
 

diff-tree 590711b7dd731bb04e7892c0451566d788985e79 (from bd1d6e2451f2bb0132416fda4d129c4f57a827bc)
Author: Jack Steiner <steiner@sgi.com>
Date:   Tue Dec 6 08:05:24 2005 -0600

    [IA64-SGI] Fix SN PTC deadlock recovery
    
    The patch that added support for a new platform chipset (shub2) broke
    PTC deadlock recovery on older versions of the chipset. (PTCs are the
    SN platform-specific method for doing a global TLB purge). This
    patch fixes deadlock recovery so that it works on both the old & new
    chipsets.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/sn2/ptc_deadlock.S b/arch/ia64/sn/kernel/sn2/ptc_deadlock.S
index 3fa9506..bebbcc4 100644
--- a/arch/ia64/sn/kernel/sn2/ptc_deadlock.S
+++ b/arch/ia64/sn/kernel/sn2/ptc_deadlock.S
@@ -39,9 +39,13 @@ sn2_ptc_deadlock_recovery_core:
 	mov	r8=r0
 
 1:
+	cmp.ne  p8,p9=r0,ptc1		// Test for shub type (ptc1 non-null on shub1)
+					// p8 = 1 if shub1, p9 = 1 if shub2
+
 	add	scr2=ALIAS_OFFSET,piowc	// Address of WRITE_STATUS alias register 
-	;;
-	ld8.acq	scr1=[scr2];;
+	mov	scr1=7;;		// Clear DEADLOCK, WRITE_ERROR, MULTI_WRITE_ERROR
+(p8)	st8.rel	[scr2]=scr1;;
+(p9)	ld8.acq	scr1=[scr2];;
 
 5:	ld8.acq	scr1=[piowc];;		// Wait for PIOs to complete.
 	hint	@pause

diff-tree bd1d6e2451f2bb0132416fda4d129c4f57a827bc (from acb7f67280128a9ddaa756ff10212391d28caec4)
Author: Robin Holt <holt@sgi.com>
Date:   Mon Dec 5 20:02:31 2005 -0600

    [IA64] Change SET_PERSONALITY to comply with comment in binfmt_elf.c.
    
    We have a customer application which trips a bug.  The problem arises
    when a driver attempts to call do_munmap on an area which is mapped, but
    because current->thread.task_size has been set to 0xC0000000, the call
    to do_munmap fails thinking it is an unmap beyond the user's address
    space.
    
    The comment in fs/binfmt_elf.c in load_elf_library() before the call
    to SET_PERSONALITY() indicates that task_size must not be changed for
    the running application until flush_thread, but is for ia64 executing
    ia32 binaries.
    
    This patch moves the setting of task_size from SET_PERSONALITY() to
    flush_thread() as indicated.  The customer application no longer is able
    to trip the bug.
    
    Signed-off-by: Robin Holt <holt@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/ia32/binfmt_elf32.c b/arch/ia64/ia32/binfmt_elf32.c
index a7280d9..4e7a6a1 100644
--- a/arch/ia64/ia32/binfmt_elf32.c
+++ b/arch/ia64/ia32/binfmt_elf32.c
@@ -261,8 +261,6 @@ elf32_set_personality (void)
 {
 	set_personality(PER_LINUX32);
 	current->thread.map_base  = IA32_PAGE_OFFSET/3;
-	current->thread.task_size = IA32_PAGE_OFFSET;	/* use what Linux/x86 uses... */
-	set_fs(USER_DS);				/* set addr limit for new TASK_SIZE */
 }
 
 static unsigned long
diff --git a/arch/ia64/ia32/ia32priv.h b/arch/ia64/ia32/ia32priv.h
index e3e9290..68ceb4e 100644
--- a/arch/ia64/ia32/ia32priv.h
+++ b/arch/ia64/ia32/ia32priv.h
@@ -305,7 +305,6 @@ struct old_linux32_dirent {
 #define ELF_DATA	ELFDATA2LSB
 #define ELF_ARCH	EM_386
 
-#define IA32_PAGE_OFFSET	0xc0000000
 #define IA32_STACK_TOP		IA32_PAGE_OFFSET
 #define IA32_GATE_OFFSET	IA32_PAGE_OFFSET
 #define IA32_GATE_END		IA32_PAGE_OFFSET + PAGE_SIZE
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 2e33665..a4da715 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -721,8 +721,11 @@ flush_thread (void)
 	/* drop floating-point and debug-register state if it exists: */
 	current->thread.flags &= ~(IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALID);
 	ia64_drop_fpu(current);
-	if (IS_IA32_PROCESS(ia64_task_regs(current)))
+	if (IS_IA32_PROCESS(ia64_task_regs(current))) {
 		ia32_drop_partial_page_list(current);
+		current->thread.task_size = IA32_PAGE_OFFSET;
+		set_fs(USER_DS);
+	}
 }
 
 /*
diff --git a/include/asm-ia64/ia32.h b/include/asm-ia64/ia32.h
index 8e746b2..f8044a1 100644
--- a/include/asm-ia64/ia32.h
+++ b/include/asm-ia64/ia32.h
@@ -13,6 +13,8 @@
 
 # ifdef CONFIG_IA32_SUPPORT
 
+#define IA32_PAGE_OFFSET	0xc0000000
+
 extern void ia32_cpu_init (void);
 extern void ia32_mem_init (void);
 extern void ia32_gdt_init (void);

diff-tree acb7f67280128a9ddaa756ff10212391d28caec4 (from 3ec829b6895092b0686254c315f42642b4a07efc)
Author: Jack Steiner <steiner@sgi.com>
Date:   Mon Dec 5 13:56:50 2005 -0600

    [IA64] Limit the maximum NODEDATA_ALIGN() offset
    
    The per-node data structures are allocated with strided offsets that are a
    function of the node number. This prevents excessive cache-aliasing from
    occurring.
    
    On systems with a large number of nodes, the strided offset becomes
    too large. This patch restricts the maximum offset to 32MB. This is far larger
    than the size of any current L3 cache.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 0f776b0..c87d6d1 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -50,8 +50,10 @@ static nodemask_t memory_less_mask __ini
  * To prevent cache aliasing effects, align per-node structures so that they
  * start at addresses that are strided by node number.
  */
+#define MAX_NODE_ALIGN_OFFSET	(32 * 1024 * 1024)
 #define NODEDATA_ALIGN(addr, node)						\
-	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
+	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + 				\
+	     (((node)*PERCPU_PAGE_SIZE) & (MAX_NODE_ALIGN_OFFSET - 1)))
 
 /**
  * build_node_maps - callback to setup bootmem structs for each node

diff-tree 3ec829b6895092b0686254c315f42642b4a07efc (from 3e356b2660eda9da7776144cbc0a038c93dcb335)
Author: John Keller <jpk@sgi.com>
Date:   Tue Nov 29 16:36:32 2005 -0600

    [IA64-SGI] altix: pci_window fixup
    
    Altix only patch to add fixup code that sets up
    pci_controller->window. This code is a temporary
    fix until ACPI support on Altix is added.
    
    Also, corrects the usage of pci_dev->sysdata,
    which had previously been used to reference
    platform specific device info, to now point to
    a pci_controller struct.
    
    Signed-off-by: John Keller <jpk@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 05e4ea8..318087e 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/bootmem.h>
@@ -147,6 +147,24 @@ sal_get_pcidev_info(u64 segment, u64 bus
 }
 
 /*
+ * sn_pcidev_info_get() - Retrieve the pcidev_info struct for the specified
+ *			  device.
+ */
+inline struct pcidev_info *
+sn_pcidev_info_get(struct pci_dev *dev)
+{
+	struct pcidev_info *pcidev;
+
+	list_for_each_entry(pcidev,
+			    &(SN_PCI_CONTROLLER(dev)->pcidev_info), pdi_list) {
+		if (pcidev->pdi_linux_pcidev = dev) {
+			return pcidev;
+		}
+	}
+	return NULL;
+}
+
+/*
  * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for 
  *	each node in the system.
  */
@@ -229,6 +247,50 @@ static void sn_fixup_ionodes(void)
 
 }
 
+/*
+ * sn_pci_window_fixup() - Create a pci_window for each device resource.
+ *			   Until ACPI support is added, we need this code
+ *			   to setup pci_windows for use by
+ *			   pcibios_bus_to_resource(),
+ *			   pcibios_resource_to_bus(), etc.
+ */
+static void
+sn_pci_window_fixup(struct pci_dev *dev, unsigned int count,
+		    int64_t * pci_addrs)
+{
+	struct pci_controller *controller = PCI_CONTROLLER(dev->bus);
+	unsigned int i;
+	unsigned int idx;
+	unsigned int new_count;
+	struct pci_window *new_window;
+
+	if (count = 0)
+		return;
+	idx = controller->windows;
+	new_count = controller->windows + count;
+	new_window = kcalloc(new_count, sizeof(struct pci_window), GFP_KERNEL);
+	if (new_window = NULL)
+		BUG();
+	if (controller->window) {
+		memcpy(new_window, controller->window,
+		       sizeof(struct pci_window) * controller->windows);
+		kfree(controller->window);
+	}
+
+	/* Setup a pci_window for each device resource. */
+	for (i = 0; i <= PCI_ROM_RESOURCE; i++) {
+		if (pci_addrs[i] = -1)
+			continue;
+
+		new_window[idx].offset = dev->resource[i].start - pci_addrs[i];
+		new_window[idx].resource = dev->resource[i];
+		idx++;
+	}
+
+	controller->windows = new_count;
+	controller->window = new_window;
+}
+
 void sn_pci_unfixup_slot(struct pci_dev *dev)
 {
 	struct pci_dev *host_pci_dev = SN_PCIDEV_INFO(dev)->host_pci_dev;
@@ -246,21 +308,23 @@ void sn_pci_unfixup_slot(struct pci_dev 
  */
 void sn_pci_fixup_slot(struct pci_dev *dev)
 {
+	unsigned int count = 0;
 	int idx;
 	int segment = pci_domain_nr(dev->bus);
 	int status = 0;
 	struct pcibus_bussoft *bs;
  	struct pci_bus *host_pci_bus;
  	struct pci_dev *host_pci_dev;
+	struct pcidev_info *pcidev_info;
+	int64_t pci_addrs[PCI_ROM_RESOURCE + 1];
  	struct sn_irq_info *sn_irq_info;
  	unsigned long size;
  	unsigned int bus_no, devfn;
 
 	pci_dev_get(dev); /* for the sysdata pointer */
-	dev->sysdata = kmalloc(sizeof(struct pcidev_info), GFP_KERNEL);
-	if (SN_PCIDEV_INFO(dev) <= 0)
+	pcidev_info = kzalloc(sizeof(struct pcidev_info), GFP_KERNEL);
+	if (pcidev_info <= 0)
 		BUG();		/* Cannot afford to run out of memory */
-	memset(SN_PCIDEV_INFO(dev), 0, sizeof(struct pcidev_info));
 
 	sn_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
 	if (sn_irq_info <= 0)
@@ -270,22 +334,34 @@ void sn_pci_fixup_slot(struct pci_dev *d
 	/* Call to retrieve pci device information needed by kernel. */
 	status = sal_get_pcidev_info((u64) segment, (u64) dev->bus->number, 
 				     dev->devfn,
-				     (u64) __pa(SN_PCIDEV_INFO(dev)),
+				     (u64) __pa(pcidev_info),
 				     (u64) __pa(sn_irq_info));
 	if (status)
 		BUG(); /* Cannot get platform pci device information */
 
+	/* Add pcidev_info to list in sn_pci_controller struct */
+	list_add_tail(&pcidev_info->pdi_list,
+		      &(SN_PCI_CONTROLLER(dev->bus)->pcidev_info));
+
 	/* Copy over PIO Mapped Addresses */
 	for (idx = 0; idx <= PCI_ROM_RESOURCE; idx++) {
 		unsigned long start, end, addr;
 
-		if (!SN_PCIDEV_INFO(dev)->pdi_pio_mapped_addr[idx])
+		if (!pcidev_info->pdi_pio_mapped_addr[idx]) {
+			pci_addrs[idx] = -1;
 			continue;
+		}
 
 		start = dev->resource[idx].start;
 		end = dev->resource[idx].end;
 		size = end - start;
-		addr = SN_PCIDEV_INFO(dev)->pdi_pio_mapped_addr[idx];
+		if (size = 0) {
+			pci_addrs[idx] = -1;
+			continue;
+		}
+		pci_addrs[idx] = start;
+		count++;
+		addr = pcidev_info->pdi_pio_mapped_addr[idx];
 		addr = ((addr << 4) >> 4) | __IA64_UNCACHED_OFFSET;
 		dev->resource[idx].start = addr;
 		dev->resource[idx].end = addr + size;
@@ -294,23 +370,27 @@ void sn_pci_fixup_slot(struct pci_dev *d
 		else
 			dev->resource[idx].parent = &iomem_resource;
 	}
+	/* Create a pci_window in the pci_controller struct for
+	 * each device resource.
+	 */
+	if (count > 0)
+		sn_pci_window_fixup(dev, count, pci_addrs);
 
 	/*
 	 * Using the PROMs values for the PCI host bus, get the Linux
  	 * PCI host_pci_dev struct and set up host bus linkages
  	 */
 
- 	bus_no = (SN_PCIDEV_INFO(dev)->pdi_slot_host_handle >> 32) & 0xff;
- 	devfn = SN_PCIDEV_INFO(dev)->pdi_slot_host_handle & 0xffffffff;
+	bus_no = (pcidev_info->pdi_slot_host_handle >> 32) & 0xff;
+	devfn = pcidev_info->pdi_slot_host_handle & 0xffffffff;
  	host_pci_bus = pci_find_bus(segment, bus_no);
  	host_pci_dev = pci_get_slot(host_pci_bus, devfn);
 
-	SN_PCIDEV_INFO(dev)->host_pci_dev = host_pci_dev;
-	SN_PCIDEV_INFO(dev)->pdi_host_pcidev_info -	    					SN_PCIDEV_INFO(host_pci_dev);
-	SN_PCIDEV_INFO(dev)->pdi_linux_pcidev = dev;
+	pcidev_info->host_pci_dev = host_pci_dev;
+	pcidev_info->pdi_linux_pcidev = dev;
+	pcidev_info->pdi_host_pcidev_info = SN_PCIDEV_INFO(host_pci_dev);
 	bs = SN_PCIBUS_BUSSOFT(dev->bus);
-	SN_PCIDEV_INFO(dev)->pdi_pcibus_info = bs;
+	pcidev_info->pdi_pcibus_info = bs;
 
 	if (bs && bs->bs_asic_type < PCIIO_ASIC_MAX_TYPES) {
 		SN_PCIDEV_BUSPROVIDER(dev) = sn_pci_provider[bs->bs_asic_type];
@@ -320,11 +400,11 @@ void sn_pci_fixup_slot(struct pci_dev *d
 
 	/* Only set up IRQ stuff if this device has a host bus context */
 	if (bs && sn_irq_info->irq_irq) {
-		SN_PCIDEV_INFO(dev)->pdi_sn_irq_info = sn_irq_info;
-		dev->irq = SN_PCIDEV_INFO(dev)->pdi_sn_irq_info->irq_irq;
+		pcidev_info->pdi_sn_irq_info = sn_irq_info;
+		dev->irq = pcidev_info->pdi_sn_irq_info->irq_irq;
 		sn_irq_fixup(dev, sn_irq_info);
 	} else {
-		SN_PCIDEV_INFO(dev)->pdi_sn_irq_info = NULL;
+		pcidev_info->pdi_sn_irq_info = NULL;
 		kfree(sn_irq_info);
 	}
 }
@@ -338,6 +418,7 @@ void sn_pci_controller_fixup(int segment
 	int status = 0;
 	int nasid, cnode;
 	struct pci_controller *controller;
+	struct sn_pci_controller *sn_controller;
 	struct pcibus_bussoft *prom_bussoft_ptr;
 	struct hubdev_info *hubdev_info;
 	void *provider_soft = NULL;
@@ -349,10 +430,15 @@ void sn_pci_controller_fixup(int segment
 		return;		/*bus # does not exist */
 	prom_bussoft_ptr = __va(prom_bussoft_ptr);
 
- 	controller = kzalloc(sizeof(struct pci_controller), GFP_KERNEL);
+	/* Allocate a sn_pci_controller, which has a pci_controller struct
+	 * as the first member.
+	 */
+	sn_controller = kzalloc(sizeof(struct sn_pci_controller), GFP_KERNEL);
+	if (!sn_controller)
+		BUG();
+	INIT_LIST_HEAD(&sn_controller->pcidev_info);
+	controller = &sn_controller->pci_controller;
 	controller->segment = segment;
- 	if (!controller)
- 		BUG();
 
 	if (bus = NULL) {
  		bus = pci_scan_bus(busnum, &pci_root_ops, controller);
@@ -390,6 +476,29 @@ void sn_pci_controller_fixup(int segment
 	}
 
 	/*
+	 * Setup pci_windows for legacy IO and MEM space.
+	 * (Temporary until ACPI support is in place.)
+	 */
+	controller->window = kcalloc(2, sizeof(struct pci_window), GFP_KERNEL);
+	if (controller->window = NULL)
+		BUG();
+	controller->window[0].offset = prom_bussoft_ptr->bs_legacy_io;
+	controller->window[0].resource.name = "legacy_io";
+	controller->window[0].resource.flags = IORESOURCE_IO;
+	controller->window[0].resource.start = prom_bussoft_ptr->bs_legacy_io;
+	controller->window[0].resource.end +	    controller->window[0].resource.start + 0xffff;
+	controller->window[0].resource.parent = &ioport_resource;
+	controller->window[1].offset = prom_bussoft_ptr->bs_legacy_mem;
+	controller->window[1].resource.name = "legacy_mem";
+	controller->window[1].resource.flags = IORESOURCE_MEM;
+	controller->window[1].resource.start = prom_bussoft_ptr->bs_legacy_mem;
+	controller->window[1].resource.end +	    controller->window[1].resource.start + (1024 * 1024) - 1;
+	controller->window[1].resource.parent = &iomem_resource;
+	controller->windows = 2;
+
+	/*
 	 * Generic bus fixup goes here.  Don't reference prom_bussoft_ptr
 	 * after this point.
 	 */
@@ -421,7 +530,7 @@ void sn_pci_controller_fixup(int segment
 
 error_return:
 
-	kfree(controller);
+	kfree(sn_controller);
 	return;
 }
 
@@ -434,7 +543,7 @@ void sn_bus_store_sysdata(struct pci_dev
 		dev_dbg(dev, "%s: out of memory!\n", __FUNCTION__);
 		return;
 	}
-	element->sysdata = dev->sysdata;
+	element->sysdata = SN_PCIDEV_INFO(dev);
 	list_add(&element->entry, &sn_sysdata_list);
 }
 
diff --git a/include/asm-ia64/sn/pcidev.h b/include/asm-ia64/sn/pcidev.h
index 49711d0..f65d222 100644
--- a/include/asm-ia64/sn/pcidev.h
+++ b/include/asm-ia64/sn/pcidev.h
@@ -3,15 +3,27 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 #ifndef _ASM_IA64_SN_PCI_PCIDEV_H
 #define _ASM_IA64_SN_PCI_PCIDEV_H
 
 #include <linux/pci.h>
 
-#define SN_PCIDEV_INFO(pci_dev) \
-        ((struct pcidev_info *)(pci_dev)->sysdata)
+/*
+ * In ia64, pci_dev->sysdata must be a *pci_controller. To provide access to
+ * the pcidev_info structs for all devices under a controller, we extend the
+ * definition of pci_controller, via sn_pci_controller, to include a list
+ * of pcidev_info.
+ */
+struct sn_pci_controller {
+	struct pci_controller pci_controller;
+	struct list_head pcidev_info;
+};
+
+#define SN_PCI_CONTROLLER(dev) ((struct sn_pci_controller *) dev->sysdata)
+
+#define SN_PCIDEV_INFO(dev)	sn_pcidev_info_get(dev)
 
 #define SN_PCIBUS_BUSSOFT_INFO(pci_bus) \
 	(struct pcibus_info *)((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
@@ -53,11 +65,13 @@ struct pcidev_info {
 	struct sn_irq_info	*pdi_sn_irq_info;
 	struct sn_pcibus_provider *pdi_provider;	/* sn pci ops */
 	struct pci_dev 		*host_pci_dev;		/* host bus link */
+	struct list_head	pdi_list;		/* List of pcidev_info */
 };
 
 extern void sn_irq_fixup(struct pci_dev *pci_dev,
 			 struct sn_irq_info *sn_irq_info);
 extern void sn_irq_unfixup(struct pci_dev *pci_dev);
+extern struct pcidev_info * sn_pcidev_info_get(struct pci_dev *);
 extern void sn_pci_controller_fixup(int segment, int busnum,
  				    struct pci_bus *bus);
 extern void sn_bus_store_sysdata(struct pci_dev *dev);

diff-tree 05f70395c642bed0300bc1955bfa8c0f93de2bc2 (from 885da19e8044051a92cfd70099398c373245c431)
Author: Keith Owens <kaos@sgi.com>
Date:   Fri Dec 2 13:40:15 2005 +1100

    [IA64] Allow salinfo_decode to detect signals on read
    
    Return -EINTR instead of -ERESTARTSYS when signals are delivered during
    a blocked read of /proc/sal/*/event.  This allows salinfo_decode to
    detect signals when it is blocked on a read of those files.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index ca68e6e..1461dc6 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -293,7 +293,7 @@ retry:
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
 		if (down_interruptible(&data->sem))
-			return -ERESTARTSYS;
+			return -EINTR;
 	}
 
 	n = data->cpu_check;

diff-tree 885da19e8044051a92cfd70099398c373245c431 (from 1448652a54b5de5189a217374706700275b857e6)
Author: Tony Luck <tony.luck@intel.com>
Date:   Fri Dec 2 16:18:42 2005 -0800

    [IA64] refresh tiger_defconfig ready for 2.6.15
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index 9bc8bca..b1e8f09 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.14-rc1
-# Wed Sep 14 15:17:57 2005
+# Linux kernel version: 2.6.15-rc4
+# Fri Dec  2 16:06:32 2005
 #
 
 #
@@ -59,17 +59,36 @@ CONFIG_KMOD=y
 CONFIG_STOP_MACHINE=y
 
 #
+# Block layer
+#
+
+#
+# IO Schedulers
+#
+CONFIG_IOSCHED_NOOP=y
+CONFIG_IOSCHED_AS=y
+CONFIG_IOSCHED_DEADLINE=y
+CONFIG_IOSCHED_CFQ=y
+CONFIG_DEFAULT_AS=y
+# CONFIG_DEFAULT_DEADLINE is not set
+# CONFIG_DEFAULT_CFQ is not set
+# CONFIG_DEFAULT_NOOP is not set
+CONFIG_DEFAULT_IOSCHED="anticipatory"
+
+#
 # Processor type and features
 #
 CONFIG_IA64=y
 CONFIG_64BIT=y
 CONFIG_MMU=y
+CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_TIME_INTERPOLATION=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
+CONFIG_ZONE_DMA_IS_DMA32=y
 # CONFIG_IA64_GENERIC is not set
 CONFIG_IA64_DIG=y
 # CONFIG_IA64_HP_ZX1 is not set
@@ -82,18 +101,16 @@ CONFIG_MCKINLEY=y
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
+CONFIG_PGTABLE_3=y
+# CONFIG_PGTABLE_4 is not set
 # CONFIG_HZ_100 is not set
 CONFIG_HZ_250=y
 # CONFIG_HZ_1000 is not set
 CONFIG_HZ%0
 CONFIG_IA64_L1_CACHE_SHIFT=7
-# CONFIG_NUMA is not set
-CONFIG_VIRTUAL_MEM_MAP=y
-CONFIG_HOLES_IN_ZONE=y
 CONFIG_IA64_CYCLONE=y
 CONFIG_IOSAPIC=y
-# CONFIG_IA64_SGI_SN_XP is not set
-CONFIG_FORCE_MAX_ZONEORDER
+CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUS=4
 CONFIG_HOTPLUG_CPU=y
@@ -106,7 +123,13 @@ CONFIG_FLATMEM_MANUAL=y
 CONFIG_FLATMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
 # CONFIG_SPARSEMEM_STATIC is not set
-CONFIG_HAVE_DEC_LOCK=y
+CONFIG_SPLIT_PTLOCK_CPUS=4
+CONFIG_ARCH_SELECT_MEMORY_MODEL=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
+CONFIG_ARCH_FLATMEM_ENABLE=y
+CONFIG_ARCH_SPARSEMEM_ENABLE=y
+CONFIG_VIRTUAL_MEM_MAP=y
+CONFIG_HOLES_IN_ZONE=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
@@ -118,7 +141,6 @@ CONFIG_IA64_PALINFO=y
 #
 CONFIG_EFI_VARS=y
 CONFIG_EFI_PCDP=y
-# CONFIG_DELL_RBU is not set
 CONFIG_BINFMT_ELF=y
 CONFIG_BINFMT_MISC=m
 
@@ -126,6 +148,7 @@ CONFIG_BINFMT_MISC=m
 # Power management and ACPI
 #
 CONFIG_PM=y
+CONFIG_PM_LEGACY=y
 # CONFIG_PM_DEBUG is not set
 
 #
@@ -226,14 +249,16 @@ CONFIG_TCP_CONG_BIC=y
 # CONFIG_NET_DIVERT is not set
 # CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
+
+#
+# QoS and/or fair queueing
+#
 # CONFIG_NET_SCHED is not set
-# CONFIG_NET_CLS_ROUTE is not set
 
 #
 # Network testing
 #
 # CONFIG_NET_PKTGEN is not set
-# CONFIG_NETFILTER_NETLINK is not set
 # CONFIG_HAMRADIO is not set
 # CONFIG_IRDA is not set
 # CONFIG_BT is not set
@@ -295,14 +320,6 @@ CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
 CONFIG_BLK_DEV_INITRD=y
 # CONFIG_CDROM_PKTCDVD is not set
-
-#
-# IO Schedulers
-#
-CONFIG_IOSCHED_NOOP=y
-CONFIG_IOSCHED_AS=y
-CONFIG_IOSCHED_DEADLINE=y
-CONFIG_IOSCHED_CFQ=y
 # CONFIG_ATA_OVER_ETH is not set
 
 #
@@ -400,6 +417,7 @@ CONFIG_SCSI_FC_ATTRS=y
 #
 # SCSI low-level drivers
 #
+# CONFIG_ISCSI_TCP is not set
 # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
 # CONFIG_SCSI_3W_9XXX is not set
 # CONFIG_SCSI_ACARD is not set
@@ -409,6 +427,7 @@ CONFIG_SCSI_FC_ATTRS=y
 # CONFIG_SCSI_AIC79XX is not set
 # CONFIG_MEGARAID_NEWGEN is not set
 # CONFIG_MEGARAID_LEGACY is not set
+# CONFIG_MEGARAID_SAS is not set
 # CONFIG_SCSI_SATA is not set
 # CONFIG_SCSI_DMX3191D is not set
 # CONFIG_SCSI_FUTURE_DOMAIN is not set
@@ -424,7 +443,6 @@ CONFIG_SCSI_SYM53C8XX_MAX_TAGSd
 CONFIG_SCSI_QLOGIC_FC=y
 # CONFIG_SCSI_QLOGIC_FC_FIRMWARE is not set
 CONFIG_SCSI_QLOGIC_1280=y
-# CONFIG_SCSI_QLOGIC_1280_1040 is not set
 CONFIG_SCSI_QLA2XXX=y
 CONFIG_SCSI_QLA21XX=m
 CONFIG_SCSI_QLA22XX=m
@@ -463,6 +481,7 @@ CONFIG_DM_ZERO=m
 CONFIG_FUSION=y
 CONFIG_FUSION_SPI=y
 CONFIG_FUSION_FC=y
+# CONFIG_FUSION_SAS is not set
 CONFIG_FUSION_MAX_SGE8
 CONFIG_FUSION_CTL=y
 
@@ -503,6 +522,7 @@ CONFIG_NET_ETHERNET=y
 CONFIG_MII=m
 # CONFIG_HAPPYMEAL is not set
 # CONFIG_SUNGEM is not set
+# CONFIG_CASSINI is not set
 # CONFIG_NET_VENDOR_3COM is not set
 
 #
@@ -727,6 +747,7 @@ CONFIG_MAX_RAW_DEVS%6
 # TPM devices
 #
 # CONFIG_TCG_TPM is not set
+# CONFIG_TELCLOCK is not set
 
 #
 # I2C support
@@ -812,12 +833,15 @@ CONFIG_USB_UHCI_HCD=y
 #
 # USB Device Class drivers
 #
-# CONFIG_USB_BLUETOOTH_TTY is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
 
 #
-# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support' may also be needed; see USB_STORAGE Help for more information
+# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
+#
+
+#
+# may also be needed; see USB_STORAGE Help for more information
 #
 CONFIG_USB_STORAGE=m
 # CONFIG_USB_STORAGE_DEBUG is not set
@@ -1123,9 +1147,10 @@ CONFIG_GENERIC_IRQ_PROBE=y
 CONFIG_GENERIC_PENDING_IRQ=y
 
 #
-# Profiling support
+# Instrumentation Support
 #
 # CONFIG_PROFILING is not set
+# CONFIG_KPROBES is not set
 
 #
 # Kernel hacking
@@ -1142,7 +1167,8 @@ CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 # CONFIG_DEBUG_FS is not set
-# CONFIG_KPROBES is not set
+# CONFIG_DEBUG_VM is not set
+# CONFIG_RCU_TORTURE_TEST is not set
 CONFIG_IA64_GRANULE_16MB=y
 # CONFIG_IA64_GRANULE_64MB is not set
 # CONFIG_IA64_PRINT_HAZARDS is not set

diff-tree 1448652a54b5de5189a217374706700275b857e6 (from deda498710e190c7922c2634ed630ee64ce86c05)
Author: Robin Holt <holt@sgi.com>
Date:   Fri Dec 2 11:14:41 2005 -0600

    [IA64] Updates to the sn2_defconfig for 2.6.15.
    
    This updates the sn2_defconfig file for the Altix 330 hardware, enables
    the AGP graphics for the SGI Prism, and removes prompts for the remainder
    of the new features.  Greg Edwards reviewed the changes.
    
    Signed-off-by: Robin Holt <holt@sgi.com>
    Signed-off-by: Greg Edwards <edwardsg@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index 87cfd31..e1924cc 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.13-rc6
-# Tue Aug 16 14:40:41 2005
+# Linux kernel version: 2.6.15-rc4
+# Fri Dec  2 10:33:48 2005
 #
 
 #
@@ -16,6 +16,7 @@ CONFIG_INIT_ENV_ARG_LIMIT2
 # General setup
 #
 CONFIG_LOCALVERSION=""
+# CONFIG_LOCALVERSION_AUTO is not set
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
 CONFIG_POSIX_MQUEUE=y
@@ -26,6 +27,7 @@ CONFIG_HOTPLUG=y
 CONFIG_KOBJECT_UEVENT=y
 # CONFIG_IKCONFIG is not set
 CONFIG_CPUSETS=y
+CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
 CONFIG_KALLSYMS_ALL=y
@@ -56,11 +58,29 @@ CONFIG_KMOD=y
 CONFIG_STOP_MACHINE=y
 
 #
+# Block layer
+#
+
+#
+# IO Schedulers
+#
+CONFIG_IOSCHED_NOOP=y
+CONFIG_IOSCHED_AS=y
+CONFIG_IOSCHED_DEADLINE=y
+CONFIG_IOSCHED_CFQ=y
+CONFIG_DEFAULT_AS=y
+# CONFIG_DEFAULT_DEADLINE is not set
+# CONFIG_DEFAULT_CFQ is not set
+# CONFIG_DEFAULT_NOOP is not set
+CONFIG_DEFAULT_IOSCHED="anticipatory"
+
+#
 # Processor type and features
 #
 CONFIG_IA64=y
 CONFIG_64BIT=y
 CONFIG_MMU=y
+CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_TIME_INTERPOLATION=y
@@ -68,6 +88,7 @@ CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
 CONFIG_IA64_UNCACHED_ALLOCATOR=y
+CONFIG_ZONE_DMA_IS_DMA32=y
 # CONFIG_IA64_GENERIC is not set
 # CONFIG_IA64_DIG is not set
 # CONFIG_IA64_HP_ZX1 is not set
@@ -87,14 +108,10 @@ CONFIG_HZ_250=y
 # CONFIG_HZ_1000 is not set
 CONFIG_HZ%0
 CONFIG_IA64_L1_CACHE_SHIFT=7
-CONFIG_NUMA=y
-CONFIG_VIRTUAL_MEM_MAP=y
-CONFIG_HOLES_IN_ZONE=y
-CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
 CONFIG_IA64_SGI_SN_XP=m
-CONFIG_FORCE_MAX_ZONEORDER
+CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
 # CONFIG_HOTPLUG_CPU is not set
@@ -107,7 +124,17 @@ CONFIG_DISCONTIGMEM_MANUAL=y
 CONFIG_DISCONTIGMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
 CONFIG_NEED_MULTIPLE_NODES=y
-CONFIG_HAVE_DEC_LOCK=y
+# CONFIG_SPARSEMEM_STATIC is not set
+CONFIG_SPLIT_PTLOCK_CPUS=4
+CONFIG_ARCH_SELECT_MEMORY_MODEL=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
+CONFIG_ARCH_FLATMEM_ENABLE=y
+CONFIG_ARCH_SPARSEMEM_ENABLE=y
+CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
+CONFIG_NUMA=y
+CONFIG_VIRTUAL_MEM_MAP=y
+CONFIG_HOLES_IN_ZONE=y
+CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
@@ -126,28 +153,35 @@ CONFIG_BINFMT_ELF=y
 # Power management and ACPI
 #
 CONFIG_PM=y
-CONFIG_ACPI=y
+# CONFIG_PM_LEGACY is not set
+# CONFIG_PM_DEBUG is not set
 
 #
 # ACPI (Advanced Configuration and Power Interface) Support
 #
+CONFIG_ACPI=y
 # CONFIG_ACPI_BUTTON is not set
 # CONFIG_ACPI_FAN is not set
 # CONFIG_ACPI_PROCESSOR is not set
 CONFIG_ACPI_NUMA=y
+CONFIG_ACPI_BLACKLIST_YEAR=0
 # CONFIG_ACPI_DEBUG is not set
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_SYSTEM=y
 # CONFIG_ACPI_CONTAINER is not set
 
 #
+# CPU Frequency scaling
+#
+# CONFIG_CPU_FREQ is not set
+
+#
 # Bus options (PCI, PCMCIA)
 #
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
 # CONFIG_PCI_MSI is not set
 CONFIG_PCI_LEGACY_PROC=y
-CONFIG_PCI_NAMES=y
 # CONFIG_PCI_DEBUG is not set
 
 #
@@ -191,8 +225,8 @@ CONFIG_SYN_COOKIES=y
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_TUNNEL is not set
-CONFIG_IP_TCPDIAG=y
-# CONFIG_IP_TCPDIAG_IPV6 is not set
+CONFIG_INET_DIAG=m
+CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_BIC=y
 CONFIG_IPV6=m
@@ -205,6 +239,11 @@ CONFIG_IPV6=m
 # CONFIG_NETFILTER is not set
 
 #
+# DCCP Configuration (EXPERIMENTAL)
+#
+# CONFIG_IP_DCCP is not set
+
+#
 # SCTP Configuration (EXPERIMENTAL)
 #
 # CONFIG_IP_SCTP is not set
@@ -220,8 +259,11 @@ CONFIG_IPV6=m
 # CONFIG_NET_DIVERT is not set
 # CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
+
+#
+# QoS and/or fair queueing
+#
 # CONFIG_NET_SCHED is not set
-# CONFIG_NET_CLS_ROUTE is not set
 
 #
 # Network testing
@@ -230,6 +272,7 @@ CONFIG_IPV6=m
 # CONFIG_HAMRADIO is not set
 # CONFIG_IRDA is not set
 # CONFIG_BT is not set
+# CONFIG_IEEE80211 is not set
 
 #
 # Device Drivers
@@ -244,6 +287,11 @@ CONFIG_FW_LOADER=y
 # CONFIG_DEBUG_DRIVER is not set
 
 #
+# Connector - unified userspace <-> kernelspace linker
+#
+# CONFIG_CONNECTOR is not set
+
+#
 # Memory Technology Devices (MTD)
 #
 # CONFIG_MTD is not set
@@ -275,16 +323,7 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
 CONFIG_BLK_DEV_INITRD=y
-CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_CDROM_PKTCDVD is not set
-
-#
-# IO Schedulers
-#
-CONFIG_IOSCHED_NOOP=y
-CONFIG_IOSCHED_AS=y
-CONFIG_IOSCHED_DEADLINE=y
-CONFIG_IOSCHED_CFQ=y
 CONFIG_ATA_OVER_ETH=m
 
 #
@@ -349,6 +388,7 @@ CONFIG_IDEDMA_AUTO=y
 #
 # SCSI device support
 #
+# CONFIG_RAID_ATTRS is not set
 CONFIG_SCSI=y
 CONFIG_SCSI_PROC_FS=y
 
@@ -375,11 +415,13 @@ CONFIG_SCSI_CONSTANTS=y
 #
 CONFIG_SCSI_SPI_ATTRS=y
 CONFIG_SCSI_FC_ATTRS=y
-# CONFIG_SCSI_ISCSI_ATTRS is not set
+CONFIG_SCSI_ISCSI_ATTRS=m
+CONFIG_SCSI_SAS_ATTRS=y
 
 #
 # SCSI low-level drivers
 #
+CONFIG_ISCSI_TCP=m
 # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
 # CONFIG_SCSI_3W_9XXX is not set
 # CONFIG_SCSI_ACARD is not set
@@ -389,15 +431,19 @@ CONFIG_SCSI_FC_ATTRS=y
 # CONFIG_SCSI_AIC79XX is not set
 # CONFIG_MEGARAID_NEWGEN is not set
 # CONFIG_MEGARAID_LEGACY is not set
+# CONFIG_MEGARAID_SAS is not set
 CONFIG_SCSI_SATA=y
 # CONFIG_SCSI_SATA_AHCI is not set
 # CONFIG_SCSI_SATA_SVW is not set
 # CONFIG_SCSI_ATA_PIIX is not set
+# CONFIG_SCSI_SATA_MV is not set
 # CONFIG_SCSI_SATA_NV is not set
-# CONFIG_SCSI_SATA_PROMISE is not set
+# CONFIG_SCSI_PDC_ADMA is not set
 # CONFIG_SCSI_SATA_QSTOR is not set
+# CONFIG_SCSI_SATA_PROMISE is not set
 # CONFIG_SCSI_SATA_SX4 is not set
 # CONFIG_SCSI_SATA_SIL is not set
+# CONFIG_SCSI_SATA_SIL24 is not set
 # CONFIG_SCSI_SATA_SIS is not set
 # CONFIG_SCSI_SATA_ULI is not set
 # CONFIG_SCSI_SATA_VIA is not set
@@ -411,7 +457,6 @@ CONFIG_SCSI_SATA_VITESSE=y
 # CONFIG_SCSI_IPR is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
-# CONFIG_SCSI_QLOGIC_1280_1040 is not set
 CONFIG_SCSI_QLA2XXX=y
 # CONFIG_SCSI_QLA21XX is not set
 CONFIG_SCSI_QLA22XX=y
@@ -451,6 +496,7 @@ CONFIG_DM_MULTIPATH_EMC=m
 CONFIG_FUSION=y
 CONFIG_FUSION_SPI=y
 CONFIG_FUSION_FC=y
+CONFIG_FUSION_SAS=y
 CONFIG_FUSION_MAX_SGE8
 CONFIG_FUSION_CTL=m
 
@@ -479,6 +525,10 @@ CONFIG_NETDEVICES=y
 # CONFIG_ARCNET is not set
 
 #
+# PHY device support
+#
+
+#
 # Ethernet (10 or 100Mbit)
 #
 # CONFIG_NET_ETHERNET is not set
@@ -493,6 +543,7 @@ CONFIG_NETDEVICES=y
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
+# CONFIG_SIS190 is not set
 # CONFIG_SKGE is not set
 # CONFIG_SK98LIN is not set
 CONFIG_TIGON3=y
@@ -501,10 +552,10 @@ CONFIG_TIGON3=y
 #
 # Ethernet (10000 Mbit)
 #
+CONFIG_CHELSIO_T1=m
 # CONFIG_IXGB is not set
 CONFIG_S2IO=m
 # CONFIG_S2IO_NAPI is not set
-# CONFIG_2BUFF_MODE is not set
 
 #
 # Token Ring devices
@@ -583,6 +634,7 @@ CONFIG_HW_CONSOLE=y
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_ROCKETPORT is not set
 # CONFIG_CYCLADES is not set
+# CONFIG_DIGIEPCA is not set
 # CONFIG_MOXA_SMARTIO is not set
 # CONFIG_ISI is not set
 # CONFIG_SYNCLINKMP is not set
@@ -629,7 +681,8 @@ CONFIG_EFI_RTC=y
 #
 # Ftape, the floppy tape device driver
 #
-# CONFIG_AGP is not set
+CONFIG_AGP=y
+CONFIG_AGP_SGI_TIOCA=y
 # CONFIG_DRM is not set
 CONFIG_RAW_DRIVER=m
 # CONFIG_HPET is not set
@@ -641,12 +694,12 @@ CONFIG_MMTIMER=y
 # TPM devices
 #
 # CONFIG_TCG_TPM is not set
+# CONFIG_TELCLOCK is not set
 
 #
 # I2C support
 #
 # CONFIG_I2C is not set
-# CONFIG_I2C_SENSOR is not set
 
 #
 # Dallas's 1-wire bus
@@ -657,12 +710,17 @@ CONFIG_MMTIMER=y
 # Hardware Monitoring support
 #
 # CONFIG_HWMON is not set
+# CONFIG_HWMON_VID is not set
 
 #
 # Misc devices
 #
 
 #
+# Multimedia Capabilities Port drivers
+#
+
+#
 # Multimedia devices
 #
 # CONFIG_VIDEO_DEV is not set
@@ -721,12 +779,15 @@ CONFIG_USB_UHCI_HCD=m
 #
 # USB Device Class drivers
 #
-# CONFIG_USB_BLUETOOTH_TTY is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
 
 #
-# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support' may also be needed; see USB_STORAGE Help for more information
+# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
+#
+
+#
+# may also be needed; see USB_STORAGE Help for more information
 #
 # CONFIG_USB_STORAGE is not set
 
@@ -751,9 +812,11 @@ CONFIG_USB_HIDINPUT=y
 # CONFIG_USB_MTOUCH is not set
 # CONFIG_USB_ITMTOUCH is not set
 # CONFIG_USB_EGALAX is not set
+# CONFIG_USB_YEALINK is not set
 # CONFIG_USB_XPAD is not set
 # CONFIG_USB_ATI_REMOTE is not set
 # CONFIG_USB_KEYSPAN_REMOTE is not set
+# CONFIG_USB_APPLETOUCH is not set
 
 #
 # USB Imaging devices
@@ -824,11 +887,13 @@ CONFIG_USB_MON=y
 # InfiniBand support
 #
 CONFIG_INFINIBAND=m
-CONFIG_INFINIBAND_USER_VERBS=m
+# CONFIG_INFINIBAND_USER_MAD is not set
+CONFIG_INFINIBAND_USER_ACCESS=m
 CONFIG_INFINIBAND_MTHCA=m
 # CONFIG_INFINIBAND_MTHCA_DEBUG is not set
 CONFIG_INFINIBAND_IPOIB=m
 # CONFIG_INFINIBAND_IPOIB_DEBUG is not set
+CONFIG_INFINIBAND_SRP=m
 
 #
 # SN Devices
@@ -858,16 +923,12 @@ CONFIG_REISERFS_FS_POSIX_ACL=y
 CONFIG_REISERFS_FS_SECURITY=y
 # CONFIG_JFS_FS is not set
 CONFIG_FS_POSIX_ACL=y
-
-#
-# XFS support
-#
 CONFIG_XFS_FS=y
 CONFIG_XFS_EXPORT=y
-CONFIG_XFS_RT=y
 CONFIG_XFS_QUOTA=y
 # CONFIG_XFS_SECURITY is not set
 CONFIG_XFS_POSIX_ACL=y
+CONFIG_XFS_RT=y
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
 CONFIG_INOTIFY=y
@@ -878,6 +939,7 @@ CONFIG_QUOTACTL=y
 CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=m
 CONFIG_AUTOFS4_FS=m
+CONFIG_FUSE_FS=m
 
 #
 # CD-ROM/DVD Filesystems
@@ -904,13 +966,11 @@ CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
-# CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-CONFIG_TMPFS_XATTR=y
-CONFIG_TMPFS_SECURITY=y
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
+CONFIG_RELAYFS_FS=m
 
 #
 # Miscellaneous filesystems
@@ -959,6 +1019,7 @@ CONFIG_CIFS=m
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
+# CONFIG_9P_FS is not set
 
 #
 # Partition Types
@@ -1028,18 +1089,21 @@ CONFIG_NLS_UTF8=y
 # Library routines
 #
 # CONFIG_CRC_CCITT is not set
+CONFIG_CRC16=m
 CONFIG_CRC32=y
-# CONFIG_LIBCRC32C is not set
+CONFIG_LIBCRC32C=m
 CONFIG_ZLIB_INFLATE=m
 CONFIG_ZLIB_DEFLATE=m
 CONFIG_GENERIC_ALLOCATOR=y
 CONFIG_GENERIC_HARDIRQS=y
 CONFIG_GENERIC_IRQ_PROBE=y
+CONFIG_GENERIC_PENDING_IRQ=y
 
 #
-# Profiling support
+# Instrumentation Support
 #
 # CONFIG_PROFILING is not set
+# CONFIG_KPROBES is not set
 
 #
 # Kernel hacking
@@ -1048,6 +1112,7 @@ CONFIG_GENERIC_IRQ_PROBE=y
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
 CONFIG_LOG_BUF_SHIFT 
+CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_PREEMPT=y
@@ -1056,7 +1121,8 @@ CONFIG_DEBUG_PREEMPT=y
 # CONFIG_DEBUG_KOBJECT is not set
 CONFIG_DEBUG_INFO=y
 # CONFIG_DEBUG_FS is not set
-# CONFIG_KPROBES is not set
+# CONFIG_DEBUG_VM is not set
+# CONFIG_RCU_TORTURE_TEST is not set
 CONFIG_IA64_GRANULE_16MB=y
 # CONFIG_IA64_GRANULE_64MB is not set
 # CONFIG_IA64_PRINT_HAZARDS is not set
@@ -1097,7 +1163,7 @@ CONFIG_CRYPTO_DES=m
 # CONFIG_CRYPTO_ANUBIS is not set
 CONFIG_CRYPTO_DEFLATE=m
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
-# CONFIG_CRYPTO_CRC32C is not set
+CONFIG_CRYPTO_CRC32C=m
 # CONFIG_CRYPTO_TEST is not set
 
 #
