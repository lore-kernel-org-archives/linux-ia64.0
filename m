From: yuan linyu <cugyly@163.com>
Date: Sat, 07 Apr 2018 01:55:20 +0000
Subject: [RFC linux v2] init: make all setup_arch() output string to boot_command_line[]
Message-Id: <20180407015520.2839-1-cugyly@163.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

then all arch boot parameter handled in the same way in start_kernel()

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
v2:
	fix kbuild issue of parisc

 arch/alpha/kernel/setup.c          |  4 +---
 arch/arc/kernel/setup.c            |  5 +----
 arch/arm/kernel/setup.c            |  7 +------
 arch/arm64/kernel/setup.c          |  4 +---
 arch/c6x/kernel/setup.c            |  5 +----
 arch/h8300/kernel/setup.c          |  3 +--
 arch/hexagon/kernel/setup.c        | 16 +---------------
 arch/ia64/kernel/setup.c           | 15 ++++++++-------
 arch/m68k/kernel/setup_mm.c        |  5 ++---
 arch/m68k/kernel/setup_no.c        |  3 +--
 arch/microblaze/kernel/setup.c     |  4 +---
 arch/mips/kernel/setup.c           | 11 +++--------
 arch/nds32/kernel/setup.c          |  3 +--
 arch/nios2/kernel/setup.c          |  5 +----
 arch/openrisc/kernel/setup.c       |  4 +---
 arch/parisc/kernel/setup.c         | 11 +++--------
 arch/powerpc/kernel/setup-common.c |  4 +---
 arch/riscv/kernel/setup.c          |  4 +---
 arch/s390/kernel/setup.c           |  6 +-----
 arch/sh/kernel/setup.c             |  7 ++++---
 arch/sparc/kernel/setup_32.c       |  9 +++++----
 arch/sparc/kernel/setup_64.c       |  8 ++++----
 arch/um/kernel/um_arch.c           |  3 +--
 arch/unicore32/kernel/setup.c      |  8 +-------
 arch/x86/kernel/setup.c            |  6 +-----
 arch/xtensa/kernel/setup.c         |  9 +++++----
 include/linux/init.h               |  2 +-
 init/main.c                        | 14 +++++++-------
 28 files changed, 60 insertions(+), 125 deletions(-)

diff --git a/arch/alpha/kernel/setup.c b/arch/alpha/kernel/setup.c
index 5576f7646fb6..c74675cf7129 100644
--- a/arch/alpha/kernel/setup.c
+++ b/arch/alpha/kernel/setup.c
@@ -505,8 +505,7 @@ register_cpus(void)
 
 arch_initcall(register_cpus);
 
-void __init
-setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	extern char _end[];
 
@@ -566,7 +565,6 @@ setup_arch(char **cmdline_p)
 		strlcpy(command_line, COMMAND_LINE, sizeof command_line);
 	}
 	strcpy(boot_command_line, command_line);
-	*cmdline_p = command_line;
 
 	/* 
 	 * Process command-line arguments.
diff --git a/arch/arc/kernel/setup.c b/arch/arc/kernel/setup.c
index b2cae79a25d7..9cfdcf42bf28 100644
--- a/arch/arc/kernel/setup.c
+++ b/arch/arc/kernel/setup.c
@@ -456,7 +456,7 @@ static inline int is_kernel(unsigned long addr)
 	return 0;
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 #ifdef CONFIG_ARC_UBOOT_SUPPORT
 	/* make sure that uboot passed pointer to cmdline/dtb is valid */
@@ -487,9 +487,6 @@ void __init setup_arch(char **cmdline_p)
 		}
 	}
 
-	/* Save unparsed command line copy for /proc/cmdline */
-	*cmdline_p = boot_command_line;
-
 	/* To force early parsing of things like mem=xxx */
 	parse_early_param();
 
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index fc40a2b40595..1025e3a37689 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -153,7 +153,6 @@ EXPORT_SYMBOL(elf_platform);
 
 static const char *cpu_name;
 static const char *machine_name;
-static char __initdata cmd_line[COMMAND_LINE_SIZE];
 const struct machine_desc *machine_desc __initdata;
 
 static union { char c[4]; unsigned long l; } endian_test __initdata = { { 'l', '?', '?', 'b' } };
