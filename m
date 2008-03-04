From: akpm@linux-foundation.org
Date: Tue, 04 Mar 2008 23:15:00 +0000
Subject: [patch 3/3] ia64: remove remaining __FUNCTION__ occurrences
Message-Id: <200803042315.m24NF0nZ002327@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Harvey Harrison <harvey.harrison@gmail.com>

__FUNCTION__ is gcc-specific, use __func__

Long lines have been kept where they exist, some small spacing changes
have been done.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/hp/common/hwsw_iommu.c        |    2 
 arch/ia64/hp/common/sba_iommu.c         |   36 +++----
 arch/ia64/hp/sim/simeth.c               |    2 
 arch/ia64/hp/sim/simserial.c            |    2 
 arch/ia64/kernel/crash.c                |    2 
 arch/ia64/kernel/efi.c                  |    6 -
 arch/ia64/kernel/iosapic.c              |   24 ++---
 arch/ia64/kernel/irq_ia64.c             |    4 
 arch/ia64/kernel/mca.c                  |   73 +++++++--------
 arch/ia64/kernel/module.c               |   22 ++--
 arch/ia64/kernel/perfmon.c              |    4 
 arch/ia64/kernel/perfmon_default_smpl.c |    4 
 arch/ia64/kernel/ptrace.c               |    4 
 arch/ia64/kernel/setup.c                |    8 -
 arch/ia64/kernel/unaligned.c            |    6 -
 arch/ia64/kernel/unwind.c               |  102 +++++++++++-----------
 arch/ia64/mm/init.c                     |    2 
 arch/ia64/pci/pci.c                     |    4 
 arch/ia64/sn/kernel/huberror.c          |    4 
 arch/ia64/sn/kernel/io_acpi_init.c      |   36 +++----
 arch/ia64/sn/kernel/io_common.c         |    2 
 arch/ia64/sn/kernel/io_init.c           |    4 
 arch/ia64/sn/kernel/mca.c               |    2 
 arch/ia64/sn/pci/pci_dma.c              |    6 -
 arch/ia64/sn/pci/tioca_provider.c       |   12 +-
 arch/ia64/sn/pci/tioce_provider.c       |    4 
 26 files changed, 186 insertions(+), 191 deletions(-)

diff -puN arch/ia64/hp/common/hwsw_iommu.c~ia64-remove-remaining-__function__-occurences arch/ia64/hp/common/hwsw_iommu.c
--- a/arch/ia64/hp/common/hwsw_iommu.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/hp/common/hwsw_iommu.c
@@ -71,7 +71,7 @@ hwsw_init (void)
 #ifdef CONFIG_IA64_GENERIC
 		/* Better to have normal DMA than panic */
 		printk(KERN_WARNING "%s: Failed to initialize software I/O TLB,"
-		       " reverting to hpzx1 platform vector\n", __FUNCTION__);
+		       " reverting to hpzx1 platform vector\n", __func__);
 		machvec_init("hpzx1");
 #else
 		panic("Unable to initialize software I/O TLB services");
