From: Andreas Schwab <schwab@suse.de>
Date: Fri, 23 Aug 2002 10:10:55 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.19)
Message-Id: <marc-linux-ia64-105590701905978@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi!

Here is a patch to kill many warnings.

--- linux/arch/ia64/hp/common/sba_iommu.c.~1~
+++ linux/arch/ia64/hp/common/sba_iommu.c
@@ -626,7 +626,7 @@ mark_clean (void *addr, size_t size)
 	pg_addr =3D PAGE_ALIGN((unsigned long) addr);
 	end =3D (unsigned long) addr + size;
 	while (pg_addr + PAGE_SIZE <=3D end) {
-		struct page *page =3D virt_to_page(pg_addr);
+		struct page *page =3D virt_to_page((void *)pg_addr);
 		set_bit(PG_arch_1, &page->flags);
 		pg_addr +=3D PAGE_SIZE;
 	}
--- linux/arch/ia64/kernel/machvec.c.~1~
+++ linux/arch/ia64/kernel/machvec.c
@@ -15,7 +15,7 @@ struct ia64_machine_vector ia64_mv;
  * into a memory map index.
  */
 unsigned long
-map_nr_dense (unsigned long addr)
+map_nr_dense (void *addr)
 {
 	return MAP_NR_DENSE(addr);
 }
--- linux/arch/ia64/lib/swiotlb.c.~1~
+++ linux/arch/ia64/lib/swiotlb.c
@@ -351,7 +351,7 @@ mark_clean (void *addr, size_t size)
 	pg_addr =3D PAGE_ALIGN((unsigned long) addr);
 	end =3D (unsigned long) addr + size;
 	while (pg_addr + PAGE_SIZE <=3D end) {
-		struct page *page =3D virt_to_page(pg_addr);
+		struct page *page =3D virt_to_page((void *)pg_addr);
 		set_bit(PG_arch_1, &page->flags);
 		pg_addr +=3D PAGE_SIZE;
 	}
--- linux/arch/ia64/mm/init.c.~1~
+++ linux/arch/ia64/mm/init.c
@@ -114,8 +114,8 @@ free_initmem (void)
=20
 	addr =3D (unsigned long) &__init_begin;
 	for (; addr < (unsigned long) &__init_end; addr +=3D PAGE_SIZE) {
-		clear_bit(PG_reserved, &virt_to_page(addr)->flags);
-		set_page_count(virt_to_page(addr), 1);
+		clear_bit(PG_reserved, &virt_to_page((void *)addr)->flags);
+		set_page_count(virt_to_page((void *)addr), 1);
 		free_page(addr);
 		++totalram_pages;
 	}
@@ -164,10 +164,10 @@ free_initrd_mem(unsigned long start, uns
 		printk(KERN_INFO "Freeing initrd memory: %ldkB freed\n", (end - start) >=
> 10);
=20
 	for (; start < end; start +=3D PAGE_SIZE) {
-		if (!VALID_PAGE(virt_to_page(start)))
+		if (!VALID_PAGE(virt_to_page((void *)start)))
 			continue;
-		clear_bit(PG_reserved, &virt_to_page(start)->flags);
-		set_page_count(virt_to_page(start), 1);
+		clear_bit(PG_reserved, &virt_to_page((void *)start)->flags);
+		set_page_count(virt_to_page((void *)start), 1);
 		free_page(start);
 		++totalram_pages;
 	}
@@ -554,7 +554,7 @@ count_reserved_pages (u64 start, u64 end
 	unsigned long *count =3D arg;
 	struct page *pg;
=20
-	for (pg =3D virt_to_page(start); pg < virt_to_page(end); ++pg)
+	for (pg =3D virt_to_page((void *)start); pg < virt_to_page((void *)end); =
++pg)
 		if (PageReserved(pg))
 			++num_reserved;
 	*count +=3D num_reserved;
--- linux/arch/ia64/sn/kernel/setup.c.~1~
+++ linux/arch/ia64/sn/kernel/setup.c
@@ -137,7 +137,7 @@ char drive_info[4*16];
  * virt_to_page() (asm-ia64/page.h), among other things.
  */
 unsigned long
-sn_map_nr (unsigned long addr)
+sn_map_nr (void *addr)
 {
 	return MAP_NR_DISCONTIG(addr);
 }
--- linux/include/asm-ia64/machvec.h.~1~
+++ linux/include/asm-ia64/machvec.h
@@ -25,7 +25,7 @@ typedef void ia64_mv_cpu_init_t(void);
 typedef void ia64_mv_irq_init_t (void);
 typedef void ia64_mv_pci_fixup_t (int);
 typedef void ia64_mv_pci_enable_device_t (struct pci_dev *);
-typedef unsigned long ia64_mv_map_nr_t (unsigned long);
+typedef unsigned long ia64_mv_map_nr_t (void *);
 typedef void ia64_mv_mca_init_t (void);
 typedef void ia64_mv_mca_handler_t (void);
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