@@ -1061,7 +1060,7 @@ void __init hyp_mode_check(void)
 #endif
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	const struct machine_desc *mdesc;
 
@@ -1091,10 +1090,6 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.end_data   = (unsigned long) _edata;
 	init_mm.brk	   = (unsigned long) _end;
 
-	/* populate cmd_line too for later use, preserving boot_command_line */
-	strlcpy(cmd_line, boot_command_line, COMMAND_LINE_SIZE);
-	*cmdline_p = cmd_line;
-
 	early_fixmap_init();
 	early_ioremap_init();
 
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 30ad2f085d1f..c7ba4d32e7f7 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -243,15 +243,13 @@ static void __init request_standard_resources(void)
 
 u64 __cpu_logical_map[NR_CPUS] = { [0 ... NR_CPUS-1] = INVALID_HWID };
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	init_mm.start_code = (unsigned long) _text;
 	init_mm.end_code   = (unsigned long) _etext;
 	init_mm.end_data   = (unsigned long) _edata;
 	init_mm.brk	   = (unsigned long) _end;
 
-	*cmdline_p = boot_command_line;
-
 	early_fixmap_init();
 	early_ioremap_init();
 
diff --git a/arch/c6x/kernel/setup.c b/arch/c6x/kernel/setup.c
index 786e36e2f61d..012c8e746889 100644
--- a/arch/c6x/kernel/setup.c
+++ b/arch/c6x/kernel/setup.c
@@ -294,16 +294,13 @@ notrace void __init machine_init(unsigned long dt_ptr)
 	parse_early_param();
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	int bootmap_size;
 	struct memblock_region *reg;
 
 	printk(KERN_INFO "Initializing kernel\n");
 
-	/* Initialize command line */
-	*cmdline_p = boot_command_line;
-
 	memory_end = ram_end;
 	memory_end &= ~(PAGE_SIZE - 1);
 
diff --git a/arch/h8300/kernel/setup.c b/arch/h8300/kernel/setup.c
index a4d0470c10a9..bb54c2087f13 100644
--- a/arch/h8300/kernel/setup.c
+++ b/arch/h8300/kernel/setup.c
@@ -117,7 +117,7 @@ static void __init bootmem_init(void)
 	}
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	unflatten_and_copy_device_tree();
 
@@ -131,7 +131,6 @@ void __init setup_arch(char **cmdline_p)
 
 	if (*command_line)
 		strcpy(boot_command_line, command_line);
-	*cmdline_p = boot_command_line;
 
 	parse_early_param();
 
diff --git a/arch/hexagon/kernel/setup.c b/arch/hexagon/kernel/setup.c
index 6981949f5df3..a0348dfad265 100644
--- a/arch/hexagon/kernel/setup.c
+++ b/arch/hexagon/kernel/setup.c
@@ -34,7 +34,6 @@
 #include <asm/vm_mmu.h>
 #include <asm/time.h>
 
-char cmd_line[COMMAND_LINE_SIZE];
 static char default_command_line[COMMAND_LINE_SIZE] __initdata = CONFIG_CMDLINE;
 
 int on_simulator;
@@ -44,12 +43,7 @@ void calibrate_delay(void)
 	loops_per_jiffy = thread_freq_mhz * 1000000 / HZ;
 }
 
-/*
- * setup_arch -  high level architectural setup routine
- * @cmdline_p: pointer to pointer to command-line arguments
- */
-
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	char *p = &external_cmdline_buffer;
 
@@ -84,14 +78,6 @@ void __init setup_arch(char **cmdline_p)
 		strlcpy(boot_command_line, default_command_line,
 			COMMAND_LINE_SIZE);
 
-	/*
-	 * boot_command_line and the value set up by setup_arch
-	 * are both picked up by the init code. If no reason to
-	 * make them different, pass the same pointer back.
-	 */
-	strlcpy(cmd_line, boot_command_line, COMMAND_LINE_SIZE);
-	*cmdline_p = cmd_line;
-
 	parse_early_param();
 
 	setup_arch_memory();
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index dee56bcb993d..75196264dd4e 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -527,15 +527,16 @@ int __init reserve_elfcorehdr(u64 *start, u64 *end)
 
 #endif /* CONFIG_PROC_VMCORE */
 