diff -puN arch/ia64/hp/common/sba_iommu.c~ia64-remove-remaining-__function__-occurences arch/ia64/hp/common/sba_iommu.c
--- a/arch/ia64/hp/common/sba_iommu.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/hp/common/sba_iommu.c
@@ -529,7 +529,7 @@ sba_search_bitmap(struct ioc *ioc, unsig
 		base_mask = RESMAP_MASK(bits_wanted);
 		mask = base_mask << bitshiftcnt;
 
-		DBG_RES("%s() o %ld %p", __FUNCTION__, o, res_ptr);
+		DBG_RES("%s() o %ld %p", __func__, o, res_ptr);
 		for(; res_ptr < res_end ; res_ptr++)
 		{ 
 			DBG_RES("    %p %lx %lx\n", res_ptr, mask, *res_ptr);
@@ -679,7 +679,7 @@ sba_alloc_range(struct ioc *ioc, size_t 
 #endif
 
 	DBG_RES("%s(%x) %d -> %lx hint %x/%x\n",
-		__FUNCTION__, size, pages_needed, pide,
+		__func__, size, pages_needed, pide,
 		(uint) ((unsigned long) ioc->res_hint - (unsigned long) ioc->res_map),
 		ioc->res_bitshift );
 
@@ -722,8 +722,8 @@ sba_free_range(struct ioc *ioc, dma_addr
 			m = RESMAP_MASK(bits_not_wanted) << (pide & (BITS_PER_LONG - 1));
 			bits_not_wanted = 0;
 
-			DBG_RES("%s( ,%x,%x) %x/%lx %x %p %lx\n", __FUNCTION__, (uint) iova, size,
-		        	bits_not_wanted, m, pide, res_ptr, *res_ptr);
+			DBG_RES("%s( ,%x,%x) %x/%lx %x %p %lx\n", __func__, (uint) iova, size,
+			        bits_not_wanted, m, pide, res_ptr, *res_ptr);
 
 			ASSERT(m != 0);
 			ASSERT(bits_not_wanted);
@@ -940,8 +940,7 @@ sba_map_single(struct device *dev, void 
 
 	iovp = (dma_addr_t) pide << iovp_shift;
 
-	DBG_RUN("%s() 0x%p -> 0x%lx\n",
-		__FUNCTION__, addr, (long) iovp | offset);
+	DBG_RUN("%s() 0x%p -> 0x%lx\n", __func__, addr, (long) iovp | offset);
 
 	pdir_start = &(ioc->pdir_base[pide]);
 
@@ -1029,8 +1028,7 @@ void sba_unmap_single(struct device *dev
 #endif
 	offset = iova & ~iovp_mask;
 
-	DBG_RUN("%s() iovp 0x%lx/%x\n",
-		__FUNCTION__, (long) iova, size);
+	DBG_RUN("%s() iovp 0x%lx/%x\n", __func__, (long) iova, size);
 
 	iova ^= offset;        /* clear offset bits */
 	size += offset;
@@ -1404,7 +1402,7 @@ int sba_map_sg(struct device *dev, struc
 	struct scatterlist *sg;
 #endif
 
-	DBG_RUN_SG("%s() START %d entries\n", __FUNCTION__, nents);
+	DBG_RUN_SG("%s() START %d entries\n", __func__, nents);
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 
@@ -1468,7 +1466,7 @@ int sba_map_sg(struct device *dev, struc
 #endif
 
 	ASSERT(coalesced = filled);
-	DBG_RUN_SG("%s() DONE %d mappings\n", __FUNCTION__, filled);
+	DBG_RUN_SG("%s() DONE %d mappings\n", __func__, filled);
 
 	return filled;
 }
@@ -1491,7 +1489,7 @@ void sba_unmap_sg (struct device *dev, s
 #endif
 
 	DBG_RUN_SG("%s() START %d entries,  %p,%x\n",
-		__FUNCTION__, nents, sba_sg_address(sglist), sglist->length);
+		   __func__, nents, sba_sg_address(sglist), sglist->length);
 
 #ifdef ASSERT_PDIR_SANITY
 	ioc = GET_IOC(dev);
@@ -1509,7 +1507,7 @@ void sba_unmap_sg (struct device *dev, s
 		nents--;
 	}
 
-	DBG_RUN_SG("%s() DONE (nents %d)\n", __FUNCTION__,  nents);
+	DBG_RUN_SG("%s() DONE (nents %d)\n", __func__,  nents);
 
 #ifdef ASSERT_PDIR_SANITY
 	spin_lock_irqsave(&ioc->res_lock, flags);
@@ -1546,7 +1544,7 @@ ioc_iova_init(struct ioc *ioc)
 	ioc->iov_size = ~ioc->imask + 1;
 
 	DBG_INIT("%s() hpa %p IOV base 0x%lx mask 0x%lx (%dMB)\n",
-		__FUNCTION__, ioc->ioc_hpa, ioc->ibase, ioc->imask,
+		__func__, ioc->ioc_hpa, ioc->ibase, ioc->imask,
 		ioc->iov_size >> 20);
 
 	switch (iovp_size) {
@@ -1569,7 +1567,7 @@ ioc_iova_init(struct ioc *ioc)
 
 	memset(ioc->pdir_base, 0, ioc->pdir_size);
 
-	DBG_INIT("%s() IOV page size %ldK pdir %p size %x\n", __FUNCTION__,
+	DBG_INIT("%s() IOV page size %ldK pdir %p size %x\n", __func__,
 		iovp_size >> 10, ioc->pdir_base, ioc->pdir_size);
 
 	ASSERT(ALIGN((unsigned long) ioc->pdir_base, 4*1024) = (unsigned long) ioc->pdir_base);
@@ -1612,7 +1610,7 @@ ioc_iova_init(struct ioc *ioc)
 
 		prefetch_spill_page = virt_to_phys(addr);
 
-		DBG_INIT("%s() prefetch spill addr: 0x%lx\n", __FUNCTION__, prefetch_spill_page);
+		DBG_INIT("%s() prefetch spill addr: 0x%lx\n", __func__, prefetch_spill_page);
 	}
 	/*
   	** Set all the PDIR entries valid w/ the spill page as the target
@@ -1641,7 +1639,7 @@ ioc_resource_init(struct ioc *ioc)
 	/* resource map size dictated by pdir_size */
 	ioc->res_size = ioc->pdir_size / PDIR_ENTRY_SIZE; /* entries */
 	ioc->res_size >>= 3;  /* convert bit count to byte count */
-	DBG_INIT("%s() res_size 0x%x\n", __FUNCTION__, ioc->res_size);
+	DBG_INIT("%s() res_size 0x%x\n", __func__, ioc->res_size);
 
 	ioc->res_map = (char *) __get_free_pages(GFP_KERNEL,
 						 get_order(ioc->res_size));
@@ -1664,7 +1662,7 @@ ioc_resource_init(struct ioc *ioc)
 							      | prefetch_spill_page);
 #endif
 
-	DBG_INIT("%s() res_map %x %p\n", __FUNCTION__,
+	DBG_INIT("%s() res_map %x %p\n", __func__,
 		 ioc->res_size, (void *) ioc->res_map);
 }
 
@@ -1767,7 +1765,7 @@ ioc_init(u64 hpa, void *handle)
 	iovp_size = (1 << iovp_shift);
 	iovp_mask = ~(iovp_size - 1);
 
-	DBG_INIT("%s: PAGE_SIZE %ldK, iovp_size %ldK\n", __FUNCTION__,
+	DBG_INIT("%s: PAGE_SIZE %ldK, iovp_size %ldK\n", __func__,
 		PAGE_SIZE >> 10, iovp_size >> 10);
 
 	if (!ioc->name) {
@@ -2137,7 +2135,7 @@ sba_page_override(char *str)
 			break;
 		default:
 			printk("%s: unknown/unsupported iommu page size %ld\n",
-			       __FUNCTION__, page_size);
+			       __func__, page_size);
 	}
 
 	return 1;
diff -puN arch/ia64/hp/sim/simeth.c~ia64-remove-remaining-__function__-occurences arch/ia64/hp/sim/simeth.c
--- a/arch/ia64/hp/sim/simeth.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/hp/sim/simeth.c
@@ -222,7 +222,7 @@ simeth_probe1(void)
 	}
 
 	if ((rc = assign_irq_vector(AUTO_ASSIGN)) < 0)
-		panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+		panic("%s: out of interrupt vectors!\n", __func__);
 	dev->irq = rc;
 
 	/*
diff -puN arch/ia64/hp/sim/simserial.c~ia64-remove-remaining-__function__-occurences arch/ia64/hp/sim/simserial.c
--- a/arch/ia64/hp/sim/simserial.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/hp/sim/simserial.c
@@ -1000,7 +1000,7 @@ simrs_init (void)
 		if (!state->irq) {
 			if ((rc = assign_irq_vector(AUTO_ASSIGN)) < 0)
 				panic("%s: out of interrupt vectors!\n",
-				      __FUNCTION__);
+				      __func__);
 			state->irq = rc;
 			ia64_ssc_connect_irq(KEYBOARD_INTR, state->irq);
 		}
diff -puN arch/ia64/kernel/crash.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/crash.c
--- a/arch/ia64/kernel/crash.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/crash.c
@@ -155,7 +155,7 @@ kdump_init_notifier(struct notifier_bloc
 		if (val = DIE_INIT_MONARCH_LEAVE)
 			ia64_mca_printk(KERN_NOTICE
 					"%s: kdump not configured\n",
-					__FUNCTION__);
+					__func__);
 		return NOTIFY_DONE;
 	}
 
diff -puN arch/ia64/kernel/efi.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/efi.c
@@ -379,8 +379,8 @@ efi_get_pal_addr (void)
 		 * a dedicated ITR for the PAL code.
 		 */
 		if ((vaddr & mask) = (KERNEL_START & mask)) {
-			printk(KERN_INFO "%s: no need to install ITR for "
-			       "PAL code\n", __FUNCTION__);
+			printk(KERN_INFO "%s: no need to install ITR for PAL code\n",
+			       __func__);
 			continue;
 		}
 
@@ -399,7 +399,7 @@ efi_get_pal_addr (void)
 		return __va(md->phys_addr);
 	}
 	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found\n",
-	       __FUNCTION__);
+	       __func__);
 	return NULL;
 }
 
diff -puN arch/ia64/kernel/iosapic.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/iosapic.c
@@ -532,7 +532,7 @@ iosapic_reassign_vector (int irq)
 	if (iosapic_intr_info[irq].count) {
 		new_irq = create_irq();
 		if (new_irq < 0)
-			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+			panic("%s: out of interrupt vectors!\n", __func__);
 		printk(KERN_INFO "Reassigning vector %d to %d\n",
 		       irq_to_vector(irq), irq_to_vector(new_irq));
 		memcpy(&iosapic_intr_info[new_irq], &iosapic_intr_info[irq],
@@ -597,7 +597,7 @@ register_intr (unsigned int gsi, int irq
 	index = find_iosapic(gsi);
 	if (index < 0) {
 		printk(KERN_WARNING "%s: No IOSAPIC for GSI %u\n",
-		       __FUNCTION__, gsi);
+		       __func__, gsi);
 		return -ENODEV;
 	}
 
@@ -606,7 +606,7 @@ register_intr (unsigned int gsi, int irq
 		rte = iosapic_alloc_rte();
 		if (!rte) {
 			printk(KERN_WARNING "%s: cannot allocate memory\n",
-			       __FUNCTION__);
+			       __func__);
 			return -ENOMEM;
 		}
 
@@ -623,7 +623,7 @@ register_intr (unsigned int gsi, int irq
 		    (info->trigger != trigger || info->polarity != polarity)){
 			printk (KERN_WARNING
 				"%s: cannot override the interrupt\n",
-				__FUNCTION__);
+				__func__);
 			return -EINVAL;
 		}
 		rte->refcnt++;
@@ -645,7 +645,7 @@ register_intr (unsigned int gsi, int irq
 		if (idesc->chip != &no_irq_type)
 			printk(KERN_WARNING
 			       "%s: changing vector %d from %s to %s\n",
-			       __FUNCTION__, irq_to_vector(irq),
+			       __func__, irq_to_vector(irq),
 			       idesc->chip->name, irq_type->name);
 		idesc->chip = irq_type;
 	}
@@ -918,7 +918,7 @@ iosapic_register_platform_intr (u32 int_
 	      case ACPI_INTERRUPT_INIT:
 		irq = create_irq();
 		if (irq < 0)
-			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+			panic("%s: out of interrupt vectors!\n", __func__);
 		vector = irq_to_vector(irq);
 		delivery = IOSAPIC_INIT;
 		break;
@@ -929,7 +929,7 @@ iosapic_register_platform_intr (u32 int_
 		mask = 1;
 		break;
 	      default:
-		printk(KERN_ERR "%s: invalid int type 0x%x\n", __FUNCTION__,
+		printk(KERN_ERR "%s: invalid int type 0x%x\n", __func__,
 		       int_type);
 		return -1;
 	}
@@ -994,7 +994,7 @@ iosapic_system_init (int system_pcat_com
 		 */
 		printk(KERN_INFO
 		       "%s: Disabling PC-AT compatible 8259 interrupts\n",
-		       __FUNCTION__);
+		       __func__);
 		outb(0xff, 0xA1);
 		outb(0xff, 0x21);
 	}
@@ -1009,7 +1009,7 @@ iosapic_alloc (void)
 		if (!iosapic_lists[index].addr)
 			return index;
 
-	printk(KERN_WARNING "%s: failed to allocate iosapic\n", __FUNCTION__);
+	printk(KERN_WARNING "%s: failed to allocate iosapic\n", __func__);
 	return -1;
 }
 
@@ -1107,14 +1107,14 @@ iosapic_remove (unsigned int gsi_base)
 	index = find_iosapic(gsi_base);
 	if (index < 0) {
 		printk(KERN_WARNING "%s: No IOSAPIC for GSI base %u\n",
-		       __FUNCTION__, gsi_base);
+		       __func__, gsi_base);
 		goto out;
 	}
 
 	if (iosapic_lists[index].rtes_inuse) {
 		err = -EBUSY;
 		printk(KERN_WARNING "%s: IOSAPIC for GSI base %u is busy\n",
-		       __FUNCTION__, gsi_base);
+		       __func__, gsi_base);
 		goto out;
 	}
 
@@ -1135,7 +1135,7 @@ map_iosapic_to_node(unsigned int gsi_bas
 	index = find_iosapic(gsi_base);
 	if (index < 0) {
 		printk(KERN_WARNING "%s: No IOSAPIC for GSI %u\n",
-		       __FUNCTION__, gsi_base);
+		       __func__, gsi_base);
 		return;
 	}
 	iosapic_lists[index].node = node;
diff -puN arch/ia64/kernel/irq_ia64.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/irq_ia64.c
--- a/arch/ia64/kernel/irq_ia64.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/irq_ia64.c
@@ -440,7 +440,7 @@ ia64_handle_irq (ia64_vector vector, str
 			if (unlikely(irq < 0)) {
 				printk(KERN_ERR "%s: Unexpected interrupt "
 				       "vector %d on CPU %d is not mapped "
-				       "to any IRQ!\n", __FUNCTION__, vector,
+				       "to any IRQ!\n", __func__, vector,
 				       smp_processor_id());
 			} else
 				generic_handle_irq(irq);
@@ -505,7 +505,7 @@ void ia64_process_pending_intr(void)
 			if (unlikely(irq < 0)) {
 				printk(KERN_ERR "%s: Unexpected interrupt "
 				       "vector %d on CPU %d not being mapped "
-				       "to any IRQ!!\n", __FUNCTION__, vector,
+				       "to any IRQ!!\n", __func__, vector,
 				       smp_processor_id());
 			} else {
 				vectors_in_migration[irq]=0;
diff -puN arch/ia64/kernel/mca.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/mca.c
@@ -413,8 +413,8 @@ ia64_log_get(int sal_info_type, u8 **buf
 		IA64_LOG_INDEX_INC(sal_info_type);
 		IA64_LOG_UNLOCK(sal_info_type);
 		if (irq_safe) {
-			IA64_MCA_DEBUG("%s: SAL error record type %d retrieved. "
-				       "Record length = %ld\n", __FUNCTION__, sal_info_type, total_len);
+			IA64_MCA_DEBUG("%s: SAL error record type %d retrieved. Record length = %ld\n",
+				       __func__, sal_info_type, total_len);
 		}
 		*buffer = (u8 *) log_buffer;
 		return total_len;
@@ -518,7 +518,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
 	static DEFINE_SPINLOCK(cpe_history_lock);
 
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
-		       __FUNCTION__, cpe_irq, smp_processor_id());
+		       __func__, cpe_irq, smp_processor_id());
 
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
@@ -594,7 +594,7 @@ ia64_mca_register_cpev (int cpev)
 	}
 
 	IA64_MCA_DEBUG("%s: corrected platform error "
-		       "vector %#x registered\n", __FUNCTION__, cpev);
+		       "vector %#x registered\n", __func__, cpev);
 }
 #endif /* CONFIG_ACPI */
 
@@ -621,12 +621,11 @@ ia64_mca_cmc_vector_setup (void)
 	cmcv.cmcv_vector	= IA64_CMC_VECTOR;
 	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);
 
