From: Fengguang Wu <fengguang.wu@intel.com>
Date: Tue, 17 Jul 2012 12:32:33 +0000
Subject: ia64 build errors
Message-Id: <20120717123233.GA17001@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Tony,

I've kicked off IA64 build tests on a native IA64 box and the test
kconfigs are:

 ia64-allmodconfig
 ia64-allnoconfig
 ia64-defconfig
 ia64-randconfig-h001
 ...
 ia64-randconfig-h009

Only the allnoconfig and defconfig builds fine. The other ones mostly failed in two errors:

1)

In file included from include/linux/kernel.h:22:0,
                 from include/asm-generic/bug.h:13,
                 from arch/ia64/include/asm/bug.h:12,
                 from include/linux/bug.h:4,
                 from include/linux/page-flags.h:9,
                 from kernel/bounds.c:9:
include/linux/printk.h:142:5: error: static declaration of 'printk' follows non-static declaration
In file included from include/linux/bitops.h:22:0,
                 from include/linux/kernel.h:19,
                 from include/asm-generic/bug.h:13,
                 from arch/ia64/include/asm/bug.h:12,
                 from include/linux/bug.h:4,
                 from include/linux/page-flags.h:9,
                 from kernel/bounds.c:9:
arch/ia64/include/asm/bitops.h:313:3: note: previous declaration of 'printk' was here

2)

In file included from arch/ia64/kernel/asm-offsets.c:9:0:
include/linux/sched.h: In function 'stack_not_used':
include/linux/sched.h:2519:21: error: 'IA64_TASK_SIZE' undeclared (first use in this function)
include/linux/sched.h:2519:21: note: each undeclared identifier is reported only once for each function it appears in
include/linux/sched.h:2519:21: error: 'IA64_THREAD_INFO_SIZE' undeclared (first use in this function)

3) and one randconfig failed with lots of undefined symbols (attached).

Thanks,
Fengguang

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=15994-14061