-void __init
-setup_arch (char **cmdline_p)
+void __init setup_arch (void)
 {
+	char *cmdline_p;
+
 	unw_init();
 
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
 
-	*cmdline_p = __va(ia64_boot_param->command_line);
-	strlcpy(boot_command_line, *cmdline_p, COMMAND_LINE_SIZE);
+	cmdline_p = __va(ia64_boot_param->command_line);
+	strlcpy(boot_command_line, cmdline_p, COMMAND_LINE_SIZE);
 
 	efi_init();
 	io_port_init();
@@ -546,12 +547,12 @@ setup_arch (char **cmdline_p)
 	 * that ia64_mv is initialised before any command line
 	 * settings may cause console setup to occur
 	 */
-	machvec_init_from_cmdline(*cmdline_p);
+	machvec_init_from_cmdline(cmdline_p);
 #endif
 
 	parse_early_param();
 
-	if (early_console_setup(*cmdline_p) = 0)
+	if (early_console_setup(cmdline_p) = 0)
 		mark_bsp_online();
 
 #ifdef CONFIG_ACPI
@@ -618,7 +619,7 @@ setup_arch (char **cmdline_p)
 	if (!nomca)
 		ia64_mca_init();
 
-	platform_setup(cmdline_p);
+	platform_setup(&cmdline_p);
 #ifndef CONFIG_IA64_HP_SIM
 	check_sal_cache_flush();
 #endif
diff --git a/arch/m68k/kernel/setup_mm.c b/arch/m68k/kernel/setup_mm.c
index dd25bfc22fb4..38ccaf3e0274 100644
--- a/arch/m68k/kernel/setup_mm.c
+++ b/arch/m68k/kernel/setup_mm.c
@@ -222,7 +222,7 @@ static void __init m68k_parse_bootinfo(const struct bi_record *record)
 #endif
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 #ifndef CONFIG_SUN3
 	int i;
@@ -272,8 +272,7 @@ void __init setup_arch(char **cmdline_p)
 	m68k_command_line[CL_SIZE - 1] = 0;
 #endif /* CONFIG_BOOTPARAM */
 	process_uboot_commandline(&m68k_command_line[0], CL_SIZE);
-	*cmdline_p = m68k_command_line;
-	memcpy(boot_command_line, *cmdline_p, CL_SIZE);
+	memcpy(boot_command_line, m68k_command_line, CL_SIZE);
 
 	parse_early_param();
 
diff --git a/arch/m68k/kernel/setup_no.c b/arch/m68k/kernel/setup_no.c
index a98af1018201..8b244d4ea603 100644
--- a/arch/m68k/kernel/setup_no.c
+++ b/arch/m68k/kernel/setup_no.c
@@ -84,7 +84,7 @@ void (*mach_power_off)(void);
 #define	CPU_INSTR_PER_JIFFY	16
 #endif
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	int bootmap_size;
 
@@ -143,7 +143,6 @@ void __init setup_arch(char **cmdline_p)
 		 __bss_stop, memory_start, memory_start, memory_end);
 
 	/* Keep a copy of command line */
-	*cmdline_p = &command_line[0];
 	memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
 	boot_command_line[COMMAND_LINE_SIZE-1] = 0;
 
diff --git a/arch/microblaze/kernel/setup.c b/arch/microblaze/kernel/setup.c
index be98ffe28ca8..632b7546effc 100644
--- a/arch/microblaze/kernel/setup.c
+++ b/arch/microblaze/kernel/setup.c
@@ -50,10 +50,8 @@ unsigned int boot_cpuid;
  */
 char cmd_line[COMMAND_LINE_SIZE] __attribute__ ((section(".data")));
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
-	*cmdline_p = boot_command_line;
-
 	console_verbose();
 
 	unflatten_device_tree();
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index 5f8b0a9e30b3..2bff67be95d6 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -64,7 +64,6 @@ EXPORT_SYMBOL(mips_machtype);
 
 struct boot_mem_map boot_mem_map;
 
-static char __initdata command_line[COMMAND_LINE_SIZE];
 char __initdata arcs_cmdline[COMMAND_LINE_SIZE];
 
 #ifdef CONFIG_CMDLINE_BOOL
@@ -829,7 +828,7 @@ static void __init request_crashkernel(struct resource *res)
 #define BUILTIN_EXTEND_WITH_PROM	\
 	IS_ENABLED(CONFIG_MIPS_CMDLINE_BUILTIN_EXTEND)
 