-	IA64_MCA_DEBUG("%s: CPU %d corrected "
-		       "machine check vector %#x registered.\n",
-		       __FUNCTION__, smp_processor_id(), IA64_CMC_VECTOR);
+	IA64_MCA_DEBUG("%s: CPU %d corrected machine check vector %#x registered.\n",
+		       __func__, smp_processor_id(), IA64_CMC_VECTOR);
 
 	IA64_MCA_DEBUG("%s: CPU %d CMCV = %#016lx\n",
-		       __FUNCTION__, smp_processor_id(), ia64_getreg(_IA64_REG_CR_CMCV));
+		       __func__, smp_processor_id(), ia64_getreg(_IA64_REG_CR_CMCV));
 }
 
 /*
@@ -651,9 +650,8 @@ ia64_mca_cmc_vector_disable (void *dummy
 	cmcv.cmcv_mask = 1; /* Mask/disable interrupt */
 	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);
 
-	IA64_MCA_DEBUG("%s: CPU %d corrected "
-		       "machine check vector %#x disabled.\n",
-		       __FUNCTION__, smp_processor_id(), cmcv.cmcv_vector);
+	IA64_MCA_DEBUG("%s: CPU %d corrected machine check vector %#x disabled.\n",
+		       __func__, smp_processor_id(), cmcv.cmcv_vector);
 }
 
 /*
@@ -678,9 +676,8 @@ ia64_mca_cmc_vector_enable (void *dummy)
 	cmcv.cmcv_mask = 0; /* Unmask/enable interrupt */
 	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);
 
-	IA64_MCA_DEBUG("%s: CPU %d corrected "
-		       "machine check vector %#x enabled.\n",
-		       __FUNCTION__, smp_processor_id(), cmcv.cmcv_vector);
+	IA64_MCA_DEBUG("%s: CPU %d corrected machine check vector %#x enabled.\n",
+		       __func__, smp_processor_id(), cmcv.cmcv_vector);
 }
 
 /*
@@ -767,7 +764,7 @@ ia64_mca_rendez_int_handler(int rendez_i
 	local_irq_save(flags);
 	if (notify_die(DIE_MCA_RENDZVOUS_ENTER, "MCA", get_irq_regs(),
 		       (long)&nd, 0, 0) = NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
+		ia64_mca_spin(__func__);
 
 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE;
 	/* Register with the SAL monarch that the slave has
@@ -777,7 +774,7 @@ ia64_mca_rendez_int_handler(int rendez_i
 
 	if (notify_die(DIE_MCA_RENDZVOUS_PROCESS, "MCA", get_irq_regs(),
 		       (long)&nd, 0, 0) = NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
+		ia64_mca_spin(__func__);
 
 	/* Wait for the monarch cpu to exit. */
 	while (monarch_cpu != -1)
@@ -785,7 +782,7 @@ ia64_mca_rendez_int_handler(int rendez_i
 
 	if (notify_die(DIE_MCA_RENDZVOUS_LEAVE, "MCA", get_irq_regs(),
 		       (long)&nd, 0, 0) = NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
+		ia64_mca_spin(__func__);
 
 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 	/* Enable all interrupts */
@@ -1230,7 +1227,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 
 	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
+		ia64_mca_spin(__func__);
 
 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_CONCURRENT_MCA;
 	if (sos->monarch) {
@@ -1246,7 +1243,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 		ia64_mca_wakeup_all();
 		if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
-			ia64_mca_spin(__FUNCTION__);
+			ia64_mca_spin(__func__);
 	} else {
 		while (cpu_isset(cpu, mca_cpu))
 			cpu_relax();	/* spin until monarch wakes us */
@@ -1276,7 +1273,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 	}
 	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
 			= NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
+		ia64_mca_spin(__func__);
 
 
 	if (atomic_dec_return(&mca_count) > 0) {
@@ -1328,7 +1325,7 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 	static DEFINE_SPINLOCK(cmc_history_lock);
 
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
-		       __FUNCTION__, cmc_irq, smp_processor_id());
+		       __func__, cmc_irq, smp_processor_id());
 
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
@@ -1614,7 +1611,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	 */
 	if (!sos->monarch && atomic_add_return(1, &slaves) = num_online_cpus()) {
 		mprintk(KERN_WARNING "%s: Promoting cpu %d to monarch.\n",
-		       __FUNCTION__, cpu);
+		        __func__, cpu);
 		atomic_dec(&slaves);
 		sos->monarch = 1;
 	}
@@ -1626,7 +1623,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	 */
 	if (sos->monarch && atomic_add_return(1, &monarchs) > 1) {
 		mprintk(KERN_WARNING "%s: Demoting cpu %d to slave.\n",
-			       __FUNCTION__, cpu);
+			       __func__, cpu);
 		atomic_dec(&monarchs);
 		sos->monarch = 0;
 	}
