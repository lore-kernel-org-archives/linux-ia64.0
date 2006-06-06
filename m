From: Jes Sorensen <jes@sgi.com>
Date: Tue, 06 Jun 2006 09:15:03 +0000
Subject: Re: [RFC 1/2] Xen/ia64 modified files
Message-Id: <yq0wtbusl0o.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1149275354.5999.83.camel@lappy>
In-Reply-To: <1149275354.5999.83.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Alex" = Alex Williamson <alex.williamson@hp.com> writes:

Alex>    This patch includes only the modifications to existing
Alex> Linux/ia64 files to support both privileged and un-privileged
Alex> guests on Xen/ia64.

Hi Alex,

A few comments:

- There's a lot of function prototypes scattered over the code which
  should be in headers
- Several // commented out cases
- is_running_on_xen() should be done like IS_RUNNING_ON_SIMULATOR() in
  the sn2 tree
- In general I don't like this CONFIG_XEN being added everywhere. It
  would be much nicer if we could seperate the majority of the Xen
  code into a seperate file that is only compiled in when enabled.
- In many cases expanding and using the machvec table would reduce the
  ugliness of the patches. For instance in the dma mapping code,
  simply define a set of Xen specific functions that do all the magic
  stuff nobody else cares about.
- I do not like the fact that the changes to the generic code as so
  Xen specific. It would be much nicer to call into
  hypervisor_init_foo() so if someone wanted to write their own
  hypervisor they could interface to it without us getting another
  round of patches to core code. After all it seems that 2006 is the
  year of hypervisor-du-jour :)

I know the comments seem fairly harsh, but please don't take them
personal. I find a lot of the changes really ugly, but I suspect thats
because it's ported over.

Anyway, hope it's helpful.

Cheers,
Jes


diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/entry.S	Fri Jun 02 09:54:29 2006 -0600
@@ -636,8 +636,11 @@ GLOBAL_ENTRY(ia64_ret_from_syscall)
 	adds r2=PT(R8)+16,sp			// r2 = &pt_regs.r8
 	mov r10=r0				// clear error indication in r10
 (p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
+	;;
+	// don't fall through, ia64_leave_syscall may be #define'd
+	br.cond.sptk.few ia64_leave_syscall
+	;;
 END(ia64_ret_from_syscall)
-	// fall through

Aren't we taking a performance hit here for the general case just to
be able to support Xen. IMHO that should be conditional.

--- a/arch/ia64/kernel/iosapic.c	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/iosapic.c	Fri Jun 02 09:54:29 2006 -0600
@@ -160,6 +160,65 @@ static int iosapic_kmalloc_ok;
 static int iosapic_kmalloc_ok;
 static LIST_HEAD(free_rte_list);
 
+#ifdef CONFIG_XEN
+#include <xen/interface/xen.h>
+#include <xen/interface/physdev.h>
+#include <asm/hypervisor.h>
+static inline unsigned int xen_iosapic_read(char __iomem *iosapic, unsigned int reg)
+{
+	struct physdev_apic apic_op;
+	int ret;
+
+	apic_op.apic_physbase = (unsigned long)iosapic -
+					__IA64_UNCACHED_OFFSET;
+	apic_op.reg = reg;
+	ret = HYPERVISOR_physdev_op(PHYSDEVOP_apic_read, &apic_op);
+	if (ret)
+		return ret;
+	return apic_op.value;
+}
[snip]
+static inline unsigned int iosapic_read(char __iomem *iosapic, unsigned int reg)
+{
+	if (!is_running_on_xen()) {
+		writel(reg, iosapic + IOSAPIC_REG_SELECT);
+		return readl(iosapic + IOSAPIC_WINDOW);
+	} else
+		return xen_iosapic_read(iosapic, reg);
+}

This is where I'd write 'shiver ... barf!' and a couple of other
things unsuitable for email. Magically overloading macros from a
header file. It would be much nicer to put this into the machvec
table or a similar place and stick the Xen specific stuff in a
seperate file.

+/* 16 should be far optimistic value, since only several percpu irqs
+ * are registered early.
+ */
+#define MAX_LATE_IRQ	16
+static struct saved_irq saved_percpu_irqs[MAX_LATE_IRQ];
+static unsigned short late_irq_cnt = 0;
+static unsigned short saved_irq_cnt = 0;
+static int xen_slab_ready = 0;

No need to init with zero, just wastes space in the text segment.

+/*
+ * This is xen version percpu irq registration, which needs bind
+ * to xen specific evtchn sub-system. One trick here is that xen
+ * evtchn binding interface depends on kmalloc because related
+ * port needs to be freed at device/cpu down. So we cache the
+ * registration on BSP before slab is ready and then deal them
+ * at later point. For rest instances happening after slab ready,
+ * we hook them to xen evtchn immediately.
+ *
+ * FIXME: MCA is not supported by far, and thus "nomca" boot param is
+ * required.
+ */
+void
+xen_register_percpu_irq (unsigned int irq, struct irqaction *action, int save)
+{

More stuff for a sepete xen specific file.

+	char name[15];
+	unsigned int cpu = smp_processor_id();
+	int ret = 0;
+
+	if (xen_slab_ready) {
+		switch (irq) {
+		case IA64_TIMER_VECTOR:
+			sprintf(timer_name[cpu], "%s%d", action->name, cpu);
+			ret = bind_virq_to_irqhandler(VIRQ_ITC, cpu,
+				action->handler, action->flags,
+				timer_name[cpu], action->dev_id);
+			printk(KERN_INFO "register VIRQ_ITC (%s) to xen irq (%d)\n", name, ret);

The kernel is 80 columns.

+/* FIXME: There's no obvious point to check whether slab is ready. So
+ * a hack is used here by utilizing a late time hook.
+ */
+extern void (*late_time_init)(void);
+extern char xen_event_callback;
+extern void xen_init_IRQ(void);

postcore initcall perhaps? Oh and of course in a header file.

+DECLARE_PER_CPU(int, ipi_to_irq[NR_IPIS]);
+void xen_smp_intr_init(void)
+{

More for a seperate xen file.

@@ -232,6 +382,10 @@ register_percpu_irq (ia64_vector vec, st
 
 	for (irq = 0; irq < NR_IRQS; ++irq)
 		if (irq_to_vector(irq) = vec) {
+#ifdef CONFIG_XEN
+			if (is_running_on_xen())
+				return xen_register_percpu_irq(vec, action, 1);
+#endif

Maybe one could do some sort of xen_init_core() that included this
instead adding the xen specific callout?

@@ -243,6 +397,21 @@ void __init
 void __init
 init_IRQ (void)
 {
+#ifdef CONFIG_XEN
+	/* Maybe put into platform_irq_init later */
+	if (is_running_on_xen()) {
+		struct callback_register event = {

Ditto

@@ -260,6 +429,37 @@ ia64_send_ipi (int cpu, int vector, int 
 	unsigned long ipi_data;
 	unsigned long phys_cpu_id;
 
+#ifdef CONFIG_XEN
+        if (is_running_on_xen()) {
+		int irq = -1;
+
+		/* TODO: we need to call vcpu_up here */
+		if (unlikely(vector = ap_wakeup_vector)) {
+			extern void xen_send_ipi (int cpu, int vec);

Header file please.

+			xen_send_ipi (cpu, vector);
+			//vcpu_prepare_and_up(cpu);
+			return;
+		}
+
+		switch(vector) {
+		case IA64_IPI_VECTOR:
+			irq = per_cpu(ipi_to_irq, cpu)[IPI_VECTOR];
+			break;
+		case IA64_IPI_RESCHEDULE:
+			irq = per_cpu(ipi_to_irq, cpu)[RESCHEDULE_VECTOR];
+			break;
+		default:
+			printk(KERN_WARNING"Unsupported IPI type 0x%x\n", vector);
+			irq = 0;
+			break;
+		}		
+	
+		BUG_ON(irq < 0);
+		notify_remote_via_irq(irq);
+		return;
+        }
+#endif /* CONFIG_XEN */

Looks like another machvec style candidate.

diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/setup.c	Fri Jun 02 09:54:29 2006 -0600
@@ -61,6 +61,10 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
 #include <asm/system.h>
+#ifdef CONFIG_XEN
+#include <asm/hypervisor.h>
+#endif

Why make the include conditional?

@@ -478,6 +505,25 @@ setup_arch (char **cmdline_p)
 			conswitchp = &vga_con;
 # endif
 	}
+#ifdef CONFIG_XEN
+	if (is_running_on_xen()) {
+		extern shared_info_t *HYPERVISOR_shared_info;
+		extern int xen_init (void);
+
+		xen_init ();

Again make it external? Some sort of hypervisor_init_console() call?

@@ -486,6 +532,7 @@ setup_arch (char **cmdline_p)
 
 	platform_setup(cmdline_p);
 	paging_init();
+	contiguous_bitmap_init(max_pfn);

????? huh?

diff -r 016512c08f6b -r 4489a633a5de arch/ia64/mm/ioremap.c
--- a/arch/ia64/mm/ioremap.c	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/mm/ioremap.c	Fri Jun 02 09:54:29 2006 -0600
@@ -15,6 +15,9 @@ static inline void __iomem *
 static inline void __iomem *
 __ioremap (unsigned long offset, unsigned long size)
 {
+#ifdef CONFIG_XEN
+	offset = HYPERVISOR_ioremap(offset, size);
+#endif

Why not defined it as "HYPERVISOR_IOREMAP_ADJUST(foo)	foo" for the
non hypervisor case?

No studly caps please.

 /* GATT allocation. Returns/accepts GATT kernel virtual address. */
+#ifndef CONFIG_XEN
 #define alloc_gatt_pages(order)		\
 	((char *)__get_free_pages(GFP_KERNEL, (order)))
 #define free_gatt_pages(table, order)	\
 	free_pages((unsigned long)(table), (order))
+#else
+#include <asm/hypervisor.h>
+static inline char*
+alloc_gatt_pages(unsigned int order)
+{
+	unsigned long error;
+	unsigned long ret = __get_free_pages(GFP_KERNEL, (order));
+	if (ret = 0) {
+		goto out;
+	}
+	error = xen_create_contiguous_region(ret, order, 0);

An example of this being too xen specific.

diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/dma-mapping.h
--- a/include/asm-ia64/dma-mapping.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/dma-mapping.h	Fri Jun 02 09:54:29 2006 -0600
@@ -7,7 +7,13 @@
  */
 #include <linux/config.h>
 #include <asm/machvec.h>
+#ifdef CONFIG_XEN
+#include <asm/hypervisor.h> //XXX to compile arch/i386/kernel/swiotlb.c
+                            //    and arch/i386/kernel/pci-dma-xen.c
+#include <asm-i386/mach-xen/asm/swiotlb.h> //XXX to compile arch/i386/kernel/swiotlb.c
+#endif

Pass the barf bucket please!
 
+#ifndef CONFIG_XEN
 #define dma_alloc_coherent	platform_dma_alloc_coherent
 #define dma_alloc_noncoherent	platform_dma_alloc_coherent	/* coherent mem. is cheap */
 #define dma_free_coherent	platform_dma_free_coherent
@@ -21,6 +27,46 @@
 #define dma_sync_single_for_device platform_dma_sync_single_for_device
 #define dma_sync_sg_for_device	platform_dma_sync_sg_for_device
 #define dma_mapping_error	platform_dma_mapping_error
+#else
+int dma_map_sg(struct device *hwdev, struct scatterlist *sg, int nents,
+               enum dma_data_direction direction);
+void dma_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
+                  enum dma_data_direction direction);
+int dma_supported(struct device *dev, u64 mask);

Please use the machvec table appropriately here.

@@ -62,4 +108,27 @@ dma_cache_sync (void *vaddr, size_t size
 
 #define dma_is_consistent(dma_handle)	(1)	/* all we do is coherent memory... */
 
+#ifdef CONFIG_XEN
+// arch/i386/kernel/swiotlb.o requires
+void contiguous_bitmap_init(unsigned long end_pfn);
+
+static inline int
+address_needs_mapping(struct device *hwdev, dma_addr_t addr)
+{
+	dma_addr_t mask = DMA_64BIT_MASK;
+	/* If the device has a mask, use it, otherwise default to 64 bits */
+	if (hwdev && hwdev->dma_mask)
+		mask = *hwdev->dma_mask;
+	return (addr & ~mask) != 0;
+}
+
+static inline int
+range_straddles_page_boundary(void *p, size_t size)
+{
+	extern unsigned long *contiguous_bitmap;
+	return (((((unsigned long)p & ~PAGE_MASK) + size) > PAGE_SIZE) &&
+	        !test_bit(__pa(p) >> PAGE_SHIFT, contiguous_bitmap));
+}
+#endif

These are used by what?

 #endif /* _ASM_IA64_DMA_MAPPING_H */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/gcc_intrin.h
--- a/include/asm-ia64/gcc_intrin.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/gcc_intrin.h	Fri Jun 02 09:54:29 2006 -0600
@@ -26,7 +26,7 @@ extern void ia64_bad_param_for_getreg (v
 
 register unsigned long ia64_r13 asm ("r13") __attribute_used__;
 
-#define ia64_setreg(regnum, val)						\
+#define __ia64_setreg(regnum, val)						\

Mmmm, in general I think going the intrinsics way was a big mistake
which was a path we should never have taken just to support a broken
compiler :( This just makes it even uglier :(

diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/hw_irq.h
--- a/include/asm-ia64/hw_irq.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/hw_irq.h	Fri Jun 02 09:54:29 2006 -0600
@@ -15,7 +15,11 @@
 #include <asm/ptrace.h>
 #include <asm/smp.h>
 
+#ifndef CONFIG_XEN
 typedef u8 ia64_vector;
+#else
+typedef u16 ia64_vector;
+#endif

Whats the justification for this? If it's needed, couldn't we just
make it a u16 table for all cases or is the performance impact severe?

+#ifndef CONFIG_XEN
 static inline void
 hw_resend_irq (struct hw_interrupt_type *h, unsigned int vector)
 {
 	platform_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
 }
+#else
+extern void hw_resend_irq(struct hw_interrupt_type *h, unsigned int i);
+#endif /* CONFIG_XEN */
 
If Xen used the machvec table this would be unnecessary.

diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/io.h
--- a/include/asm-ia64/io.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/io.h	Fri Jun 02 09:54:29 2006 -0600
@@ -71,6 +71,10 @@ extern unsigned int num_io_spaces;
 #include <asm/page.h>
 #include <asm/system.h>
 #include <asm-generic/iomap.h>
+#ifdef CONFIG_XEN
+#include <asm/privop.h>
+#include <asm/hypervisor.h>
+#endif
 
 /*
  * Change virtual addresses to physical addresses and vv.
@@ -95,9 +99,39 @@ extern int valid_mmap_phys_addr_range (u
  * The following two macros are deprecated and scheduled for removal.
  * Please use the PCI-DMA interface defined in <asm/pci.h> instead.
  */
+#ifndef CONFIG_XEN
 #define bus_to_virt	phys_to_virt
 #define virt_to_bus	virt_to_phys
 #define page_to_bus	page_to_phys
+#define page_to_phys(page)		(page_to_pfn(page) << PAGE_SHIFT)
+#define page_to_pseudophys(page)	page_to_phys(page)
+#else
+#define bus_to_virt(bus)	\
+	phys_to_virt(machine_to_phys_for_dma(bus))
+#define virt_to_bus(virt)	\
+	phys_to_machine_for_dma(virt_to_phys(virt))

No thanks! Could we please have this split into two seperate files if
it's needed?

diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/irq.h
--- a/include/asm-ia64/irq.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/irq.h	Fri Jun 02 09:54:29 2006 -0600
@@ -11,8 +11,39 @@
  * 02/29/00     D.Mosberger	moved most things into hw_irq.h
  */
 
+#ifndef CONFIG_XEN
 #define NR_IRQS		256
 #define NR_IRQ_VECTORS	NR_IRQS
+#else

You define the same values for Xen below. Why not just create a
xen_irq.h for the rest and include it where needed.

diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/machvec.h
--- a/include/asm-ia64/machvec.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/machvec.h	Fri Jun 02 09:54:29 2006 -0600
@@ -257,6 +257,21 @@ extern void machvec_init (const char *na
 #  error Unknown configuration.  Update asm-ia64/machvec.h.
 # endif /* CONFIG_IA64_GENERIC */
 
+#ifdef CONFIG_XEN
+# define platform_dma_map_sg		dma_map_sg
+# define platform_dma_unmap_sg		dma_unmap_sg
+# define platform_dma_mapping_error	dma_mapping_error
+# define platform_dma_supported		dma_supported
+# define platform_dma_alloc_coherent	dma_alloc_coherent
+# define platform_dma_free_coherent	dma_free_coherent
+# define platform_dma_map_single	dma_map_single
+# define platform_dma_unmap_single	dma_unmap_single
+# define platform_dma_sync_single_for_cpu \
+					dma_sync_single_for_cpu
+# define platform_dma_sync_single_for_device \
+					dma_sync_single_for_device
+#endif
+

Uh oh! - think I covered this above :)

diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/page.h	Fri Jun 02 09:54:29 2006 -0600
@@ -127,7 +127,6 @@ extern unsigned long max_low_pfn;
 # define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
 #endif
 
-#define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 
@@ -229,4 +228,105 @@ get_order (unsigned long size)
 					 (((current->personality & READ_IMPLIES_EXEC) != 0)	\
 					  ? VM_EXEC : 0))
 
+#ifndef __ASSEMBLY__
+#ifdef CONFIG_XEN
+
+#define INVALID_P2M_ENTRY	(~0UL)
+
+#include <linux/kernel.h>
+#include <asm/hypervisor.h>
+#include <xen/features.h>	// to compile netback, netfront
+typedef unsigned long maddr_t;	// to compile netback, netfront

There is no such thing as a maddr_t in the kernel and there never
should be! typedefs were invented by the evil empire which is just out
to get us! Please teach the Xen community to write code instead :)

+// XXX hack!
+//     Linux/IA64 uses PG_arch_1.
+//     This hack will be removed once PG_foreign bit is taken.
+//#include <xen/foreign_page.h>
+#ifdef __ASM_XEN_FOREIGN_PAGE_H__
+# error "don't include include/xen/foreign_page.h!"
+#endif

I am somewhat concerned about the excessive number of #include's added
to core header files like page.h

+extern struct address_space xen_ia64_foreign_dummy_mapping;
+#define PageForeign(page)	\
+	((page)->mapping = &xen_ia64_foreign_dummy_mapping)

Barf!

+#define HAVE_ARCH_FREE_PAGE
+
+//XXX xen page size != page size

Why?

+static inline unsigned long
+mfn_to_pfn_for_dma(unsigned long mfn)
+{
+	unsigned long pfn;
+	pfn = HYPERVISOR_machtophys(mfn);

StUdLyCaPsMeHaRdEr!