-static void __init arch_mem_init(char **cmdline_p)
+static void __init arch_mem_init(void)
 {
 	struct memblock_region *reg;
 	extern void plat_mem_setup(void);
@@ -881,10 +880,6 @@ static void __init arch_mem_init(char **cmdline_p)
 	pr_info("Determined physical RAM map:\n");
 	print_memory_map();
 
-	strlcpy(command_line, boot_command_line, COMMAND_LINE_SIZE);
-
-	*cmdline_p = command_line;
-
 	parse_early_param();
 
 	if (usermem) {
@@ -1002,7 +997,7 @@ static void __init prefill_possible_map(void)
 static inline void prefill_possible_map(void) {}
 #endif
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	cpu_probe();
 	mips_cm_probe();
@@ -1023,7 +1018,7 @@ void __init setup_arch(char **cmdline_p)
 #endif
 #endif
 
-	arch_mem_init(cmdline_p);
+	arch_mem_init();
 
 	resource_init();
 	plat_smp_setup();
diff --git a/arch/nds32/kernel/setup.c b/arch/nds32/kernel/setup.c
index ba910e9e4ecb..7df72753dd9a 100644
--- a/arch/nds32/kernel/setup.c
+++ b/arch/nds32/kernel/setup.c
@@ -276,7 +276,7 @@ static void __init setup_memory(void)
 	memblock_dump_all();
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	early_init_devtree( __dtb_start);
 
@@ -303,7 +303,6 @@ void __init setup_arch(char **cmdline_p)
 			conswitchp = &dummy_con;
 	}
 
-	*cmdline_p = boot_command_line;
 	early_trap_init();
 }
 
diff --git a/arch/nios2/kernel/setup.c b/arch/nios2/kernel/setup.c
index 926a02b17b31..e8d140f1d40c 100644
--- a/arch/nios2/kernel/setup.c
+++ b/arch/nios2/kernel/setup.c
@@ -141,7 +141,7 @@ asmlinkage void __init nios2_boot_init(unsigned r4, unsigned r5, unsigned r6,
 	parse_early_param();
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	int bootmap_size;
 
@@ -156,9 +156,6 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.brk = (unsigned long) _end;
 	init_task.thread.kregs = &fake_regs;
 
-	/* Keep a copy of command line */
-	*cmdline_p = boot_command_line;
-
 	min_low_pfn = PFN_UP(memory_start);
 	max_low_pfn = PFN_DOWN(memory_end);
 	max_mapnr = max_low_pfn;
diff --git a/arch/openrisc/kernel/setup.c b/arch/openrisc/kernel/setup.c
index 9d28ab14d139..d73e1faa88d1 100644
--- a/arch/openrisc/kernel/setup.c
+++ b/arch/openrisc/kernel/setup.c
@@ -283,7 +283,7 @@ void calibrate_delay(void)
 		(loops_per_jiffy / (5000 / HZ)) % 100, loops_per_jiffy);
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	unflatten_and_copy_device_tree();
 
@@ -320,8 +320,6 @@ void __init setup_arch(char **cmdline_p)
 		conswitchp = &dummy_con;
 #endif
 
-	*cmdline_p = boot_command_line;
-
 	printk(KERN_INFO "OpenRISC Linux -- http://openrisc.io\n");
 }
 
diff --git a/arch/parisc/kernel/setup.c b/arch/parisc/kernel/setup.c
index 0e9675f857a5..0a78a897959a 100644
--- a/arch/parisc/kernel/setup.c
+++ b/arch/parisc/kernel/setup.c
@@ -51,8 +51,6 @@
 #include <asm/unwind.h>
 #include <asm/smp.h>
 
-static char __initdata command_line[COMMAND_LINE_SIZE];
-
 /* Intended for ccio/sba/cpu statistics under /proc/bus/{runway|gsc} */
 struct proc_dir_entry * proc_runway_root __read_mostly = NULL;
 struct proc_dir_entry * proc_gsc_root __read_mostly = NULL;
@@ -63,7 +61,7 @@ int parisc_bus_is_phys __read_mostly = 1;	/* Assume no IOMMU is present */
 EXPORT_SYMBOL(parisc_bus_is_phys);
 #endif
 