@@ -1637,15 +1634,15 @@ ia64_init_handler(struct pt_regs *regs, 
 		       cpu_relax();	/* spin until monarch enters */
 		if (notify_die(DIE_INIT_SLAVE_ENTER, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
-			ia64_mca_spin(__FUNCTION__);
+			ia64_mca_spin(__func__);
 		if (notify_die(DIE_INIT_SLAVE_PROCESS, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
-			ia64_mca_spin(__FUNCTION__);
+			ia64_mca_spin(__func__);
 		while (monarch_cpu != -1)
 		       cpu_relax();	/* spin until monarch leaves */
 		if (notify_die(DIE_INIT_SLAVE_LEAVE, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
-			ia64_mca_spin(__FUNCTION__);
+			ia64_mca_spin(__func__);
 		mprintk("Slave on cpu %d returning to normal service.\n", cpu);
 		set_curr_task(cpu, previous_current);
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
@@ -1656,7 +1653,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	monarch_cpu = cpu;
 	if (notify_die(DIE_INIT_MONARCH_ENTER, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
+		ia64_mca_spin(__func__);
 
 	/*
 	 * Wait for a bit.  On some machines (e.g., HP's zx2000 and zx6000, INIT can be
@@ -1673,10 +1670,10 @@ ia64_init_handler(struct pt_regs *regs, 
 	 */
 	if (notify_die(DIE_INIT_MONARCH_PROCESS, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
+		ia64_mca_spin(__func__);
 	if (notify_die(DIE_INIT_MONARCH_LEAVE, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
+		ia64_mca_spin(__func__);
 	mprintk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
 	atomic_dec(&monarchs);
 	set_curr_task(cpu, previous_current);
@@ -1884,7 +1881,7 @@ ia64_mca_init(void)
 		.priority = 0/* we need to notified last */
 	};
 
-	IA64_MCA_DEBUG("%s: begin\n", __FUNCTION__);
+	IA64_MCA_DEBUG("%s: begin\n", __func__);
 
 	/* Clear the Rendez checkin flag for all cpus */
 	for(i = 0 ; i < NR_CPUS; i++)
@@ -1928,7 +1925,7 @@ ia64_mca_init(void)
 		return;
 	}
 
-	IA64_MCA_DEBUG("%s: registered MCA rendezvous spinloop and wakeup mech.\n", __FUNCTION__);
+	IA64_MCA_DEBUG("%s: registered MCA rendezvous spinloop and wakeup mech.\n", __func__);
 
 	ia64_mc_info.imi_mca_handler        = ia64_tpa(mca_hldlr_ptr->fp);
 	/*
@@ -1949,7 +1946,7 @@ ia64_mca_init(void)
 		return;
 	}
 
-	IA64_MCA_DEBUG("%s: registered OS MCA handler with SAL at 0x%lx, gp = 0x%lx\n", __FUNCTION__,
+	IA64_MCA_DEBUG("%s: registered OS MCA handler with SAL at 0x%lx, gp = 0x%lx\n", __func__,
 		       ia64_mc_info.imi_mca_handler, ia64_tpa(mca_hldlr_ptr->gp));
 
 	/*
@@ -1961,7 +1958,7 @@ ia64_mca_init(void)
 	ia64_mc_info.imi_slave_init_handler		= ia64_tpa(init_hldlr_ptr_slave->fp);
 	ia64_mc_info.imi_slave_init_handler_size	= 0;
 
-	IA64_MCA_DEBUG("%s: OS INIT handler at %lx\n", __FUNCTION__,
+	IA64_MCA_DEBUG("%s: OS INIT handler at %lx\n", __func__,
 		       ia64_mc_info.imi_monarch_init_handler);
 
 	/* Register the os init handler with SAL */
@@ -1982,7 +1979,7 @@ ia64_mca_init(void)
 		return;
 	}
 
-	IA64_MCA_DEBUG("%s: registered OS INIT handler with SAL\n", __FUNCTION__);
+	IA64_MCA_DEBUG("%s: registered OS INIT handler with SAL\n", __func__);
 
 	/*
 	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
@@ -2042,7 +2039,7 @@ ia64_mca_late_init(void)
 	cmc_polling_enabled = 0;
 	schedule_work(&cmc_enable_work);
 
-	IA64_MCA_DEBUG("%s: CMCI/P setup and enabled.\n", __FUNCTION__);
+	IA64_MCA_DEBUG("%s: CMCI/P setup and enabled.\n", __func__);
 
 #ifdef CONFIG_ACPI
 	/* Setup the CPEI/P vector and handler */
@@ -2065,17 +2062,17 @@ ia64_mca_late_init(void)
 				ia64_cpe_irq = irq;
 				ia64_mca_register_cpev(cpe_vector);
 				IA64_MCA_DEBUG("%s: CPEI/P setup and enabled.\n",
-					__FUNCTION__);
+					__func__);
 				return 0;
 			}
 			printk(KERN_ERR "%s: Failed to find irq for CPE "
 					"interrupt handler, vector %d\n",
-					__FUNCTION__, cpe_vector);
+					__func__, cpe_vector);
 		}
 		/* If platform doesn't support CPEI, get the timer going. */
 		if (cpe_poll_enabled) {
 			ia64_mca_cpe_poll(0UL);
-			IA64_MCA_DEBUG("%s: CPEP setup and enabled.\n", __FUNCTION__);
+			IA64_MCA_DEBUG("%s: CPEP setup and enabled.\n", __func__);
 		}
 	}
 #endif
diff -puN arch/ia64/kernel/module.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/module.c
--- a/arch/ia64/kernel/module.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/module.c
@@ -493,7 +493,7 @@ module_frob_arch_sections (Elf_Ehdr *ehd
 	mod->arch.opd->sh_addralign = 8;
 	mod->arch.opd->sh_size = fdescs * sizeof(struct fdesc);
 	DEBUGP("%s: core.plt=%lx, init.plt=%lx, got=%lx, fdesc=%lx\n",
-	       __FUNCTION__, mod->arch.core_plt->sh_size, mod->arch.init_plt->sh_size,
+	       __func__, mod->arch.core_plt->sh_size, mod->arch.init_plt->sh_size,
 	       mod->arch.got->sh_size, mod->arch.opd->sh_size);
 	return 0;
 }
@@ -585,7 +585,7 @@ get_plt (struct module *mod, const struc
 #if ARCH_MODULE_DEBUG
 	if (plt_target(plt) != target_ip) {
 		printk("%s: mistargeted PLT: wanted %lx, got %lx\n",
-		       __FUNCTION__, target_ip, plt_target(plt));
+		       __func__, target_ip, plt_target(plt));
 		*okp = 0;
 		return 0;
 	}
@@ -703,7 +703,7 @@ do_reloc (struct module *mod, uint8_t r_
 		if (r_type = R_IA64_PCREL21BI) {
 			if (!is_internal(mod, val)) {
 				printk(KERN_ERR "%s: %s reloc against non-local symbol (%lx)\n",
-				       __FUNCTION__, reloc_name[r_type], val);
+				       __func__, reloc_name[r_type], val);
 				return -ENOEXEC;
 			}
 			format = RF_INSN21B;
@@ -737,7 +737,7 @@ do_reloc (struct module *mod, uint8_t r_
 		      case R_IA64_LDXMOV:
 			if (gp_addressable(mod, val)) {
 				/* turn "ld8" into "mov": */
-				DEBUGP("%s: patching ld8 at %p to mov\n", __FUNCTION__, location);
+				DEBUGP("%s: patching ld8 at %p to mov\n", __func__, location);
 				ia64_patch((u64) location, 0x1fff80fe000UL, 0x10000000000UL);
 			}
 			return 0;
@@ -771,7 +771,7 @@ do_reloc (struct module *mod, uint8_t r_
 	if (!ok)
 		return -ENOEXEC;
 
-	DEBUGP("%s: [%p]<-%016lx = %s(%lx)\n", __FUNCTION__, location, val,
+	DEBUGP("%s: [%p]<-%016lx = %s(%lx)\n", __func__, location, val,
 	       reloc_name[r_type] ? reloc_name[r_type] : "?", sym->st_value + addend);
 
 	switch (format) {
@@ -807,7 +807,7 @@ apply_relocate_add (Elf64_Shdr *sechdrs,
 	Elf64_Shdr *target_sec;
 	int ret;
 
-	DEBUGP("%s: applying section %u (%u relocs) to %u\n", __FUNCTION__,
+	DEBUGP("%s: applying section %u (%u relocs) to %u\n", __func__,
 	       relsec, n, sechdrs[relsec].sh_info);
 
 	target_sec = sechdrs + sechdrs[relsec].sh_info;
@@ -835,7 +835,7 @@ apply_relocate_add (Elf64_Shdr *sechdrs,
 			gp = mod->core_size / 2;
 		gp = (uint64_t) mod->module_core + ((gp + 7) & -8);
 		mod->arch.gp = gp;
-		DEBUGP("%s: placing gp at 0x%lx\n", __FUNCTION__, gp);
+		DEBUGP("%s: placing gp at 0x%lx\n", __func__, gp);
 	}
 
 	for (i = 0; i < n; i++) {
@@ -903,7 +903,7 @@ register_unwind_table (struct module *mo
 		init = start + num_core;
 	}
 
-	DEBUGP("%s: name=%s, gp=%lx, num_init=%lu, num_core=%lu\n", __FUNCTION__,
+	DEBUGP("%s: name=%s, gp=%lx, num_init=%lu, num_core=%lu\n", __func__,
 	       mod->name, mod->arch.gp, num_init, num_core);
 
 	/*
@@ -912,13 +912,13 @@ register_unwind_table (struct module *mo
 	if (num_core > 0) {
 		mod->arch.core_unw_table = unw_add_unwind_table(mod->name, 0, mod->arch.gp,
 								core, core + num_core);
-		DEBUGP("%s:  core: handle=%p [%p-%p)\n", __FUNCTION__,
+		DEBUGP("%s:  core: handle=%p [%p-%p)\n", __func__,
 		       mod->arch.core_unw_table, core, core + num_core);
 	}
 	if (num_init > 0) {
 		mod->arch.init_unw_table = unw_add_unwind_table(mod->name, 0, mod->arch.gp,
 								init, init + num_init);
-		DEBUGP("%s:  init: handle=%p [%p-%p)\n", __FUNCTION__,
+		DEBUGP("%s:  init: handle=%p [%p-%p)\n", __func__,
 		       mod->arch.init_unw_table, init, init + num_init);
 	}
 }
@@ -926,7 +926,7 @@ register_unwind_table (struct module *mo
 int
 module_finalize (const Elf_Ehdr *hdr, const Elf_Shdr *sechdrs, struct module *mod)
 {
-	DEBUGP("%s: init: entry=%p\n", __FUNCTION__, mod->init);
+	DEBUGP("%s: init: entry=%p\n", __func__, mod->init);
 	if (mod->arch.unwind)
 		register_unwind_table(mod);
 	return 0;
diff -puN arch/ia64/kernel/perfmon.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/perfmon.c
@@ -227,12 +227,12 @@
 #ifdef PFM_DEBUGGING
 #define DPRINT(a) \
 	do { \
-		if (unlikely(pfm_sysctl.debug >0)) { printk("%s.%d: CPU%d [%d] ", __FUNCTION__, __LINE__, smp_processor_id(), task_pid_nr(current)); printk a; } \
+		if (unlikely(pfm_sysctl.debug >0)) { printk("%s.%d: CPU%d [%d] ", __func__, __LINE__, smp_processor_id(), task_pid_nr(current)); printk a; } \
 	} while (0)
 
 #define DPRINT_ovfl(a) \
 	do { \
-		if (unlikely(pfm_sysctl.debug > 0 && pfm_sysctl.debug_ovfl >0)) { printk("%s.%d: CPU%d [%d] ", __FUNCTION__, __LINE__, smp_processor_id(), task_pid_nr(current)); printk a; } \
+		if (unlikely(pfm_sysctl.debug > 0 && pfm_sysctl.debug_ovfl >0)) { printk("%s.%d: CPU%d [%d] ", __func__, __LINE__, smp_processor_id(), task_pid_nr(current)); printk a; } \
 	} while (0)
 #endif
 
diff -puN arch/ia64/kernel/perfmon_default_smpl.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/perfmon_default_smpl.c
--- a/arch/ia64/kernel/perfmon_default_smpl.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/perfmon_default_smpl.c
@@ -24,12 +24,12 @@ MODULE_LICENSE("GPL");
 #ifdef DEFAULT_DEBUG
 #define DPRINT(a) \
 	do { \
-		if (unlikely(pfm_sysctl.debug >0)) { printk("%s.%d: CPU%d ", __FUNCTION__, __LINE__, smp_processor_id()); printk a; } \
+		if (unlikely(pfm_sysctl.debug >0)) { printk("%s.%d: CPU%d ", __func__, __LINE__, smp_processor_id()); printk a; } \
 	} while (0)
 
 #define DPRINT_ovfl(a) \
 	do { \
-		if (unlikely(pfm_sysctl.debug > 0 && pfm_sysctl.debug_ovfl >0)) { printk("%s.%d: CPU%d ", __FUNCTION__, __LINE__, smp_processor_id()); printk a; } \
+		if (unlikely(pfm_sysctl.debug > 0 && pfm_sysctl.debug_ovfl >0)) { printk("%s.%d: CPU%d ", __func__, __LINE__, smp_processor_id()); printk a; } \
 	} while (0)
 
 #else
diff -puN arch/ia64/kernel/ptrace.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/ptrace.c
--- a/arch/ia64/kernel/ptrace.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/ptrace.c
@@ -826,14 +826,14 @@ convert_to_non_syscall (struct task_stru
 		if ((long)((unsigned long)child + IA64_STK_OFFSET - sp)
 		    < IA64_PT_REGS_SIZE) {
 			dprintk("ptrace.%s: ran off the top of the kernel "
-				"stack\n", __FUNCTION__);
+				"stack\n", __func__);
 			return;
 		}
 		if (unw_get_pr (&prev_info, &pr) < 0) {
 			unw_get_rp(&prev_info, &ip);
 			dprintk("ptrace.%s: failed to read "
 				"predicate register (ip=0x%lx)\n",
-				__FUNCTION__, ip);
+				__func__, ip);
 			return;
 		}
 		if (unw_is_intr_frame(&info)
diff -puN arch/ia64/kernel/setup.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/setup.c
@@ -690,7 +690,7 @@ get_model_name(__u8 family, __u8 model)
 	if (overflow++ = 0)
 		printk(KERN_ERR
 		       "%s: Table overflow. Some processor model information will be missing\n",
-		       __FUNCTION__);
+		       __func__);
 	return "Unknown";
 }
 
@@ -785,7 +785,7 @@ get_max_cacheline_size (void)
         status = ia64_pal_cache_summary(&levels, &unique_caches);
         if (status != 0) {
                 printk(KERN_ERR "%s: ia64_pal_cache_summary() failed (status=%ld)\n",
-                       __FUNCTION__, status);
+                       __func__, status);
                 max = SMP_CACHE_BYTES;
 		/* Safest setup for "flush_icache_range()" */
 		ia64_i_cache_stride_shift = I_CACHE_STRIDE_SHIFT;
@@ -798,7 +798,7 @@ get_max_cacheline_size (void)
 		if (status != 0) {
 			printk(KERN_ERR
 			       "%s: ia64_pal_cache_config_info(l=%lu, 2) failed (status=%ld)\n",
-			       __FUNCTION__, l, status);
+			       __func__, l, status);
 			max = SMP_CACHE_BYTES;
 			/* The safest setup for "flush_icache_range()" */
 			cci.pcci_stride = I_CACHE_STRIDE_SHIFT;
@@ -814,7 +814,7 @@ get_max_cacheline_size (void)
 			if (status != 0) {
 				printk(KERN_ERR
 				"%s: ia64_pal_cache_config_info(l=%lu, 1) failed (status=%ld)\n",
-					__FUNCTION__, l, status);
+					__func__, l, status);
 				/* The safest setup for "flush_icache_range()" */
 				cci.pcci_stride = I_CACHE_STRIDE_SHIFT;
 			}
diff -puN arch/ia64/kernel/unaligned.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/unaligned.c
--- a/arch/ia64/kernel/unaligned.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/unaligned.c
@@ -28,7 +28,7 @@ extern int die_if_kernel(char *str, stru
 #undef DEBUG_UNALIGNED_TRAP
 
 #ifdef DEBUG_UNALIGNED_TRAP
-# define DPRINT(a...)	do { printk("%s %u: ", __FUNCTION__, __LINE__); printk (a); } while (0)
+# define DPRINT(a...)	do { printk("%s %u: ", __func__, __LINE__); printk (a); } while (0)
 # define DDUMP(str,vp,len)	dump(str, vp, len)
 
 static void
@@ -674,7 +674,7 @@ emulate_load_updates (update_t type, loa
 	 * just in case.
 	 */
 	if (ld.x6_op = 1 || ld.x6_op = 3) {
-		printk(KERN_ERR "%s: register update on speculative load, error\n", __FUNCTION__);
+		printk(KERN_ERR "%s: register update on speculative load, error\n", __func__);
 		if (die_if_kernel("unaligned reference on speculative load with register update\n",
 				  regs, 30))
 			return;
@@ -1104,7 +1104,7 @@ emulate_load_floatpair (unsigned long if
 		 */
 		if (ld.x6_op = 1 || ld.x6_op = 3)
 			printk(KERN_ERR "%s: register update on speculative load pair, error\n",
-			       __FUNCTION__);
+			       __func__);
 
 		setreg(ld.r3, ifa, 0, regs);
 	}
diff -puN arch/ia64/kernel/unwind.c~ia64-remove-remaining-__function__-occurences arch/ia64/kernel/unwind.c
--- a/arch/ia64/kernel/unwind.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/kernel/unwind.c
@@ -257,7 +257,7 @@ pt_regs_off (unsigned long reg)
 		off = unw.pt_regs_offsets[reg];
 
 	if (off < 0) {
-		UNW_DPRINT(0, "unwind.%s: bad scratch reg r%lu\n", __FUNCTION__, reg);
+		UNW_DPRINT(0, "unwind.%s: bad scratch reg r%lu\n", __func__, reg);
 		off = 0;
 	}
 	return (unsigned long) off;
@@ -268,13 +268,13 @@ get_scratch_regs (struct unw_frame_info 
 {
 	if (!info->pt) {
 		/* This should not happen with valid unwind info.  */
-		UNW_DPRINT(0, "unwind.%s: bad unwind info: resetting info->pt\n", __FUNCTION__);
+		UNW_DPRINT(0, "unwind.%s: bad unwind info: resetting info->pt\n", __func__);
 		if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
 			info->pt = (unsigned long) ((struct pt_regs *) info->psp - 1);
 		else
 			info->pt = info->sp - 16;
 	}
-	UNW_DPRINT(3, "unwind.%s: sp 0x%lx pt 0x%lx\n", __FUNCTION__, info->sp, info->pt);
+	UNW_DPRINT(3, "unwind.%s: sp 0x%lx pt 0x%lx\n", __func__, info->sp, info->pt);
 	return (struct pt_regs *) info->pt;
 }
 
@@ -294,7 +294,7 @@ unw_access_gr (struct unw_frame_info *in
 			return 0;
 		}
 		UNW_DPRINT(0, "unwind.%s: trying to access non-existent r%u\n",
-			   __FUNCTION__, regnum);
+			   __func__, regnum);
 		return -1;
 	}
 
@@ -341,7 +341,7 @@ unw_access_gr (struct unw_frame_info *in
 					{
 						UNW_DPRINT(0, "unwind.%s: %p outside of regstk "
 							"[0x%lx-0x%lx)\n",
-							__FUNCTION__, (void *) addr,
+							__func__, (void *) addr,
 							info->regstk.limit,
 							info->regstk.top);
 						return -1;
@@ -374,7 +374,7 @@ unw_access_gr (struct unw_frame_info *in
 		    || (unsigned long) addr >= info->regstk.top)
 		{
 			UNW_DPRINT(0, "unwind.%s: ignoring attempt to access register outside "
-				   "of rbs\n",  __FUNCTION__);
+				   "of rbs\n",  __func__);
 			return -1;
 		}
 		if ((unsigned long) nat_addr >= info->regstk.top)
@@ -385,7 +385,7 @@ unw_access_gr (struct unw_frame_info *in
 	if (write) {
 		if (read_only(addr)) {
 			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
-				__FUNCTION__);
+				__func__);
 		} else {
 			*addr = *val;
 			if (*nat)
@@ -427,13 +427,13 @@ unw_access_br (struct unw_frame_info *in
 
 	      default:
 		UNW_DPRINT(0, "unwind.%s: trying to access non-existent b%u\n",
-			   __FUNCTION__, regnum);
+			   __func__, regnum);
 		return -1;
 	}
 	if (write)
 		if (read_only(addr)) {
 			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
-				__FUNCTION__);
+				__func__);
 		} else
 			*addr = *val;
 	else
@@ -450,7 +450,7 @@ unw_access_fr (struct unw_frame_info *in
 
 	if ((unsigned) (regnum - 2) >= 126) {
 		UNW_DPRINT(0, "unwind.%s: trying to access non-existent f%u\n",
-			   __FUNCTION__, regnum);
+			   __func__, regnum);
 		return -1;
 	}
 
@@ -482,7 +482,7 @@ unw_access_fr (struct unw_frame_info *in
 	if (write)
 		if (read_only(addr)) {
 			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
-				__FUNCTION__);
+				__func__);
 		} else
 			*addr = *val;
 	else
@@ -572,14 +572,14 @@ unw_access_ar (struct unw_frame_info *in
 
 	      default:
 		UNW_DPRINT(0, "unwind.%s: trying to access non-existent ar%u\n",
-			   __FUNCTION__, regnum);
+			   __func__, regnum);
 		return -1;
 	}
 
 	if (write) {
 		if (read_only(addr)) {
 			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
-				__FUNCTION__);
+				__func__);
 		} else
 			*addr = *val;
 	} else
@@ -600,7 +600,7 @@ unw_access_pr (struct unw_frame_info *in
 	if (write) {
 		if (read_only(addr)) {
 			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
-				__FUNCTION__);
+				__func__);
 		} else
 			*addr = *val;
 	} else
@@ -699,7 +699,7 @@ decode_abreg (unsigned char abreg, int m
 	      default:
 		break;
 	}
-	UNW_DPRINT(0, "unwind.%s: bad abreg=0x%x\n", __FUNCTION__, abreg);
+	UNW_DPRINT(0, "unwind.%s: bad abreg=0x%x\n", __func__, abreg);
 	return UNW_REG_LC;
 }
 
@@ -739,7 +739,7 @@ spill_next_when (struct unw_reg_info **r
 			return;
 		}
 	}
-	UNW_DPRINT(0, "unwind.%s: excess spill!\n",  __FUNCTION__);
+	UNW_DPRINT(0, "unwind.%s: excess spill!\n",  __func__);
 }
 
 static inline void
@@ -855,11 +855,11 @@ desc_abi (unsigned char abi, unsigned ch
 {
 	if (abi = 3 && context = 'i') {
 		sr->flags |= UNW_FLAG_INTERRUPT_FRAME;
-		UNW_DPRINT(3, "unwind.%s: interrupt frame\n",  __FUNCTION__);
+		UNW_DPRINT(3, "unwind.%s: interrupt frame\n",  __func__);
 	}
 	else
 		UNW_DPRINT(0, "unwind%s: ignoring unwabi(abi=0x%x,context=0x%x)\n",
-				__FUNCTION__, abi, context);
+				__func__, abi, context);
 }
 
 static inline void
@@ -1347,7 +1347,7 @@ script_emit (struct unw_script *script, 
 {
 	if (script->count >= UNW_MAX_SCRIPT_LEN) {
 		UNW_DPRINT(0, "unwind.%s: script exceeds maximum size of %u instructions!\n",
-			__FUNCTION__, UNW_MAX_SCRIPT_LEN);
+			__func__, UNW_MAX_SCRIPT_LEN);
 		return;
 	}
 	script->insn[script->count++] = insn;
@@ -1389,7 +1389,7 @@ emit_nat_info (struct unw_state_record *
 
 	      default:
 		UNW_DPRINT(0, "unwind.%s: don't know how to emit nat info for where = %u\n",
-			   __FUNCTION__, r->where);
+			   __func__, r->where);
 		return;
 	}
 	insn.opc = opc;
@@ -1446,7 +1446,7 @@ compile_reg (struct unw_state_record *sr
 				val = offsetof(struct pt_regs, f6) + 16*(rval - 6);
 			else
 				UNW_DPRINT(0, "unwind.%s: kernel may not touch f%lu\n",
-					   __FUNCTION__, rval);
+					   __func__, rval);
 		}
 		break;
 
@@ -1474,7 +1474,7 @@ compile_reg (struct unw_state_record *sr
 
 	      default:
 		UNW_DPRINT(0, "unwind%s: register %u has unexpected `where' value of %u\n",
-			   __FUNCTION__, i, r->where);
+			   __func__, i, r->where);
 		break;
 	}
 	insn.opc = opc;
@@ -1547,10 +1547,10 @@ build_script (struct unw_frame_info *inf
 		r->when = UNW_WHEN_NEVER;
 	sr.pr_val = info->pr;
 
-	UNW_DPRINT(3, "unwind.%s: ip 0x%lx\n", __FUNCTION__, ip);
+	UNW_DPRINT(3, "unwind.%s: ip 0x%lx\n", __func__, ip);
 	script = script_new(ip);
 	if (!script) {
-		UNW_DPRINT(0, "unwind.%s: failed to create unwind script\n",  __FUNCTION__);
+		UNW_DPRINT(0, "unwind.%s: failed to create unwind script\n",  __func__);
 		STAT(unw.stat.script.build_time += ia64_get_itc() - start);
 		return NULL;
 	}
@@ -1569,7 +1569,7 @@ build_script (struct unw_frame_info *inf
 	if (!e) {
 		/* no info, return default unwinder (leaf proc, no mem stack, no saved regs)  */
 		UNW_DPRINT(1, "unwind.%s: no unwind info for ip=0x%lx (prev ip=0x%lx)\n",
-			__FUNCTION__, ip, unw.cache[info->prev_script].ip);
+			__func__, ip, unw.cache[info->prev_script].ip);
 		sr.curr.reg[UNW_REG_RP].where = UNW_WHERE_BR;
 		sr.curr.reg[UNW_REG_RP].when = -1;
 		sr.curr.reg[UNW_REG_RP].val = 0;
@@ -1618,13 +1618,13 @@ build_script (struct unw_frame_info *inf
 		sr.curr.reg[UNW_REG_RP].when = -1;
 		sr.curr.reg[UNW_REG_RP].val = sr.return_link_reg;
 		UNW_DPRINT(1, "unwind.%s: using default for rp at ip=0x%lx where=%d val=0x%lx\n",
-			   __FUNCTION__, ip, sr.curr.reg[UNW_REG_RP].where,
+			   __func__, ip, sr.curr.reg[UNW_REG_RP].where,
 			   sr.curr.reg[UNW_REG_RP].val);
 	}
 
 #ifdef UNW_DEBUG
 	UNW_DPRINT(1, "unwind.%s: state record for func 0x%lx, t=%u:\n",
-		__FUNCTION__, table->segment_base + e->start_offset, sr.when_target);
+		__func__, table->segment_base + e->start_offset, sr.when_target);
 	for (r = sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r) {
 		if (r->where != UNW_WHERE_NONE || r->when != UNW_WHEN_NEVER) {
 			UNW_DPRINT(1, "  %s <- ", unw.preg_name[r - sr.curr.reg]);
@@ -1746,7 +1746,7 @@ run_script (struct unw_script *script, s
 			} else {
 				s[dst] = 0;
 				UNW_DPRINT(0, "unwind.%s: no state->pt, dst=%ld, val=%ld\n",
-					   __FUNCTION__, dst, val);
+					   __func__, dst, val);
 			}
 			break;
 
@@ -1756,7 +1756,7 @@ run_script (struct unw_script *script, s
 			else {
 				s[dst] = 0;
 				UNW_DPRINT(0, "unwind.%s: UNW_INSN_MOVE_CONST bad val=%ld\n",
-					   __FUNCTION__, val);
+					   __func__, val);
 			}
 			break;
 
@@ -1791,7 +1791,7 @@ run_script (struct unw_script *script, s
 			    || s[val] < TASK_SIZE)
 			{
 				UNW_DPRINT(0, "unwind.%s: rejecting bad psp=0x%lx\n",
-					   __FUNCTION__, s[val]);
+					   __func__, s[val]);
 				break;
 			}
 #endif
@@ -1825,7 +1825,7 @@ find_save_locs (struct unw_frame_info *i
 	if ((info->ip & (local_cpu_data->unimpl_va_mask | 0xf)) || info->ip < TASK_SIZE) {
 		/* don't let obviously bad addresses pollute the cache */
 		/* FIXME: should really be level 0 but it occurs too often. KAO */
-		UNW_DPRINT(1, "unwind.%s: rejecting bad ip=0x%lx\n", __FUNCTION__, info->ip);
+		UNW_DPRINT(1, "unwind.%s: rejecting bad ip=0x%lx\n", __func__, info->ip);
 		info->rp_loc = NULL;
 		return -1;
 	}
@@ -1838,7 +1838,7 @@ find_save_locs (struct unw_frame_info *i
 			spin_unlock_irqrestore(&unw.lock, flags);
 			UNW_DPRINT(0,
 				   "unwind.%s: failed to locate/build unwind script for ip %lx\n",
-				   __FUNCTION__, info->ip);
+				   __func__, info->ip);
 			return -1;
 		}
 		have_write_lock = 1;
@@ -1882,21 +1882,21 @@ unw_unwind (struct unw_frame_info *info)
 	if (!unw_valid(info, info->rp_loc)) {
 		/* FIXME: should really be level 0 but it occurs too often. KAO */
 		UNW_DPRINT(1, "unwind.%s: failed to locate return link (ip=0x%lx)!\n",
-			   __FUNCTION__, info->ip);
+			   __func__, info->ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
 	/* restore the ip */
 	ip = info->ip = *info->rp_loc;
 	if (ip < GATE_ADDR) {
-		UNW_DPRINT(2, "unwind.%s: reached user-space (ip=0x%lx)\n", __FUNCTION__, ip);
+		UNW_DPRINT(2, "unwind.%s: reached user-space (ip=0x%lx)\n", __func__, ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
 
 	/* validate the previous stack frame pointer */
 	if (!unw_valid(info, info->pfs_loc)) {
-		UNW_DPRINT(0, "unwind.%s: failed to locate ar.pfs!\n", __FUNCTION__);
+		UNW_DPRINT(0, "unwind.%s: failed to locate ar.pfs!\n", __func__);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1912,13 +1912,13 @@ unw_unwind (struct unw_frame_info *info)
 			num_regs = *info->cfm_loc & 0x7f;		/* size of frame */
 		info->pfs_loc  			(unsigned long *) (info->pt + offsetof(struct pt_regs, ar_pfs));
-		UNW_DPRINT(3, "unwind.%s: interrupt_frame pt 0x%lx\n", __FUNCTION__, info->pt);
+		UNW_DPRINT(3, "unwind.%s: interrupt_frame pt 0x%lx\n", __func__, info->pt);
 	} else
 		num_regs = (*info->cfm_loc >> 7) & 0x7f;	/* size of locals */
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->bsp, -num_regs);
 	if (info->bsp < info->regstk.limit || info->bsp > info->regstk.top) {
 		UNW_DPRINT(0, "unwind.%s: bsp (0x%lx) out of range [0x%lx-0x%lx]\n",
-			__FUNCTION__, info->bsp, info->regstk.limit, info->regstk.top);
+			__func__, info->bsp, info->regstk.limit, info->regstk.top);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1927,14 +1927,14 @@ unw_unwind (struct unw_frame_info *info)
 	info->sp = info->psp;
 	if (info->sp < info->memstk.top || info->sp > info->memstk.limit) {
 		UNW_DPRINT(0, "unwind.%s: sp (0x%lx) out of range [0x%lx-0x%lx]\n",
-			__FUNCTION__, info->sp, info->memstk.top, info->memstk.limit);
+			__func__, info->sp, info->memstk.top, info->memstk.limit);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
 
 	if (info->ip = prev_ip && info->sp = prev_sp && info->bsp = prev_bsp) {
 		UNW_DPRINT(0, "unwind.%s: ip, sp, bsp unchanged; stopping here (ip=0x%lx)\n",
-			   __FUNCTION__, ip);
+			   __func__, ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1961,7 +1961,7 @@ unw_unwind_to_user (struct unw_frame_inf
 		if ((long)((unsigned long)info->task + IA64_STK_OFFSET - sp)
 		    < IA64_PT_REGS_SIZE) {
 			UNW_DPRINT(0, "unwind.%s: ran off the top of the kernel stack\n",
-				   __FUNCTION__);
+				   __func__);
 			break;
 		}
 		if (unw_is_intr_frame(info) &&
@@ -1971,13 +1971,13 @@ unw_unwind_to_user (struct unw_frame_inf
 			unw_get_rp(info, &ip);
 			UNW_DPRINT(0, "unwind.%s: failed to read "
 				   "predicate register (ip=0x%lx)\n",
-				__FUNCTION__, ip);
+				__func__, ip);
 			return -1;
 		}
 	} while (unw_unwind(info) >= 0);
 	unw_get_ip(info, &ip);
 	UNW_DPRINT(0, "unwind.%s: failed to unwind to user-level (ip=0x%lx)\n",
-		   __FUNCTION__, ip);
+		   __func__, ip);
 	return -1;
 }
 EXPORT_SYMBOL(unw_unwind_to_user);
@@ -2028,7 +2028,7 @@ init_frame_info (struct unw_frame_info *
 		   "  pr     0x%lx\n"
 		   "  sw     0x%lx\n"
 		   "  sp     0x%lx\n",
-		   __FUNCTION__, (unsigned long) t, rbslimit, rbstop, stktop, stklimit,
+		   __func__, (unsigned long) t, rbslimit, rbstop, stktop, stklimit,
 		   info->pr, (unsigned long) info->sw, info->sp);
 	STAT(unw.stat.api.init_time += ia64_get_itc() - start; local_irq_restore(flags));
 }
@@ -2047,7 +2047,7 @@ unw_init_frame_info (struct unw_frame_in
 		   "  bsp    0x%lx\n"
 		   "  sol    0x%lx\n"
 		   "  ip     0x%lx\n",
-		   __FUNCTION__, info->bsp, sol, info->ip);
+		   __func__, info->bsp, sol, info->ip);
 	find_save_locs(info);
 }
 
@@ -2058,7 +2058,7 @@ unw_init_from_blocked_task (struct unw_f
 {
 	struct switch_stack *sw = (struct switch_stack *) (t->thread.ksp + 16);
 
-	UNW_DPRINT(1, "unwind.%s\n", __FUNCTION__);
+	UNW_DPRINT(1, "unwind.%s\n", __func__);
 	unw_init_frame_info(info, t, sw);
 }
 EXPORT_SYMBOL(unw_init_from_blocked_task);
@@ -2088,7 +2088,7 @@ unw_add_unwind_table (const char *name, 
 
 	if (end - start <= 0) {
 		UNW_DPRINT(0, "unwind.%s: ignoring attempt to insert empty unwind table\n",
-			   __FUNCTION__);
+			   __func__);
 		return NULL;
 	}
 
@@ -2119,14 +2119,14 @@ unw_remove_unwind_table (void *handle)
 
 	if (!handle) {
 		UNW_DPRINT(0, "unwind.%s: ignoring attempt to remove non-existent unwind table\n",
-			   __FUNCTION__);
+			   __func__);
 		return;
 	}
 
 	table = handle;
 	if (table = &unw.kernel_table) {
 		UNW_DPRINT(0, "unwind.%s: sorry, freeing the kernel's unwind table is a "
-			   "no-can-do!\n", __FUNCTION__);
+			   "no-can-do!\n", __func__);
 		return;
 	}
 