arch/ia64/kernel/built-in.o: In function `lsapic_retrigger': irq_lsapic.c:(.text+0x6521): undefined reference to `pv_irq_ops'
irq_lsapic.c:(.text+0x6540): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `pfm_load_regs': (.text+0x1fe50): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `pfm_load_regs': (.text+0x1fe60): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `pfm_init_percpu': (.text+0x20550): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o:(.text+0x20560): more undefined references to `pv_irq_ops' follow
arch/ia64/kernel/built-in.o: In function `timer_interrupt': time.c:(.text+0x2f790): undefined reference to `pv_time_ops'
time.c:(.text+0x2f7b0): undefined reference to `pv_time_ops'
time.c:(.text+0x2fb40): undefined reference to `pv_time_ops'
time.c:(.text+0x2fb51): undefined reference to `pv_time_ops'
arch/ia64/kernel/built-in.o: In function `mask_irq': iosapic.c:(.text+0x4e251): undefined reference to `pv_iosapic_ops'
iosapic.c:(.text+0x4e281): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o: In function `unmask_irq': iosapic.c:(.text+0x4e411): undefined reference to `pv_iosapic_ops'
iosapic.c:(.text+0x4e441): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o: In function `register_intr': iosapic.c:(.text+0x4eb10): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o:iosapic.c:(.text+0x4eb20): more undefined references to `pv_iosapic_ops' follow
arch/ia64/kernel/built-in.o: In function `iosapic_register_intr': (.text+0x4f670): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `iosapic_register_intr': (.text+0x4f680): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `iosapic_unregister_intr': (.text+0x4fc30): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o: In function `iosapic_unregister_intr': (.text+0x4fc40): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o: In function `ia64_msi_retrigger_irq': msi_ia64.c:(.text+0x50ea1): undefined reference to `pv_irq_ops'
msi_ia64.c:(.text+0x50ec1): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `init_IRQ': (.init.text+0x11e1): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `init_IRQ': (.init.text+0x1200): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `filter_rsvd_memory': (.init.text+0x32c2): undefined reference to `call_pernode_memory'
arch/ia64/kernel/built-in.o: In function `filter_memory': (.init.text+0x33f2): undefined reference to `call_pernode_memory'
arch/ia64/kernel/built-in.o: In function `reserve_memory': (.init.text+0x3580): undefined reference to `pv_init_ops'
arch/ia64/kernel/built-in.o: In function `reserve_memory': (.init.text+0x3590): undefined reference to `pv_init_ops'
arch/ia64/kernel/built-in.o: In function `setup_arch': (.init.text+0x38c0): undefined reference to `pv_init_ops'
arch/ia64/kernel/built-in.o: In function `setup_arch': (.init.text+0x38c1): undefined reference to `pv_init_ops'
arch/ia64/kernel/built-in.o: In function `time_init': (.init.text+0x3ee1): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `time_init': (.init.text+0x3f01): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `ia64_mca_late_init': mca.c:(.init.text+0x4e20): undefined reference to `pv_irq_ops'
mca.c:(.init.text+0x4e40): undefined reference to `pv_irq_ops'
arch/ia64/kernel/built-in.o: In function `iosapic_system_init': (.init.text+0x8862): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o: In function `iosapic_system_init': (.init.text+0x8890): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o: In function `set_rte': iosapic.c:(.text.unlikely+0x8d0): undefined reference to `pv_iosapic_ops'
iosapic.c:(.text.unlikely+0x8f0): undefined reference to `pv_iosapic_ops'
iosapic.c:(.text.unlikely+0x970): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o:iosapic.c:(.text.unlikely+0x990): more undefined references to `pv_iosapic_ops' follow
arch/ia64/kernel/built-in.o: In function `ia64_init_itm': (.devinit.text+0x652): undefined reference to `pv_time_ops'
arch/ia64/kernel/built-in.o: In function `ia64_init_itm': (.devinit.text+0x671): undefined reference to `pv_time_ops'
arch/ia64/kernel/built-in.o: In function `iosapic_init': (.devinit.text+0xcf0): undefined reference to `pv_iosapic_ops'
arch/ia64/kernel/built-in.o: In function `iosapic_init': (.devinit.text+0xcf1): undefined reference to `pv_iosapic_ops'
arch/ia64/mm/built-in.o: In function `__ia64_sync_icache_dcache': (.text+0x2): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `__ia64_sync_icache_dcache': (.text+0x11): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `dma_mark_clean': (.text+0x1a1): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `dma_mark_clean': (.text+0x1c0): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `free_initmem': (.text+0x841): undefined reference to `mem_map'
arch/ia64/mm/built-in.o:(.text+0x861): more undefined references to `mem_map' follow
arch/ia64/mm/built-in.o: In function `show_mem': (.text+0x4171): undefined reference to `max_mapnr'
arch/ia64/mm/built-in.o: In function `show_mem': (.text+0x4180): undefined reference to `max_mapnr'
arch/ia64/mm/built-in.o: In function `show_mem': (.text+0x4190): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `show_mem': (.text+0x41b0): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `count_reserved_pages': init.c:(.init.text+0x0): undefined reference to `mem_map'
init.c:(.init.text+0x20): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `put_kernel_page': init.c:(.init.text+0x1d0): undefined reference to `mem_map'
arch/ia64/mm/built-in.o:init.c:(.init.text+0x1e0): more undefined references to `mem_map' follow
arch/ia64/mm/built-in.o: In function `free_initrd_mem': (.init.text+0x9f0): undefined reference to `max_mapnr'
arch/ia64/mm/built-in.o: In function `free_initrd_mem': (.init.text+0x9f1): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `free_initrd_mem': (.init.text+0xa11): undefined reference to `max_mapnr'
arch/ia64/mm/built-in.o: In function `free_initrd_mem': (.init.text+0xa20): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `mem_init': (.init.text+0xb40): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `mem_init': (.init.text+0xb41): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `mem_init': (.init.text+0xbb1): undefined reference to `max_mapnr'
arch/ia64/mm/built-in.o: In function `mem_init': (.init.text+0xbd1): undefined reference to `max_mapnr'
arch/ia64/mm/built-in.o: In function `paging_init': (.init.text+0x1530): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `paging_init': (.init.text+0x1541): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `virtual_memmap_init': init.c:(.meminit.text+0x140): undefined reference to `mem_map'
init.c:(.meminit.text+0x161): undefined reference to `mem_map'
arch/ia64/mm/built-in.o: In function `memmap_init': (.meminit.text+0x2e0): undefined reference to `mem_map'
arch/ia64/mm/built-in.o:(.meminit.text+0x300): more undefined references to `mem_map' follow
mm/built-in.o: In function `move_freepages_block': page_alloc.c:(.text+0xaef1): undefined reference to `max_mapnr'
page_alloc.c:(.text+0xaf20): undefined reference to `max_mapnr'
mm/built-in.o: In function `__get_free_pages': (.text+0xcb40): undefined reference to `mem_map'
mm/built-in.o: In function `__get_free_pages': (.text+0xcb50): undefined reference to `mem_map'
mm/built-in.o: In function `get_pageblock_flags_group': (.text+0xe2c0): undefined reference to `mem_map'
mm/built-in.o: In function `get_pageblock_flags_group': (.text+0xe2e0): undefined reference to `mem_map'
mm/built-in.o: In function `__count_immobile_pages.constprop.57': page_alloc.c:(.text+0xe4e0): undefined reference to `mem_map'
page_alloc.c:(.text+0xe4e1): undefined reference to `max_mapnr'
page_alloc.c:(.text+0xe500): undefined reference to `mem_map'
page_alloc.c:(.text+0xe511): undefined reference to `max_mapnr'
mm/built-in.o: In function `set_pageblock_flags_group': (.text+0xe780): undefined reference to `mem_map'
mm/built-in.o: In function `set_pageblock_flags_group': (.text+0xe7a0): undefined reference to `mem_map'
mm/built-in.o: In function `setup_per_zone_wmarks': (.text+0xeae0): undefined reference to `max_mapnr'
mm/built-in.o: In function `setup_per_zone_wmarks': (.text+0xeb00): undefined reference to `max_mapnr'
mm/built-in.o: In function `setup_per_zone_wmarks': (.text+0xeb10): undefined reference to `mem_map'
mm/built-in.o: In function `setup_per_zone_wmarks': (.text+0xeb30): undefined reference to `mem_map'
mm/built-in.o: In function `is_pageblock_removable_nolock': (.text+0xfcd1): undefined reference to `mem_map'
mm/built-in.o: In function `is_pageblock_removable_nolock': (.text+0xfd70): undefined reference to `mem_map'
mm/built-in.o: In function `bad_page': page_alloc.c:(.text+0x102e1): undefined reference to `mem_map'
mm/built-in.o:page_alloc.c:(.text+0x10310): more undefined references to `mem_map' follow
mm/built-in.o: In function `free_pcppages_bulk': page_alloc.c:(.text+0x11cc2): undefined reference to `max_mapnr'
page_alloc.c:(.text+0x11d00): undefined reference to `mem_map'
page_alloc.c:(.text+0x11d20): undefined reference to `max_mapnr'
mm/built-in.o: In function `free_one_page': page_alloc.c:(.text+0x13ed1): undefined reference to `mem_map'
page_alloc.c:(.text+0x13ee2): undefined reference to `max_mapnr'
page_alloc.c:(.text+0x13ef1): undefined reference to `mem_map'
page_alloc.c:(.text+0x13f01): undefined reference to `max_mapnr'
page_alloc.c:(.text+0x145f2): undefined reference to `mem_map'
page_alloc.c:(.text+0x14600): undefined reference to `max_mapnr'
page_alloc.c:(.text+0x14601): undefined reference to `mem_map'
page_alloc.c:(.text+0x14610): undefined reference to `max_mapnr'
mm/built-in.o: In function `free_pages': (.text+0x154d0): undefined reference to `mem_map'
mm/built-in.o: In function `free_pages': (.text+0x154e0): undefined reference to `mem_map'
mm/built-in.o: In function `make_alloc_exact': page_alloc.c:(.text+0x15550): undefined reference to `mem_map'
page_alloc.c:(.text+0x15580): undefined reference to `mem_map'
mm/built-in.o: In function `alloc_pages_exact_nid': (.text+0x15881): undefined reference to `mem_map'
mm/built-in.o:(.text+0x158b0): more undefined references to `mem_map' follow
mm/built-in.o: In function `pagetypeinfo_showblockcount_print': vmstat.c:(.text+0x324b1): undefined reference to `max_mapnr'
vmstat.c:(.text+0x324b2): undefined reference to `mem_map'
vmstat.c:(.text+0x324f0): undefined reference to `max_mapnr'
vmstat.c:(.text+0x32501): undefined reference to `mem_map'
mm/built-in.o: In function `start_isolate_page_range': (.text+0x355a1): undefined reference to `max_mapnr'
mm/built-in.o: In function `start_isolate_page_range': (.text+0x355b0): undefined reference to `mem_map'
mm/built-in.o: In function `start_isolate_page_range': (.text+0x35600): undefined reference to `max_mapnr'
mm/built-in.o: In function `start_isolate_page_range': (.text+0x35601): undefined reference to `mem_map'
mm/built-in.o: In function `start_isolate_page_range': (.text+0x35692): undefined reference to `mem_map'
mm/built-in.o: In function `start_isolate_page_range': (.text+0x356a1): undefined reference to `mem_map'
mm/built-in.o: In function `undo_isolate_page_range': (.text+0x358a1): undefined reference to `max_mapnr'
mm/built-in.o: In function `undo_isolate_page_range': (.text+0x358b0): undefined reference to `mem_map'
mm/built-in.o: In function `undo_isolate_page_range': (.text+0x35900): undefined reference to `max_mapnr'
mm/built-in.o: In function `undo_isolate_page_range': (.text+0x35901): undefined reference to `mem_map'
mm/built-in.o: In function `test_pages_isolated': (.text+0x35b21): undefined reference to `max_mapnr'
mm/built-in.o: In function `test_pages_isolated': (.text+0x35b30): undefined reference to `mem_map'
mm/built-in.o: In function `test_pages_isolated': (.text+0x35b40): undefined reference to `max_mapnr'
mm/built-in.o: In function `test_pages_isolated': (.text+0x35b51): undefined reference to `mem_map'
mm/built-in.o: In function `test_pages_isolated': (.text+0x35c70): undefined reference to `max_mapnr'
mm/built-in.o: In function `test_pages_isolated': (.text+0x35c90): undefined reference to `max_mapnr'
mm/built-in.o: In function `test_pages_isolated': (.text+0x35cf0): undefined reference to `mem_map'
mm/built-in.o: In function `test_pages_isolated': (.text+0x35d10): undefined reference to `mem_map'
mm/built-in.o: In function `pcpu_alloc': percpu.c:(.text+0x38532): undefined reference to `mem_map'
percpu.c:(.text+0x38590): undefined reference to `mem_map'
percpu.c:(.text+0x38990): undefined reference to `mem_map'
mm/built-in.o:percpu.c:(.text+0x389a0): more undefined references to `mem_map' follow
mm/built-in.o: In function `isolate_freepages_block': compaction.c:(.text+0x39a11): undefined reference to `max_mapnr'
compaction.c:(.text+0x39a20): undefined reference to `mem_map'
compaction.c:(.text+0x39a40): undefined reference to `max_mapnr'
mm/built-in.o: In function `compaction_alloc': compaction.c:(.text+0x39db1): undefined reference to `max_mapnr'
compaction.c:(.text+0x39db2): undefined reference to `mem_map'
compaction.c:(.text+0x39e31): undefined reference to `max_mapnr'
compaction.c:(.text+0x39e41): undefined reference to `mem_map'
mm/built-in.o: In function `isolate_freepages_range': (.text+0x3a170): undefined reference to `max_mapnr'
mm/built-in.o: In function `isolate_freepages_range': (.text+0x3a181): undefined reference to `max_mapnr'
mm/built-in.o: In function `isolate_freepages_range': (.text+0x3a1d2): undefined reference to `mem_map'
mm/built-in.o: In function `isolate_freepages_range': (.text+0x3a201): undefined reference to `mem_map'
mm/built-in.o: In function `isolate_freepages_range': (.text+0x3a480): undefined reference to `mem_map'
mm/built-in.o: In function `isolate_freepages_range': (.text+0x3a490): undefined reference to `mem_map'
mm/built-in.o: In function `isolate_migratepages_range': (.text+0x3a622): undefined reference to `mem_map'
mm/built-in.o: In function `isolate_migratepages_range': (.text+0x3a630): undefined reference to `max_mapnr'
mm/built-in.o: In function `isolate_migratepages_range': (.text+0x3a681): undefined reference to `mem_map'
mm/built-in.o: In function `isolate_migratepages_range': (.text+0x3a691): undefined reference to `max_mapnr'
mm/built-in.o: In function `isolate_migratepages_range': (.text+0x3a701): undefined reference to `max_mapnr'
mm/built-in.o: In function `isolate_migratepages_range': (.text+0x3a710): undefined reference to `max_mapnr'
mm/built-in.o: In function `isolate_migratepages_range': (.text+0x3ab21): undefined reference to `max_mapnr'
mm/built-in.o: In function `isolate_migratepages_range': (.text+0x3ab31): undefined reference to `max_mapnr'
mm/built-in.o:compaction.c:(.text+0x3b222): more undefined references to `max_mapnr' follow
mm/built-in.o: In function `__do_fault': memory.c:(.text+0x3d9a0): undefined reference to `mem_map'
memory.c:(.text+0x3d9e0): undefined reference to `mem_map'
memory.c:(.text+0x3de50): undefined reference to `mem_map'
memory.c:(.text+0x3de60): undefined reference to `mem_map'
mm/built-in.o: In function `free_pgd_range': (.text+0x3e5a1): undefined reference to `mem_map'
mm/built-in.o:(.text+0x3e630): more undefined references to `mem_map' follow
mm/built-in.o: In function `vm_normal_page': (.text+0x3f4e0): undefined reference to `max_mapnr'
mm/built-in.o: In function `vm_normal_page': (.text+0x3f4f0): undefined reference to `max_mapnr'
mm/built-in.o: In function `vm_normal_page': (.text+0x3f520): undefined reference to `mem_map'
mm/built-in.o: In function `vm_normal_page': (.text+0x3f540): undefined reference to `mem_map'
mm/built-in.o: In function `do_wp_page.isra.65': memory.c:(.text+0x3f9b0): undefined reference to `mem_map'
memory.c:(.text+0x3f9c0): undefined reference to `mem_map'
memory.c:(.text+0x3fc90): undefined reference to `mem_map'
mm/built-in.o:memory.c:(.text+0x3fca0): more undefined references to `mem_map' follow
mm/built-in.o: In function `vm_insert_pfn': (.text+0x45c60): undefined reference to `max_mapnr'
mm/built-in.o: In function `vm_insert_pfn': (.text+0x45c61): undefined reference to `max_mapnr'
mm/built-in.o: In function `insert_page': memory.c:(.text+0x45f80): undefined reference to `mem_map'
memory.c:(.text+0x45f90): undefined reference to `mem_map'
memory.c:(.text+0x46140): undefined reference to `mem_map'
memory.c:(.text+0x46150): undefined reference to `mem_map'
mm/built-in.o: In function `vm_insert_mixed': (.text+0x46372): undefined reference to `max_mapnr'
mm/built-in.o: In function `vm_insert_mixed': (.text+0x463e0): undefined reference to `max_mapnr'
mm/built-in.o: In function `vm_insert_mixed': (.text+0x46470): undefined reference to `mem_map'
mm/built-in.o: In function `vm_insert_mixed': (.text+0x46491): undefined reference to `mem_map'
mm/built-in.o: In function `__get_user_pages': (.text+0x46f00): undefined reference to `mem_map'
mm/built-in.o: In function `__get_user_pages': (.text+0x46fd0): undefined reference to `mem_map'
mm/built-in.o: In function `__access_remote_vm': memory.c:(.text+0x47b71): undefined reference to `mem_map'
mm/built-in.o:memory.c:(.text+0x47b81): more undefined references to `mem_map' follow
fs/built-in.o: In function `kpagecount_read': page.c:(.text+0xd84a2): undefined reference to `max_mapnr'
page.c:(.text+0xd84b1): undefined reference to `mem_map'
page.c:(.text+0xd84d1): undefined reference to `max_mapnr'
page.c:(.text+0xd84e1): undefined reference to `mem_map'
fs/built-in.o: In function `kpageflags_read': page.c:(.text+0xd8b62): undefined reference to `max_mapnr'
page.c:(.text+0xd8b71): undefined reference to `mem_map'
page.c:(.text+0xd8b90): undefined reference to `max_mapnr'
page.c:(.text+0xd8ba1): undefined reference to `mem_map'
fs/built-in.o: In function `_get_block_create_0': inode.c:(.text+0x111fb0): undefined reference to `mem_map'
inode.c:(.text+0x111fd0): undefined reference to `mem_map'
fs/built-in.o: In function `reiserfs_truncate_file': (.text+0x1142d0): undefined reference to `mem_map'
fs/built-in.o: In function `reiserfs_truncate_file': (.text+0x1142e0): undefined reference to `mem_map'
fs/built-in.o:inode.c:(.text+0x11bef0): more undefined references to `mem_map' follow
drivers/built-in.o: In function `wmi_wmmx_mxmi': nouveau_mxm.c:(.text+0x395642): undefined reference to `wmi_evaluate_method'
drivers/built-in.o: In function `mxm_shadow_wmi': nouveau_mxm.c:(.text+0x3959f2): undefined reference to `wmi_has_guid'
nouveau_mxm.c:(.text+0x395ac2): undefined reference to `wmi_evaluate_method'
drivers/built-in.o: In function `nouveau_dsm_detect': nouveau_acpi.c:(.text+0x4aa7c2): undefined reference to `mxm_wmi_supported'
drivers/built-in.o: In function `firmware_data_read': firmware_class.c:(.text+0x4da940): undefined reference to `mem_map'
firmware_class.c:(.text+0x4da951): undefined reference to `mem_map'
drivers/built-in.o: In function `firmware_data_write': firmware_class.c:(.text+0x4dae40): undefined reference to `mem_map'
firmware_class.c:(.text+0x4dae61): undefined reference to `mem_map'
drivers/built-in.o: In function `ide_pio_bytes': (.text+0x528821): undefined reference to `mem_map'
drivers/built-in.o:(.text+0x528871): more undefined references to `mem_map' follow

--2oS5YaxWCcQjTEyO--