-void __init setup_cmdline(char **cmdline_p)
+void __init setup_cmdline(void)
 {
 	extern unsigned int boot_args[];
 
@@ -85,9 +83,6 @@ void __init setup_cmdline(char **cmdline_p)
 		}
 #endif
 	}
-
-	strcpy(command_line, boot_command_line);
-	*cmdline_p = command_line;
 }
 
 #ifdef CONFIG_PA11
@@ -119,7 +114,7 @@ void __init dma_ops_init(void)
 
 extern void collect_boot_cpu_data(void);
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 #ifdef CONFIG_64BIT
 	extern int parisc_narrow_firmware;
@@ -160,7 +155,7 @@ void __init setup_arch(char **cmdline_p)
 	}
 #endif
 	setup_pdc();
-	setup_cmdline(cmdline_p);
+	setup_cmdline();
 	collect_boot_cpu_data();
 	do_memory_inventory();  /* probe for physical memory */
 	parisc_cache_init();
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index d73ec518ef80..b88ce4afaafd 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -839,10 +839,8 @@ static __init void print_system_info(void)
  * Called into from start_kernel this initializes memblock, which is used
  * to manage page allocation until mem_init is called.
  */
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
-	*cmdline_p = boot_command_line;
-
 	/* Set a half-reasonable default so udelay does something sensible */
 	loops_per_jiffy = 500000000 / HZ;
 
diff --git a/arch/riscv/kernel/setup.c b/arch/riscv/kernel/setup.c
index c11f40c1b2a8..dee21fd2f5c2 100644
--- a/arch/riscv/kernel/setup.c
+++ b/arch/riscv/kernel/setup.c
@@ -192,10 +192,8 @@ static void __init setup_bootmem(void)
 	}
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
-	*cmdline_p = boot_command_line;
-
 	parse_early_param();
 
 	init_mm.start_code = (unsigned long) _stext;
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index a6a91f01a17a..6addb5afc59e 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -867,7 +867,7 @@ static void __init setup_task_size(void)
  * was printed.
  */
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
         /*
          * print what head.S has found out about the machine
@@ -880,10 +880,6 @@ void __init setup_arch(char **cmdline_p)
 	else if (MACHINE_IS_LPAR)
 		pr_info("Linux is running natively in 64-bit mode\n");
 
-	/* Have one command line that is parsed and saved in /proc/cmdline */
-	/* boot_command_line has been already set up in early.c */
-	*cmdline_p = boot_command_line;
-
         ROOT_DEV = Root_RAM0;
 
 	/* Is init_mm really needed? */
diff --git a/arch/sh/kernel/setup.c b/arch/sh/kernel/setup.c
index b95c411d0333..c46646f0c3c5 100644
--- a/arch/sh/kernel/setup.c
+++ b/arch/sh/kernel/setup.c
@@ -270,8 +270,10 @@ void __ref sh_fdt_init(phys_addr_t dt_phys)
 }
 #endif
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
+	char *cmdline_p = command_line;
+
 	enable_mmu();
 
 	ROOT_DEV = old_decode_dev(ORIG_ROOT_DEV);
@@ -319,7 +321,6 @@ void __init setup_arch(char **cmdline_p)
 
 	/* Save unparsed command line copy for /proc/cmdline */
 	memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
-	*cmdline_p = command_line;
 
 	parse_early_param();
 
@@ -338,7 +339,7 @@ void __init setup_arch(char **cmdline_p)
 
 	/* Perform the machine specific initialisation */
 	if (likely(sh_mv.mv_setup))
-		sh_mv.mv_setup(cmdline_p);
+		sh_mv.mv_setup(&cmdline_p);
 
 	plat_smp_setup();
 }
diff --git a/arch/sparc/kernel/setup_32.c b/arch/sparc/kernel/setup_32.c
index 13664c377196..5bced97cc5f8 100644
--- a/arch/sparc/kernel/setup_32.c
+++ b/arch/sparc/kernel/setup_32.c
@@ -294,19 +294,20 @@ void __init sparc32_start_kernel(struct linux_romvec *rp)
 	start_kernel();
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	int i;
+	char *cmdline_p;
 	unsigned long highest_paddr;
 
 	sparc_ttable = &trapbase;
 
 	/* Initialize PROM console and command line. */