@@ -2139,7 +2139,7 @@ unw_remove_unwind_table (void *handle)
 				break;
 		if (!prev) {
 			UNW_DPRINT(0, "unwind.%s: failed to find unwind table %p\n",
-				   __FUNCTION__, (void *) table);
+				   __func__, (void *) table);
 			spin_unlock_irqrestore(&unw.lock, flags);
 			return;
 		}
@@ -2185,7 +2185,7 @@ create_gate_table (void)
 		}
 
 	if (!punw) {
-		printk("%s: failed to find gate DSO's unwind table!\n", __FUNCTION__);
+		printk("%s: failed to find gate DSO's unwind table!\n", __func__);
 		return 0;
 	}
 
@@ -2202,7 +2202,7 @@ create_gate_table (void)
 	unw.gate_table = kmalloc(size, GFP_KERNEL);
 	if (!unw.gate_table) {
 		unw.gate_table_size = 0;
-		printk(KERN_ERR "%s: unable to create unwind data for gate page!\n", __FUNCTION__);
+		printk(KERN_ERR "%s: unable to create unwind data for gate page!\n", __func__);
 		return 0;
 	}
 	unw.gate_table_size = size;
diff -puN arch/ia64/mm/init.c~ia64-remove-remaining-__function__-occurences arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/mm/init.c
@@ -714,7 +714,7 @@ int arch_add_memory(int nid, u64 start, 
 
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
-		       __FUNCTION__,  ret);
+		       __func__,  ret);
 
 	return ret;
 }