-	*cmdline_p = prom_getbootargs();
-	strlcpy(boot_command_line, *cmdline_p, COMMAND_LINE_SIZE);
+	cmdline_p = prom_getbootargs();
+	strlcpy(boot_command_line, cmdline_p, COMMAND_LINE_SIZE);
 	parse_early_param();
 
-	boot_flags_init(*cmdline_p);
+	boot_flags_init(cmdline_p);
 
 	register_console(&prom_early_console);
 
diff --git a/arch/sparc/kernel/setup_64.c b/arch/sparc/kernel/setup_64.c
index 7944b3ca216a..9f6edffa6a4b 100644
--- a/arch/sparc/kernel/setup_64.c
+++ b/arch/sparc/kernel/setup_64.c
@@ -630,14 +630,14 @@ void __init alloc_irqstack_bootmem(void)
 	}
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	/* Initialize PROM console and command line. */
-	*cmdline_p = prom_getbootargs();
-	strlcpy(boot_command_line, *cmdline_p, COMMAND_LINE_SIZE);
+	char *cmdline_p = prom_getbootargs();
+	strlcpy(boot_command_line, cmdline_p, COMMAND_LINE_SIZE);
 	parse_early_param();
 
-	boot_flags_init(*cmdline_p);
+	boot_flags_init(cmdline_p);
 #ifdef CONFIG_EARLYFB
 	if (btext_find_display())
 #endif
diff --git a/arch/um/kernel/um_arch.c b/arch/um/kernel/um_arch.c
index a818ccef30ca..73d62cf96149 100644
--- a/arch/um/kernel/um_arch.c
+++ b/arch/um/kernel/um_arch.c
@@ -339,7 +339,7 @@ int __init __weak read_initrd(void)
 	return 0;
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	stack_protections((unsigned long) &init_thread_info);
 	setup_physmem(uml_physmem, uml_reserved, physmem_size, highmem);
@@ -348,7 +348,6 @@ void __init setup_arch(char **cmdline_p)
 
 	paging_init();
 	strlcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
-	*cmdline_p = command_line;
 	setup_hostinfo(host_info, sizeof host_info);
 }
 
diff --git a/arch/unicore32/kernel/setup.c b/arch/unicore32/kernel/setup.c
index c2bffa5614a4..c13a07eeed0b 100644
--- a/arch/unicore32/kernel/setup.c
+++ b/arch/unicore32/kernel/setup.c
@@ -60,8 +60,6 @@ struct screen_info screen_info;
 char elf_platform[ELF_PLATFORM_SIZE];
 EXPORT_SYMBOL(elf_platform);
 
-static char __initdata cmd_line[COMMAND_LINE_SIZE];
-
 static char default_command_line[COMMAND_LINE_SIZE] __initdata = CONFIG_CMDLINE;
 
 /*
@@ -235,7 +233,7 @@ static int __init customize_machine(void)
 }
 arch_initcall(customize_machine);
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	char *from = default_command_line;
 
@@ -249,10 +247,6 @@ void __init setup_arch(char **cmdline_p)
 	/* parse_early_param needs a boot_command_line */
 	strlcpy(boot_command_line, from, COMMAND_LINE_SIZE);
 
-	/* populate cmd_line too for later use, preserving boot_command_line */
-	strlcpy(cmd_line, boot_command_line, COMMAND_LINE_SIZE);
-	*cmdline_p = cmd_line;
-
 	parse_early_param();
 
 	uc32_memblock_init(&meminfo);
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 6285697b6e56..6e3347dde550 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -219,7 +219,6 @@ unsigned long saved_video_mode;
 #define RAMDISK_PROMPT_FLAG		0x8000
 #define RAMDISK_LOAD_FLAG		0x4000
 
-static char __initdata command_line[COMMAND_LINE_SIZE];
 #ifdef CONFIG_CMDLINE_BOOL
 static char __initdata builtin_cmdline[COMMAND_LINE_SIZE] = CONFIG_CMDLINE;
 #endif
@@ -812,7 +811,7 @@ dump_kernel_offset(struct notifier_block *self, unsigned long v, void *p)
  * Note: On x86_64, fixmaps are ready for use even before this is called.
  */
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
 	memblock_reserve(__pa_symbol(_text),
 			 (unsigned long)__bss_stop - (unsigned long)_text);
@@ -933,9 +932,6 @@ void __init setup_arch(char **cmdline_p)
 #endif
 #endif
 