diff -puN arch/ia64/pci/pci.c~ia64-remove-remaining-__function__-occurences arch/ia64/pci/pci.c
--- a/arch/ia64/pci/pci.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/pci/pci.c
@@ -765,7 +765,7 @@ static void __init set_pci_cacheline_siz
 	status = ia64_pal_cache_summary(&levels, &unique_caches);
 	if (status != 0) {
 		printk(KERN_ERR "%s: ia64_pal_cache_summary() failed "
-			"(status=%ld)\n", __FUNCTION__, status);
+			"(status=%ld)\n", __func__, status);
 		return;
 	}
 
@@ -773,7 +773,7 @@ static void __init set_pci_cacheline_siz
 				/* cache_type (data_or_unified)= */ 2, &cci);
 	if (status != 0) {
 		printk(KERN_ERR "%s: ia64_pal_cache_config_info() failed "
-			"(status=%ld)\n", __FUNCTION__, status);
+			"(status=%ld)\n", __func__, status);
 		return;
 	}
 	pci_cache_line_size = (1 << cci.pcci_line_size) / 4;
diff -puN arch/ia64/sn/kernel/huberror.c~ia64-remove-remaining-__function__-occurences arch/ia64/sn/kernel/huberror.c
--- a/arch/ia64/sn/kernel/huberror.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/sn/kernel/huberror.c
@@ -37,7 +37,7 @@ static irqreturn_t hub_eint_handler(int 
 			(u64) nasid, 0, 0, 0, 0, 0, 0);
 
 		if ((int)ret_stuff.v0)