-	strlcpy(command_line, boot_command_line, COMMAND_LINE_SIZE);
-	*cmdline_p = command_line;
-
 	/*
 	 * x86_configure_nx() is called before parse_early_param() to detect
 	 * whether hardware doesn't support NX (so that the early EHCI debug
diff --git a/arch/xtensa/kernel/setup.c b/arch/xtensa/kernel/setup.c
index 686a27444bba..0409fa85bfdd 100644
--- a/arch/xtensa/kernel/setup.c
+++ b/arch/xtensa/kernel/setup.c
@@ -309,8 +309,10 @@ static inline int mem_reserve(unsigned long start, unsigned long end)
 	return memblock_reserve(start, end - start);
 }
 
-void __init setup_arch(char **cmdline_p)
+void __init setup_arch(void)
 {
+	char *cmdline_p = command_line;
+
 	pr_info("config ID: %08x:%08x\n",
 		get_sr(SREG_EPC), get_sr(SREG_EXCSAVE));
 	if (get_sr(SREG_EPC) != XCHAL_HW_CONFIGID0 ||
@@ -318,9 +320,8 @@ void __init setup_arch(char **cmdline_p)
 		pr_info("built for config ID: %08x:%08x\n",
 			XCHAL_HW_CONFIGID0, XCHAL_HW_CONFIGID1);
 
-	*cmdline_p = command_line;
-	platform_setup(cmdline_p);
-	strlcpy(boot_command_line, *cmdline_p, COMMAND_LINE_SIZE);
+	platform_setup(&cmdline_p);
+	strlcpy(boot_command_line, cmdline_p, COMMAND_LINE_SIZE);
 
 	/* Reserve some memory regions */
 
diff --git a/include/linux/init.h b/include/linux/init.h
index bc27cf03c41e..206b98d77cb4 100644
--- a/include/linux/init.h
+++ b/include/linux/init.h
@@ -129,7 +129,7 @@ extern char *saved_command_line;
 extern unsigned int reset_devices;
 
 /* used by init/main.c */
-void setup_arch(char **);
+void setup_arch(void);
 void prepare_namespace(void);
 void __init load_default_modules(void);
 int __init init_rootfs(void);
diff --git a/init/main.c b/init/main.c
index e4a3160991ea..8df5917867b1 100644
--- a/init/main.c
+++ b/init/main.c
@@ -367,15 +367,16 @@ static inline void smp_prepare_cpus(unsigned int maxcpus) { }
  * parsing is performed in place, and we should allow a component to
  * store reference of name/value for future reference.
  */
-static void __init setup_command_line(char *command_line)
+static void __init setup_command_line(void)
 {
 	saved_command_line  		memblock_virt_alloc(strlen(boot_command_line) + 1, 0);
 	initcall_command_line  		memblock_virt_alloc(strlen(boot_command_line) + 1, 0);
-	static_command_line = memblock_virt_alloc(strlen(command_line) + 1, 0);
+	static_command_line +		memblock_virt_alloc(strlen(boot_command_line) + 1, 0);
 	strcpy(saved_command_line, boot_command_line);
-	strcpy(static_command_line, command_line);
+	strcpy(static_command_line, boot_command_line);
 }
 
 /*
@@ -514,7 +515,6 @@ static void __init mm_init(void)
 
 asmlinkage __visible void __init start_kernel(void)
 {
-	char *command_line;
 	char *after_dashes;
 
 	set_task_stack_end_magic(&init_task);
@@ -533,16 +533,16 @@ asmlinkage __visible void __init start_kernel(void)
 	boot_cpu_init();
 	page_address_init();
 	pr_notice("%s", linux_banner);
-	setup_arch(&command_line);
+	setup_arch();
 	/*
 	 * Set up the the initial canary and entropy after arch
 	 * and after adding latent and command line entropy.
 	 */
 	add_latent_entropy();
-	add_device_randomness(command_line, strlen(command_line));
+	add_device_randomness(boot_command_line, strlen(boot_command_line));
 	boot_init_stack_canary();
 	mm_init_cpumask(&init_mm);
-	setup_command_line(command_line);
+	setup_command_line();
 	setup_nr_cpu_ids();
 	setup_per_cpu_areas();
 	boot_cpu_state_init();
-- 
2.14.1