-			panic("%s: Fatal %s Error", __FUNCTION__,
+			panic("%s: Fatal %s Error", __func__,
 				((nasid & 1) ? "TIO" : "HUBII"));
 
 		if (!(nasid & 1)) /* Not a TIO, handle CRB errors */
@@ -48,7 +48,7 @@ static irqreturn_t hub_eint_handler(int 
 				(u64) nasid, 0, 0, 0, 0, 0, 0);
 
 			if ((int)ret_stuff.v0)
-				panic("%s: Fatal TIO Error", __FUNCTION__);
+				panic("%s: Fatal TIO Error", __func__);
 		} else
 			bte_error_handler((unsigned long)NODEPDA(nasid_to_cnodeid(nasid)));
 
diff -puN arch/ia64/sn/kernel/io_acpi_init.c~ia64-remove-remaining-__function__-occurences arch/ia64/sn/kernel/io_acpi_init.c
--- a/arch/ia64/sn/kernel/io_acpi_init.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/sn/kernel/io_acpi_init.c
@@ -133,7 +133,7 @@ sn_get_bussoft_ptr(struct pci_bus *bus)
 	if (ACPI_FAILURE(status)) {
 		printk(KERN_ERR "%s: "
 		       "acpi_get_vendor_resource() failed (0x%x) for: ",
-		       __FUNCTION__, status);
+		       __func__, status);
 		acpi_ns_print_node_pathname(handle, NULL);
 		printk("\n");
 		return NULL;
@@ -145,7 +145,7 @@ sn_get_bussoft_ptr(struct pci_bus *bus)
 	     sizeof(struct pcibus_bussoft *)) {
 		printk(KERN_ERR
 		       "%s: Invalid vendor data length %d\n",
-			__FUNCTION__, vendor->byte_length);
+			__func__, vendor->byte_length);
 		kfree(buffer.pointer);
 		return NULL;
 	}
@@ -184,7 +184,7 @@ sn_extract_device_info(acpi_handle handl
 	if (ACPI_FAILURE(status)) {
 		printk(KERN_ERR
 		       "%s: acpi_get_vendor_resource() failed (0x%x) for: ",
-		        __FUNCTION__, status);
+		        __func__, status);
 		acpi_ns_print_node_pathname(handle, NULL);
 		printk("\n");
 		return 1;
@@ -196,7 +196,7 @@ sn_extract_device_info(acpi_handle handl
 	    sizeof(struct pci_devdev_info *)) {
 		printk(KERN_ERR
 		       "%s: Invalid vendor data length: %d for: ",
-		        __FUNCTION__, vendor->byte_length);
+		        __func__, vendor->byte_length);
 		acpi_ns_print_node_pathname(handle, NULL);
 		printk("\n");
 		ret = 1;
@@ -205,7 +205,7 @@ sn_extract_device_info(acpi_handle handl
 
 	pcidev_ptr = kzalloc(sizeof(struct pcidev_info), GFP_KERNEL);
 	if (!pcidev_ptr)
-		panic("%s: Unable to alloc memory for pcidev_info", __FUNCTION__);
+		panic("%s: Unable to alloc memory for pcidev_info", __func__);
 
 	memcpy(&addr, vendor->byte_data, sizeof(struct pcidev_info *));
 	pcidev_prom_ptr = __va(addr);
@@ -214,7 +214,7 @@ sn_extract_device_info(acpi_handle handl
 	/* Get the IRQ info */
 	irq_info = kzalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
 	if (!irq_info)
-		 panic("%s: Unable to alloc memory for sn_irq_info", __FUNCTION__);
+		 panic("%s: Unable to alloc memory for sn_irq_info", __func__);
 
 	if (pcidev_ptr->pdi_sn_irq_info) {
 		irq_info_prom = __va(pcidev_ptr->pdi_sn_irq_info);
@@ -249,10 +249,10 @@ get_host_devfn(acpi_handle device_handle
 		status = acpi_get_parent(child, &parent);
 		if (ACPI_FAILURE(status)) {
 			printk(KERN_ERR "%s: acpi_get_parent() failed "
-			       "(0x%x) for: ", __FUNCTION__, status);
+			       "(0x%x) for: ", __func__, status);
 			acpi_ns_print_node_pathname(child, NULL);
 			printk("\n");
-			panic("%s: Unable to find host devfn\n", __FUNCTION__);
+			panic("%s: Unable to find host devfn\n", __func__);
 		}
 		if (parent = rootbus_handle)
 			break;
@@ -260,7 +260,7 @@ get_host_devfn(acpi_handle device_handle
 	}
 	if (!child) {
 		printk(KERN_ERR "%s: Unable to find root bus for: ",
-		       __FUNCTION__);
+		       __func__);
 		acpi_ns_print_node_pathname(device_handle, NULL);
 		printk("\n");
 		BUG();
@@ -269,10 +269,10 @@ get_host_devfn(acpi_handle device_handle
 	status = acpi_evaluate_integer(child, METHOD_NAME__ADR, NULL, &adr);
 	if (ACPI_FAILURE(status)) {
 		printk(KERN_ERR "%s: Unable to get _ADR (0x%x) for: ",
-		       __FUNCTION__, status);
+		       __func__, status);
 		acpi_ns_print_node_pathname(child, NULL);
 		printk("\n");
-		panic("%s: Unable to find host devfn\n", __FUNCTION__);
+		panic("%s: Unable to find host devfn\n", __func__);
 	}
 
 	slot = (adr >> 16) & 0xffff;
@@ -308,7 +308,7 @@ find_matching_device(acpi_handle handle,
 		if (ACPI_FAILURE(status)) {
 			printk(KERN_ERR
 			       "%s: acpi_get_parent() failed (0x%x) for: ",
-					__FUNCTION__, status);
+					__func__, status);
 			acpi_ns_print_node_pathname(handle, NULL);
 			printk("\n");
 			return AE_OK;
@@ -318,7 +318,7 @@ find_matching_device(acpi_handle handle,
 		if (ACPI_FAILURE(status)) {
 			printk(KERN_ERR
 			  "%s: Failed to find _BBN in parent of: ",
-					__FUNCTION__);
+					__func__);
 			acpi_ns_print_node_pathname(handle, NULL);
 			printk("\n");
 			return AE_OK;
@@ -358,14 +358,14 @@ sn_acpi_get_pcidev_info(struct pci_dev *
 		if (segment != pci_domain_nr(dev)) {
 			printk(KERN_ERR
 			       "%s: Segment number mismatch, 0x%lx vs 0x%x for: ",
-			       __FUNCTION__, segment, pci_domain_nr(dev));
+			       __func__, segment, pci_domain_nr(dev));
 			acpi_ns_print_node_pathname(rootbus_handle, NULL);
 			printk("\n");
 			return 1;
 		}
 	} else {
 		printk(KERN_ERR "%s: Unable to get __SEG from: ",
-		       __FUNCTION__);
+		       __func__);
 		acpi_ns_print_node_pathname(rootbus_handle, NULL);
 		printk("\n");
 		return 1;
@@ -386,7 +386,7 @@ sn_acpi_get_pcidev_info(struct pci_dev *
 	if (!pcidev_match.handle) {
 		printk(KERN_ERR
 		       "%s: Could not find matching ACPI device for %s.\n",
-		       __FUNCTION__, pci_name(dev));
+		       __func__, pci_name(dev));
 		return 1;
 	}
 
@@ -422,7 +422,7 @@ sn_acpi_slot_fixup(struct pci_dev *dev)
 
 	if (sn_acpi_get_pcidev_info(dev, &pcidev_info, &sn_irq_info)) {
 		panic("%s:  Failure obtaining pcidev_info for %s\n",
-		      __FUNCTION__, pci_name(dev));
+		      __func__, pci_name(dev));
 	}
 
 	if (pcidev_info->pdi_pio_mapped_addr[PCI_ROM_RESOURCE]) {
@@ -463,7 +463,7 @@ sn_acpi_bus_fixup(struct pci_bus *bus)
 			printk(KERN_ERR
 			       "%s: 0x%04x:0x%02x Unable to "
 			       "obtain prom_bussoft_ptr\n",
-			       __FUNCTION__, pci_domain_nr(bus), bus->number);
+			       __func__, pci_domain_nr(bus), bus->number);
 			return;
 		}
 		sn_common_bus_fixup(bus, prom_bussoft_ptr);
diff -puN arch/ia64/sn/kernel/io_common.c~ia64-remove-remaining-__function__-occurences arch/ia64/sn/kernel/io_common.c
--- a/arch/ia64/sn/kernel/io_common.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/sn/kernel/io_common.c
@@ -364,7 +364,7 @@ void sn_bus_store_sysdata(struct pci_dev
 
 	element = kzalloc(sizeof(struct sysdata_el), GFP_KERNEL);
 	if (!element) {
-		dev_dbg(&dev->dev, "%s: out of memory!\n", __FUNCTION__);
+		dev_dbg(&dev->dev, "%s: out of memory!\n", __func__);
 		return;
 	}
 	element->sysdata = SN_PCIDEV_INFO(dev);
diff -puN arch/ia64/sn/kernel/io_init.c~ia64-remove-remaining-__function__-occurences arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/sn/kernel/io_init.c
@@ -209,11 +209,11 @@ sn_io_slot_fixup(struct pci_dev *dev)
 
 	pcidev_info = kzalloc(sizeof(struct pcidev_info), GFP_KERNEL);
 	if (!pcidev_info)
-		panic("%s: Unable to alloc memory for pcidev_info", __FUNCTION__);
+		panic("%s: Unable to alloc memory for pcidev_info", __func__);
 
 	sn_irq_info = kzalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
 	if (!sn_irq_info)
-		panic("%s: Unable to alloc memory for sn_irq_info", __FUNCTION__);
+		panic("%s: Unable to alloc memory for sn_irq_info", __func__);
 
 	/* Call to retrieve pci device information needed by kernel. */
 	status = sal_get_pcidev_info((u64) pci_domain_nr(dev),
diff -puN arch/ia64/sn/kernel/mca.c~ia64-remove-remaining-__function__-occurences arch/ia64/sn/kernel/mca.c
--- a/arch/ia64/sn/kernel/mca.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/sn/kernel/mca.c
@@ -100,7 +100,7 @@ sn_platform_plat_specific_err_print(cons
 		if (!newbuf) {
 			mutex_unlock(&sn_oemdata_mutex);
 			printk(KERN_ERR "%s: unable to extend sn_oemdata\n",
-			       __FUNCTION__);
+			       __func__);
 			return 1;
 		}
 		vfree(*sn_oemdata);
diff -puN arch/ia64/sn/pci/pci_dma.c~ia64-remove-remaining-__function__-occurences arch/ia64/sn/pci/pci_dma.c
--- a/arch/ia64/sn/pci/pci_dma.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/sn/pci/pci_dma.c
@@ -116,7 +116,7 @@ void *sn_dma_alloc_coherent(struct devic
 	*dma_handle = provider->dma_map_consistent(pdev, phys_addr, size,
 						   SN_DMA_ADDR_PHYS);
 	if (!*dma_handle) {
-		printk(KERN_ERR "%s: out of ATEs\n", __FUNCTION__);
+		printk(KERN_ERR "%s: out of ATEs\n", __func__);
 		free_pages((unsigned long)cpuaddr, get_order(size));
 		return NULL;
 	}
@@ -179,7 +179,7 @@ dma_addr_t sn_dma_map_single(struct devi
 	phys_addr = __pa(cpu_addr);
 	dma_addr = provider->dma_map(pdev, phys_addr, size, SN_DMA_ADDR_PHYS);
 	if (!dma_addr) {
-		printk(KERN_ERR "%s: out of ATEs\n", __FUNCTION__);
+		printk(KERN_ERR "%s: out of ATEs\n", __func__);
 		return 0;
 	}
 	return dma_addr;
@@ -266,7 +266,7 @@ int sn_dma_map_sg(struct device *dev, st
 						    SN_DMA_ADDR_PHYS);
 
 		if (!sg->dma_address) {
-			printk(KERN_ERR "%s: out of ATEs\n", __FUNCTION__);
+			printk(KERN_ERR "%s: out of ATEs\n", __func__);
 
 			/*
 			 * Free any successfully allocated entries.
diff -puN arch/ia64/sn/pci/tioca_provider.c~ia64-remove-remaining-__function__-occurences arch/ia64/sn/pci/tioca_provider.c
--- a/arch/ia64/sn/pci/tioca_provider.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/sn/pci/tioca_provider.c
@@ -88,7 +88,7 @@ tioca_gart_init(struct tioca_kernel *tio
 		break;
 	default:
 		printk(KERN_ERR "%s:  Invalid CA_APERATURE_SIZE "
-		       "0x%lx\n", __FUNCTION__, (ulong) CA_APERATURE_SIZE);
+		       "0x%lx\n", __func__, (ulong) CA_APERATURE_SIZE);
 		return -1;
 	}
 
@@ -124,7 +124,7 @@ tioca_gart_init(struct tioca_kernel *tio
 	if (!tmp) {
 		printk(KERN_ERR "%s:  Could not allocate "
 		       "%lu bytes (order %d) for GART\n",
-		       __FUNCTION__,
+		       __func__,
 		       tioca_kern->ca_gart_size,
 		       get_order(tioca_kern->ca_gart_size));
 		return -ENOMEM;
@@ -341,7 +341,7 @@ tioca_dma_d48(struct pci_dev *pdev, u64 
 
 	if (node_upper > 64) {
 		printk(KERN_ERR "%s:  coretalk addr 0x%p node id out "
-		       "of range\n", __FUNCTION__, (void *)ct_addr);
+		       "of range\n", __func__, (void *)ct_addr);
 		return 0;
 	}
 
@@ -349,7 +349,7 @@ tioca_dma_d48(struct pci_dev *pdev, u64 
 	if (node_upper != (agp_dma_extn >> CA_AGP_DMA_NODE_ID_SHFT)) {
 		printk(KERN_ERR "%s:  coretalk upper node (%u) "
 		       "mismatch with ca_agp_dma_addr_extn (%lu)\n",
-		       __FUNCTION__,
+		       __func__,
 		       node_upper, (agp_dma_extn >> CA_AGP_DMA_NODE_ID_SHFT));
 		return 0;
 	}
@@ -597,7 +597,7 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 	if (is_shub1() && sn_sal_rev() < 0x0406) {
 		printk
 		    (KERN_ERR "%s:  SGI prom rev 4.06 or greater required "
-		     "for tioca support\n", __FUNCTION__);
+		     "for tioca support\n", __func__);
 		return NULL;
 	}
 
@@ -651,7 +651,7 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 		printk(KERN_WARNING
 		       "%s:  Unable to get irq %d.  "
 		       "Error interrupts won't be routed for TIOCA bus %d\n",
-		       __FUNCTION__, SGI_TIOCA_ERROR,
+		       __func__, SGI_TIOCA_ERROR,
 		       (int)tioca_common->ca_common.bs_persist_busnum);
 
 	sn_set_err_irq_affinity(SGI_TIOCA_ERROR);
diff -puN arch/ia64/sn/pci/tioce_provider.c~ia64-remove-remaining-__function__-occurences arch/ia64/sn/pci/tioce_provider.c
--- a/arch/ia64/sn/pci/tioce_provider.c~ia64-remove-remaining-__function__-occurences
+++ a/arch/ia64/sn/pci/tioce_provider.c
@@ -494,7 +494,7 @@ tioce_dma_unmap(struct pci_dev *pdev, dm
 		if (&map->ce_dmamap_list = &ce_kern->ce_dmamap_list) {
 			printk(KERN_WARNING
 			       "%s:  %s - no map found for bus_addr 0x%lx\n",
-			       __FUNCTION__, pci_name(pdev), bus_addr);
+			       __func__, pci_name(pdev), bus_addr);
 		} else if (--map->refcnt = 0) {
 			for (i = 0; i < map->ate_count; i++) {
 				map->ate_shadow[i] = 0;
@@ -1030,7 +1030,7 @@ tioce_bus_fixup(struct pcibus_bussoft *p
 		       "%s:  Unable to get irq %d.  "
 		       "Error interrupts won't be routed for "
 		       "TIOCE bus %04x:%02x\n",
-		       __FUNCTION__, SGI_PCIASIC_ERROR,
+		       __func__, SGI_PCIASIC_ERROR,
 		       tioce_common->ce_pcibus.bs_persist_segment,
 		       tioce_common->ce_pcibus.bs_persist_busnum);
 
_
