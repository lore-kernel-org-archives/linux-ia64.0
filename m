From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 05 Apr 2001 20:26:40 +0000
Subject: [Linux-ia64] kernel update (second patch relative to 2.4.3)
Message-Id: <marc-linux-ia64-105590693005374@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.3-ia64-010405.diff*

CAVEAT: You will need a NEW BOOTLOADER with this patch.  More on this
below.

What this patch does:

	- Switch over to new bootstrap procedure developed by
	  Stephane: the kernel is now booted in physical mode and the
	  bootloader is now completely decoupled from the kernel: it
	  simply loads the kernel as an ELF file and then jumps to the
	  entry point.  It has no special knowledge of where the
	  ZERO_PAGE is anymore, etc.  The new bootloader also supports
	  compressed kernel.  The Makefile supports this via "make
	  compressed": this target will produce "vmlinux" with all
	  debug info in it and "vmlinux.gz", a stripped and compressed
	  version of the kernel.

	- Sync up with Linus' 2.4.3 changes.  Warning: the locking
	  strategy changed for page table allocation.  If you have
	  code that calls pmd_alloc(), you'll need to update that code
	  to use the mm->page_table_lock (I already made these changes
	  for the IA-32 subsystem and for the AGP driver).

	- Add McKinley support (Alex).

	- The IA-32 execve() no longer has to clear r8 through r15
	  (it's already done in the generic execve() path).

	- Use 64MB instead of 256MB pages in the identity mapped
	  regions and load the kernel at address 68MB.  This avoids
	  problems with conflicting memory attributes due to the first
	  1MB of address space (Asit).

	- Don't panic in efivars.c just because EFI variables are not
	  supported.  Note: please do not call BUG() *UNLESS* you're
	  dealing with a problem that absolutely positiveley would
	  kill the kernel, delete your files, or some such.  Linux is
	  very careful not to panic for silly reasons and we'd like to
	  keep it that way.

	- Change ptrace.c so sync_kernel_register_backing_store()
	  works again.  Update unaligned.c and process.c accordingly.
	  This hasn't been well tested yet, but strace still works and
	  doing an inferior call with gdb no longer seems to corrupt
	  the stacked registers, so there is hope. ;-) Thanks to Kevin
	  for tracking down this issue.  Also, hopefully fix
	  PTRACE_GETSIGINFO, PTRACE_SETSIGINFO, and the ptrace and
	  core dump handling of ar.rnat.

	- Fix the initialization ordering bug that caused the 2.4.2
	  kernels to get stuck when using a page size smaller than
	  16KB.

	- Fix a buglet in get_unmapped_area().  Thanks to Matthew
	  Wilcox for reporting this.  (This bug had no negative
	  effect on any existing IA-64 implementation.)

	- Fix thinko in printk() rate limiting code (Khalid).

	- Update efirtc driver to move /proc/efirtc to
	  /proc/driver/efirtc and to use a format more in line with
	  the regular RTC driver (Stephane).

	- Hack fs/binfmt_elf so that the auxiliary information is
	  passed independent of whether the binary is statically or
	  dynamically linked (Rich, I haven't run this past Linus yet,
	  but I hope he won't have an issue with it; it really makes
	  no sense at all to not pass this info for static binaries:
	  an ELF file is an ELF file, no matter whether it's static or
	  dynamic).

	- Fix access_ok() to reject attempts to fool the kernel into
	  giving access to the virtually mapped page table (this
	  required moving the initial stack pointer down by one page).

	- Various minor clean ups.

In case it isn't clear yet: this patch has far more changes than I'd
normally feel comfortable with (we're trying to _stabilize_ things,
remember...).  However, as things go, several issues cropped up all at
the same time and this pretty much forced us to adopt a new bootstrap
procedure.  And since we had to update the bootloader anyhow, this
provided an opportunity to clean up some of the cruft that has
accumulated over the past couple of months.  The good news is that
while this patch may cause some pain, in my opinion the compressed
kernel support alone makes it well worth it. ;-) Still, test long and
well before shipping this kernel as part of a distro...

Now, as far as the new bootloader is concerned: Stephane has done all
the heavy lifting here and he'll soon send out an announcement with
pointers to both source and binary.

Usual disclaimers:

 o The patch below is for informational purposes only.  Get the real
   thing from ftp.kernel.org.

 o The patch below has been tested on 2P Big Sur and on the HP Ski
   simulator, in both cases with UP and MP.  As usual, YMMV.

Enjoy,

	--david

diff -urN --ignore-all-space linux-davidm/arch/ia64/Makefile lia64/arch/ia6=
4/Makefile
--- linux-davidm/arch/ia64/Makefile	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/Makefile	Thu Apr  5 09:44:42 2001
@@ -20,7 +20,7 @@
=20
 CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -Wa,-x -ffixed-r13 -mfixed-range=F10-=
f15,f32-f127 \
 	  -funwind-tables -falign-functions2
-# -frename-registers
+# -frename-registers (this crashes the Nov 17 compiler...)
 CFLAGS_KERNEL :=3D -mconstant-gp
=20
 ifeq ($(CONFIG_ITANIUM_ASTEP_SPECIFIC),y)
@@ -102,6 +102,11 @@
 		-traditional arch/$(ARCH)/vmlinux.lds.S > $@
=20
 FORCE: ;
+
+compressed: vmlinux
+	$(OBJCOPY) --strip-all vmlinux vmlinux-tmp
+	gzip -9 vmlinux-tmp
+	mv vmlinux-tmp.gz vmlinux.gz
=20
 rawboot:
 	@$(MAKEBOOT) rawboot
diff -urN --ignore-all-space linux-davidm/arch/ia64/boot/bootloader.c lia64=
/arch/ia64/boot/bootloader.c
--- linux-davidm/arch/ia64/boot/bootloader.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/boot/bootloader.c	Thu Apr  5 09:50:01 2001
@@ -65,35 +65,22 @@
 	}
 }
=20
-void
-enter_virtual_mode (unsigned long new_psr)
-{
-	long tmp;
-
-	asm volatile ("movl %0=1F" : "=3Dr"(tmp));
-	asm volatile ("mov cr.ipsr=3D%0" :: "r"(new_psr));
-	asm volatile ("mov cr.iip=3D%0" :: "r"(tmp));
-	asm volatile ("mov cr.ifs=3Dr0");
-	asm volatile ("rfi;;");
-	asm volatile ("1:");
-}
-
 #define MAX_ARGS 32
=20
 void
 _start (void)
 {
-	register long sp asm ("sp");
 	static char stack[16384] __attribute__ ((aligned (16)));
 	static char mem[4096];
 	static char buffer[1024];
-	unsigned long flags, off;
+	unsigned long off;
 	int fd, i;
 	struct disk_req req;
 	struct disk_stat stat;
 	struct elfhdr *elf;
 	struct elf_phdr *elf_phdr;	/* program header */
 	unsigned long e_entry, e_phoff, e_phnum;
+	register struct ia64_boot_param *bp;
 	char *kpath, *args;
 	long arglen =3D 0;
=20
@@ -107,15 +94,13 @@
 	ssc(0, 0, 0, 0, SSC_CONSOLE_INIT);
=20
 	/*
-	 * S.Eranian: extract the commandline argument from the=20
-	 * simulator
+	 * S.Eranian: extract the commandline argument from the simulator
 	 *
 	 * The expected format is as follows:
          *
 	 *	kernelname args...
 	 *
-	 * Both are optional but you can't have the second one without the=20
-	 * first.
+	 * Both are optional but you can't have the second one without the first.
 	 */
 	arglen =3D ssc((long) buffer, 0, 0, 0, SSC_GET_ARGS);
=20
@@ -183,6 +168,10 @@
 		e_phoff +=3D sizeof(*elf_phdr);
=20
 		elf_phdr =3D (struct elf_phdr *) mem;
+
+		if (elf_phdr->p_type !=3D PT_LOAD)
+			continue;
+
 		req.len =3D elf_phdr->p_filesz;
 		req.addr =3D __pa(elf_phdr->p_vaddr);
 		ssc(fd, 1, (long) &req, elf_phdr->p_offset, SSC_READ);
@@ -197,41 +186,12 @@
 	/* fake an I/O base address: */
 	asm volatile ("mov ar.k0=3D%0" :: "r"(0xffffc000000UL));
=20
-	/*
-	 * Install a translation register that identity maps the kernel's 256MB p=
age.
-	 */
-	ia64_clear_ic(flags);
-	ia64_set_rr(          0, (0x1000 << 8) | (_PAGE_SIZE_1M << 2));
-	ia64_set_rr(PAGE_OFFSET, (ia64_rid(0, PAGE_OFFSET) << 8) | (_PAGE_SIZE_25=
6M << 2));
-	ia64_srlz_d();
-	ia64_itr(0x3, IA64_TR_KERNEL, PAGE_OFFSET,
-		 pte_val(mk_pte_phys(0, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
-		 _PAGE_SIZE_256M);
-	/*
-	 * Map the bootloader with itr1 and dtr1; dtr1 will later be re-used for =
other
-	 * purposes, but itr1 will stick.
-	 */
-	ia64_itr(0x3, IA64_TR_PALCODE, 1024*1024,
-		 pte_val(mk_pte_phys(1024*1024, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_A=
R_RWX))),
-		 _PAGE_SIZE_1M);
-	ia64_srlz_i();
-
-	enter_virtual_mode(flags | IA64_PSR_IT | IA64_PSR_IC | IA64_PSR_DT | IA64=
_PSR_RT
-			   | IA64_PSR_DFH | IA64_PSR_BN);
-
-	sys_fw_init(args, arglen);
+	bp =3D sys_fw_init(args, arglen);
=20
 	ssc(0, (long) kpath, 0, 0, SSC_LOAD_SYMBOLS);
=20
-	/*
-	 * Install the kernel's command line argument on ZERO_PAGE
-	 * just after the botoparam structure.
-	 * In case we don't have any argument just put \0
-	 */
-	memcpy(((struct ia64_boot_param *)ZERO_PAGE_ADDR) + 1, args, arglen);
-	sp =3D __pa(&stack);
-
-	asm volatile ("br.sptk.few %0" :: "b"(e_entry));
+	asm volatile ("mov sp=3D%2; mov r28=3D%1; br.sptk.few %0"
+		      :: "b"(e_entry), "r"(bp), "r"(__pa(&stack)));
=20
 	cons_write("kernel returned!\n");
 	ssc(-1, 0, 0, 0, SSC_EXIT);
diff -urN --ignore-all-space linux-davidm/arch/ia64/config.in lia64/arch/ia=
64/config.in
--- linux-davidm/arch/ia64/config.in	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/config.in	Thu Apr  5 09:50:37 2001
@@ -24,6 +24,10 @@
 define_bool CONFIG_MCA n
 define_bool CONFIG_SBUS n
=20
+choice 'IA-64 processor type' \
+	"Itanium			CONFIG_ITANIUM \
+	 McKinley			CONFIG_MCKINLEY" Itanium
+
 choice 'IA-64 system type'					\
 	"generic		CONFIG_IA64_GENERIC		\
 	 DIG-compliant		CONFIG_IA64_DIG			\
@@ -36,12 +40,8 @@
 	 16KB			CONFIG_IA64_PAGE_SIZE_16KB		\
 	 64KB			CONFIG_IA64_PAGE_SIZE_64KB" 16KB
=20
-if [ "$CONFIG_IA64_DIG" =3D "y" -o "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
-	define_bool CONFIG_ITANIUM y
-	define_bool CONFIG_IA64_BRL_EMU y
-fi
-
 if [ "$CONFIG_ITANIUM" =3D "y" ]; then
+	define_bool CONFIG_IA64_BRL_EMU y
 	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
 	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
 	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
@@ -63,6 +63,20 @@
 	else
 	  define_bool CONFIG_ITANIUM_PTCG y
 	fi
+	if [ "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
+	  define_int CONFIG_IA64_L1_CACHE_SHIFT 7 # align cache-sensitive data to=
 128 bytes
+	else
+	  define_int CONFIG_IA64_L1_CACHE_SHIFT 6 # align cache-sensitive data to=
 64 bytes
+	fi
+fi
+
+if [ "$CONFIG_MCKINLEY" =3D "y" ]; then
+	define_bool CONFIG_ITANIUM_PTCG y
+	define_int CONFIG_IA64_L1_CACHE_SHIFT 7
+	bool '  Enable McKinley A-step specific code' CONFIG_MCKINLEY_ASTEP_SPECI=
FIC
+	if [ "$CONFIG_MCKINLEY_ASTEP_SPECIFIC" =3D "y" ]; then
+	  bool '   Enable McKinley A0/A1-step specific code' CONFIG_MCKINLEY_A0_S=
PECIFIC
+	fi
 fi
=20
 if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
@@ -75,7 +89,6 @@
 	  define_bool CONFIG_ACPI y
 	  define_bool CONFIG_ACPI_INTERPRETER y
 	fi
-	define_int CONFIG_IA64_L1_CACHE_SHIFT 6 # align cache-sensitive data to 6=
4 bytes
 fi
=20
 if [ "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
@@ -90,7 +103,6 @@
 	define_int  CONFIG_CACHE_LINE_SHIFT 7
 	bool '  Enable DISCONTIGMEM support' CONFIG_DISCONTIGMEM
 	bool '	Enable NUMA support' CONFIG_NUMA
-	define_int  CONFIG_IA64_L1_CACHE_SHIFT 7 # align cache-sensitive data to =
128 bytes
 fi
=20
 define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kco=
re.
@@ -244,7 +256,6 @@
   if [ "$CONFIG_SCSI" !=3D "n" ]; then
     bool 'Simulated SCSI disk' CONFIG_SCSI_SIM
   fi
-  define_int CONFIG_IA64_L1_CACHE_SHIFT 6 # align cache-sensitive data to =
64 bytes
   endmenu
 fi
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/dig/setup.c lia64/arch/=
ia64/dig/setup.c
--- linux-davidm/arch/ia64/dig/setup.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/dig/setup.c	Thu Apr  5 09:50:52 2001
@@ -54,8 +54,8 @@
=20
 	memset(&screen_info, 0, sizeof(screen_info));
=20
-	if (!ia64_boot_param.console_info.num_rows
-	    || !ia64_boot_param.console_info.num_cols)
+	if (!ia64_boot_param->console_info.num_rows
+	    || !ia64_boot_param->console_info.num_cols)
 	{
 		printk("dig_setup: warning: invalid screen-info, guessing 80x25\n");
 		orig_x =3D 0;
@@ -64,10 +64,10 @@
 		num_rows =3D 25;
 		font_height =3D 16;
 	} else {
-		orig_x =3D ia64_boot_param.console_info.orig_x;
-		orig_y =3D ia64_boot_param.console_info.orig_y;
-		num_cols =3D ia64_boot_param.console_info.num_cols;
-		num_rows =3D ia64_boot_param.console_info.num_rows;
+		orig_x =3D ia64_boot_param->console_info.orig_x;
+		orig_y =3D ia64_boot_param->console_info.orig_y;
+		num_cols =3D ia64_boot_param->console_info.num_cols;
+		num_rows =3D ia64_boot_param->console_info.num_rows;
 		font_height =3D 400 / num_rows;
 	}
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/ia32/binfmt_elf32.c lia=
64/arch/ia64/ia32/binfmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/ia32/binfmt_elf32.c	Thu Apr  5 09:51:03 2001
@@ -57,28 +57,30 @@
=20
 	if (page_count(page) !=3D 1)
 		printk("mem_map disagrees with %p at %08lx\n", (void *) page, address);
+
 	pgd =3D pgd_offset(tsk->mm, address);
-	pmd =3D pmd_alloc(pgd, address);
-	if (!pmd) {
-		__free_page(page);
-		force_sig(SIGKILL, tsk);
-		return 0;
-	}
-	pte =3D pte_alloc(pmd, address);
-	if (!pte) {
-		__free_page(page);
-		force_sig(SIGKILL, tsk);
-		return 0;
-	}
-	if (!pte_none(*pte)) {
-		pte_ERROR(*pte);
-		__free_page(page);
-		return 0;
-	}
+
+	spin_lock(&tsk->mm->page_table_lock);
+	{
+		pmd =3D pmd_alloc(tsk->mm, pgd, address);
+		if (!pmd)
+			goto out;
+		pte =3D pte_alloc(tsk->mm, pmd, address);
+		if (!pte)
+			goto out;
+		if (!pte_none(*pte))
+			goto out;
 	flush_page_to_ram(page);
 	set_pte(pte, pte_mkwrite(mk_pte(page, PAGE_SHARED)));
+	}
+	spin_unlock(&tsk->mm->page_table_lock);
 	/* no need for flush_tlb */
 	return page;
+
+  out:
+	spin_unlock(&tsk->mm->page_table_lock);
+	__free_page(page);
+	return 0;
 }
=20
 void ia64_elf32_init(struct pt_regs *regs)
@@ -148,19 +150,6 @@
 	regs->cr_ipsr &=3D ~IA64_PSR_AC;
=20
 	regs->loadrs =3D 0;
-	/*
-	 *  According to the ABI %edx points to an `atexit' handler.
-	 *  Since we don't have one we'll set it to 0 and initialize
-	 *  all the other registers just to make things more deterministic,
-	 *  ala the i386 implementation.
-	 */
-	regs->r8 =3D 0;	/* %eax */
-	regs->r11 =3D 0;	/* %ebx */
-	regs->r9 =3D 0;	/* %ecx */
-	regs->r10 =3D 0;	/* %edx */
-	regs->r13 =3D 0;	/* %ebp */
-	regs->r14 =3D 0;	/* %esi */
-	regs->r15 =3D 0;	/* %edi */
 }
=20
 #undef STACK_TOP
diff -urN --ignore-all-space linux-davidm/arch/ia64/ia32/ia32_entry.S lia64=
/arch/ia64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/ia32/ia32_entry.S	Wed Mar 28 21:42:44 2001
@@ -4,21 +4,6 @@
=20
 #include "../kernel/entry.h"
=20
-	.section "__ex_table", "a"		// declare section & section attributes
-	.previous
-
-#if __GNUC__ >=3D 3
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
-  [99:]	x
-#else
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
-  99:	x
-#endif
-
-	.text
-
 	/*
 	 * execve() is special because in case of success, we need to
 	 * setup a null register window frame (in case an IA-32 process
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/efi.c lia64/arch=
/ia64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/efi.c	Thu Apr  5 09:51:42 2001
@@ -129,9 +129,9 @@
 	efi_memory_desc_t *md;
 	u64 efi_desc_size, start, end;
=20
-	efi_map_start =3D __va(ia64_boot_param.efi_memmap);
-	efi_map_end   =3D efi_map_start + ia64_boot_param.efi_memmap_size;
-	efi_desc_size =3D ia64_boot_param.efi_memdesc_size;
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
=20
 	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
 		md =3D p;
@@ -204,9 +204,9 @@
 	u64 mask, flags;
 	u64 vaddr;
=20
-	efi_map_start =3D __va(ia64_boot_param.efi_memmap);
-	efi_map_end   =3D efi_map_start + ia64_boot_param.efi_memmap_size;
-	efi_desc_size =3D ia64_boot_param.efi_memdesc_size;
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
=20
 	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
 		md =3D p;
@@ -219,47 +219,42 @@
 			continue;
 		}
 		/*
-		 * We must use the same page size as the one used
-		 * for the kernel region when we map the PAL code.
-		 * This way, we avoid overlapping TRs if code is
-		 * executed nearby. The Alt I-TLB installs 256MB
-		 * page sizes as defined for region 7.
+		 * The only ITLB entry in region 7 that is used is the one installed by
+		 * __start().  That entry covers a 64MB range.
 		 *
 		 * XXX Fixme: should be dynamic here (for page size)
 		 */
-		mask  =3D ~((1 << _PAGE_SIZE_256M)-1);
+		mask  =3D ~((1 << _PAGE_SIZE_64M) - 1);
 		vaddr =3D PAGE_OFFSET + md->phys_addr;
=20
 		/*
-		 * We must check that the PAL mapping won't overlap
-		 * with the kernel mapping.
+		 * We must check that the PAL mapping won't overlap with the kernel
+		 * mapping.
 		 *
-		 * PAL code is guaranteed to be aligned on a power of 2
-		 * between 4k and 256KB.
-		 * Also from the documentation, it seems like there is an
-		 * implicit guarantee that you will need only ONE ITR to
-		 * map it. This implies that the PAL code is always aligned
-		 * on its size, i.e., the closest matching page size supported
-		 * by the TLB. Therefore PAL code is guaranteed never to cross
-		 * a 256MB unless it is bigger than 256MB (very unlikely!).
-		 * So for now the following test is enough to determine whether
-		 * or not we need a dedicated ITR for the PAL code.
+		 * PAL code is guaranteed to be aligned on a power of 2 between 4k and
+		 * 256KB.  Also from the documentation, it seems like there is an implic=
it
+		 * guarantee that you will need only ONE ITR to map it. This implies that
+		 * the PAL code is always aligned on its size, i.e., the closest matching
+		 * page size supported by the TLB. Therefore PAL code is guaranteed never
+		 * to cross a 64MB unless it is bigger than 64MB (very unlikely!).  So f=
or
+		 * now the following test is enough to determine whether or not we need a
+		 * dedicated ITR for the PAL code.
 		 */
-		if ((vaddr & mask) =3D (PAGE_OFFSET & mask)) {
-			printk(__FUNCTION__ " : no need to install ITR for PAL Code\n");
+		if ((vaddr & mask) =3D (KERNEL_START & mask)) {
+			printk(__FUNCTION__ " : no need to install ITR for PAL code\n");
 			continue;
 		}
=20
 		printk("CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
 		       smp_processor_id(), md->phys_addr, md->phys_addr + (md->num_pages=
 << 12),
-		       vaddr & mask, (vaddr & mask) + 256*1024*1024);
+		       vaddr & mask, (vaddr & mask) + 64*1024*1024);
=20
 		/*
 		 * Cannot write to CRx with PSR.ic=3D1
 		 */
 		ia64_clear_ic(flags);
 		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
-			 pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL)), _PAGE_SIZE_256M);
+			 pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL)), _PAGE_SIZE_64M);
 		local_irq_restore(flags);
 		ia64_srlz_i();
 	}
@@ -294,7 +289,7 @@
 	if (mem_limit !=3D ~0UL)
 		printk("Ignoring memory above %luMB\n", mem_limit >> 20);
=20
-	efi.systab =3D __va(ia64_boot_param.efi_systab);
+	efi.systab =3D __va(ia64_boot_param->efi_systab);
=20
 	/*
 	 * Verify the EFI Table
@@ -353,9 +348,9 @@
 	efi.get_next_high_mono_count =3D phys_get_next_high_mono_count;
 	efi.reset_system =3D phys_reset_system;
=20
-	efi_map_start =3D __va(ia64_boot_param.efi_memmap);
-	efi_map_end   =3D efi_map_start + ia64_boot_param.efi_memmap_size;
-	efi_desc_size =3D ia64_boot_param.efi_memdesc_size;
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
=20
 #if EFI_DEBUG
 	/* print EFI memory map: */
@@ -384,9 +379,9 @@
 	efi_status_t status;
 	u64 efi_desc_size;
=20
-	efi_map_start =3D __va(ia64_boot_param.efi_memmap);
-	efi_map_end   =3D efi_map_start + ia64_boot_param.efi_memmap_size;
-	efi_desc_size =3D ia64_boot_param.efi_memdesc_size;
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
=20
 	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
 		md =3D p;
@@ -425,9 +420,9 @@
 	}
=20
 	status =3D efi_call_phys(__va(runtime->set_virtual_address_map),
-			       ia64_boot_param.efi_memmap_size,
-			       efi_desc_size, ia64_boot_param.efi_memdesc_version,
-			       ia64_boot_param.efi_memmap);
+			       ia64_boot_param->efi_memmap_size,
+			       efi_desc_size, ia64_boot_param->efi_memdesc_version,
+			       ia64_boot_param->efi_memmap);
 	if (status !=3D EFI_SUCCESS) {
 		printk("Warning: unable to switch EFI into virtual mode (status=3D%lu)\n=
", status);
 		return;
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/efi_stub.S lia64=
/arch/ia64/kernel/efi_stub.S
--- linux-davidm/arch/ia64/kernel/efi_stub.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/efi_stub.S	Wed Mar 28 21:43:23 2001
@@ -33,13 +33,6 @@
 #include <asm/processor.h>
 #include <asm/asmmacro.h>
=20
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
-	.text
-
 /*
  * Inputs:
  *	in0 =3D address of function descriptor of EFI routine to call
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/efivars.c lia64/=
arch/ia64/kernel/efivars.c
--- linux-davidm/arch/ia64/kernel/efivars.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/efivars.c	Thu Apr  5 09:52:02 2001
@@ -379,9 +379,7 @@
 		case EFI_NOT_FOUND:
 			break;
 		default:
-			printk(KERN_WARNING "get_next_variable() status=3D%lx\n",
-			       status);
-			BUG();
+			printk(KERN_WARNING "get_next_variable: status=3D%lx\n", status);
 			status =3D EFI_NOT_FOUND;
 			break;
 		}
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/entry.S lia64/ar=
ch/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/entry.S	Thu Apr  5 09:52:18 2001
@@ -41,11 +41,6 @@
=20
 #include "minstate.h"
=20
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
 	/*
 	 * execve() is special because in case of success, we need to
 	 * setup a null register window frame.
@@ -145,9 +140,10 @@
 	dep r20=3D0,in0,61,3		// physical address of "current"
 	;;
 	st8 [r22]=3Dsp			// save kernel stack pointer of old task
-	shr.u r26=3Dr20,_PAGE_SIZE_256M
+	shr.u r26=3Dr20,_PAGE_SIZE_64M
+	mov r16=3D1
 	;;
-	cmp.eq p7,p6=3Dr26,r0		// check < 256M
+	cmp.ne p6,p7=3Dr26,r16		// check >=3D 64M && < 128M
 	adds r21=3DIA64_TASK_THREAD_KSP_OFFSET,in0
 	;;
 	/*
@@ -175,11 +171,11 @@
=20
 .map:
 	rsm psr.i | psr.ic
-	movl r25=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX
+	movl r25=3DPAGE_KERNEL
 	;;
 	srlz.d
 	or r23=3Dr25,r20			// construct PA | page properties
-	mov r25=3D_PAGE_SIZE_256M<<2
+	mov r25=3D_PAGE_SIZE_64M<<2
 	;;
 	mov cr.itir=3Dr25
 	mov cr.ifa=3Din0			// VA of next task...
@@ -189,7 +185,6 @@
 	;;
 	itr.d dtr[r25]=3Dr23		// wire in new mapping...
 	br.cond.sptk.many .done
-	;;
 END(ia64_switch_to)
=20
 /*
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/fw-emu.c lia64/a=
rch/ia64/kernel/fw-emu.c
--- linux-davidm/arch/ia64/kernel/fw-emu.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/fw-emu.c	Thu Apr  5 09:53:15 2001
@@ -22,7 +22,8 @@
=20
 #define NUM_MEM_DESCS	2
=20
-static char fw_mem[(  sizeof(efi_system_table_t)
+static char fw_mem[(  sizeof(struct ia64_boot_param)
+		    + sizeof(efi_system_table_t)
 		    + sizeof(efi_runtime_services_t)
 		    + 1*sizeof(efi_config_table_t)
 		    + sizeof(struct ia64_sal_systab)
@@ -333,7 +334,7 @@
 	return (void *) addr;
 }
=20
-void
+struct ia64_boot_param *
 sys_fw_init (const char *args, int arglen)
 {
 	efi_system_table_t *efi_systab;
@@ -359,6 +360,7 @@
 	sal_systab  =3D (void *) cp; cp +=3D sizeof(*sal_systab);
 	sal_ed      =3D (void *) cp; cp +=3D sizeof(*sal_ed);
 	efi_memmap  =3D (void *) cp; cp +=3D NUM_MEM_DESCS*sizeof(*efi_memmap);
+	bp	    =3D (void *) cp; cp +=3D sizeof(*bp);
 	cmd_line    =3D (void *) cp;
=20
 	if (args) {
@@ -441,7 +443,7 @@
 	md->pad =3D 0;
 	md->phys_addr =3D 2*MB;
 	md->virt_addr =3D 0;
-	md->num_pages =3D (64*MB) >> 12;	/* 64MB (in 4KB pages) */
+	md->num_pages =3D (128*MB) >> 12;	/* 128MB (in 4KB pages) */
 	md->attribute =3D EFI_MEMORY_WB;
=20
 	/* descriptor for firmware emulator: */
@@ -469,7 +471,6 @@
 	md->attribute =3D EFI_MEMORY_WB;
 #endif
=20
-	bp =3D id(ZERO_PAGE_ADDR);
 	bp->efi_systab =3D __pa(&fw_mem);
 	bp->efi_memmap =3D __pa(efi_memmap);
 	bp->efi_memmap_size =3D NUM_MEM_DESCS*sizeof(efi_memory_desc_t);
@@ -480,6 +481,7 @@
 	bp->console_info.num_rows =3D 25;
 	bp->console_info.orig_x =3D 0;
 	bp->console_info.orig_y =3D 24;
-	bp->num_pci_vectors =3D 0;
 	bp->fpswa =3D 0;
+
+	return bp;
 }
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/gate.S lia64/arc=
h/ia64/kernel/gate.S
--- linux-davidm/arch/ia64/kernel/gate.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/gate.S	Wed Mar 28 21:43:58 2001
@@ -13,10 +13,6 @@
 #include <asm/unistd.h>
 #include <asm/page.h>
=20
-	.psr abi64
-	.psr lsb
-	.lsb
-
 	.section .text.gate,"ax"
=20
 	.align PAGE_SIZE
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/head.S lia64/arc=
h/ia64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/head.S	Thu Apr  5 09:53:28 2001
@@ -5,8 +5,9 @@
  * to set up the kernel's global pointer and jump to the kernel
  * entry point.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2001 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999 Intel Corp.
@@ -18,17 +19,15 @@
=20
 #include <asm/asmmacro.h>
 #include <asm/fpu.h>
+#include <asm/kregs.h>
+#include <asm/mmu_context.h>
+#include <asm/offsets.h>
 #include <asm/pal.h>
 #include <asm/pgtable.h>
-#include <asm/offsets.h>
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
=20
-	.psr abi64
-	.psr lsb
-	.lsb
-
 	.section __special_page_section,"ax"
=20
 	.global empty_zero_page
@@ -39,29 +38,66 @@
 swapper_pg_dir:
 	.skip PAGE_SIZE
=20
-	.global empty_bad_page
-empty_bad_page:
-	.skip PAGE_SIZE
-
-	.global empty_bad_pte_table
-empty_bad_pte_table:
-	.skip PAGE_SIZE
-
-	.global empty_bad_pmd_table
-empty_bad_pmd_table:
-	.skip PAGE_SIZE
-
 	.rodata
 halt_msg:
 	stringz "Halting kernel\n"
=20
 	.text
=20
+	.global start_ap
+
+	/*
+	 * Start the kernel.  When the bootloader passes control to _start(), r28
+	 * points to the address of the boot parameter area.  Execution reaches
+	 * here in physical mode.
+	 */
 GLOBAL_ENTRY(_start)
+start_ap:
 	.prologue
 	.save rp, r4		// terminate unwind chain with a NULL rp
 	mov r4=3Dr0
 	.body
+
+	/*
+	 * Initialize the region register for region 7 and install a translation =
register
+	 * that maps the kernel's text and data:
+	 */
+	rsm psr.i | psr.ic
+	mov r16=3D((ia64_rid(IA64_REGION_ID_KERNEL, PAGE_OFFSET) << 8) | (_PAGE_S=
IZE_64M << 2))
+	;;
+	srlz.i
+	mov r18=3D_PAGE_SIZE_64M<<2
+	movl r17=3DPAGE_OFFSET + 64*1024*1024
+	;;
+	mov rr[r17]=3Dr16
+	mov cr.itir=3Dr18
+	mov cr.ifa=3Dr17
+	mov r16=3DIA64_TR_KERNEL
+	movl r18=3D(64*1024*1024 | PAGE_KERNEL)
+	;;
+	srlz.i
+	;;
+	itr.i itr[r16]=3Dr18
+	;;
+	itr.d dtr[r16]=3Dr18
+	;;
+	srlz.i
+
+	/*
+	 * Switch into virtual mode:
+	 */
+	movl r16=3D(IA64_PSR_IT|IA64_PSR_IC|IA64_PSR_DT|IA64_PSR_RT|IA64_PSR_DFH|=
IA64_PSR_BN)
+	;;
+	mov cr.ipsr=3Dr16
+	movl r17=1F
+	;;
+	mov cr.iip=3Dr17
+	mov cr.ifs=3Dr0
+	;;
+	rfi
+	;;
+1:	// now we are in virtual mode
+
 	// set IVT entry point---can't access I/O ports without it
 	movl r3=3Dia64_ivt
 	;;
@@ -75,7 +111,7 @@
 	;;
=20
 #ifdef CONFIG_IA64_EARLY_PRINTK
-	mov r3=3D(6<<8) | (28<<2)
+	mov r3=3D(6<<8) | (_PAGE_SIZE_64M<<2)
 	movl r2=3D6<<61
 	;;
 	mov rr[r2]=3Dr3
@@ -84,7 +120,8 @@
 	;;
 #endif
=20
-#define isAP	p2	// are we booting an Application Processor (not the BSP)?
+#define isAP	p2	// are we an Application Processor?
+#define isBP	p3	// are we the Bootstrap Processor?
=20
 	/*
 	 * Find the init_task for the currently booting CPU.  At poweron, and in
@@ -98,14 +135,17 @@
 	shladd r2=3Dr3,3,r2
 	;;
 	ld8 r2=3D[r2]
-	cmp4.ne isAP,p0=3Dr3,r0	// p9 =3D true if this is an application processo=
r (ap)
+	cmp4.ne isAP,isBP=3Dr3,r0
 	;;			// RAW on r2
 	extr r3=3Dr2,0,61		// r3 =3D phys addr of task struct
 	;;
=20
 	// load the "current" pointer (r13) and ar.k6 with the current task=20
 	mov r13=3Dr2
-	mov ar.k6=3Dr3		// Physical address
+	mov IA64_KR(CURRENT)=3Dr3		// Physical address
+
+	// initialize k4 to a safe value (64-128MB is mapped by TR_KERNEL)
+	mov IA64_KR(CURRENT_STACK)=3D1
 	/*
 	 * Reserve space at the top of the stack for "struct pt_regs".  Kernel th=
reads
 	 * don't store interesting values in that structure, but the space still =
needs
@@ -117,10 +157,17 @@
 	addl r2=3DIA64_RBS_OFFSET,r2	// initialize the RSE
 	mov ar.rsc=3D0		// place RSE in enforced lazy mode
 	;;
+	loadrs			// clear the dirty partition
+	;;
 	mov ar.bspstore=3Dr2	// establish the new RSE stack
 	;;
 	mov ar.rsc=3D0x3		// place RSE in eager mode
+
+(isBP)	dep r28=3D-1,r28,61,3	// make address virtual
+(isBP)	movl r2=3Dia64_boot_param
 	;;
+(isBP)	st8 [r2]=3Dr28		// save the address of the boot param area passed b=
y the bootloader
+
 #ifdef CONFIG_IA64_EARLY_PRINTK
 	.rodata
 alive_msg:
@@ -134,16 +181,12 @@
 1:	// force new bundle
 #endif /* CONFIG_IA64_EARLY_PRINTK */
=20
-	alloc r2=3Dar.pfs,8,0,2,0
-	;;
 #ifdef CONFIG_SMP
 (isAP)	br.call.sptk.few rp=3Dsmp_callin
 .ret0:
 (isAP)	br.cond.sptk.few self
 #endif
=20
-#undef isAP
-
 	// This is executed by the bootstrap processor (bsp) only:
=20
 #ifdef CONFIG_IA64_FW_EMU
@@ -152,9 +195,11 @@
 .ret1:
 #endif
 	br.call.sptk.few rp=3Dstart_kernel
-.ret2:	addl r2=3D@ltoff(halt_msg),gp
+.ret2:	addl r3=3D@ltoff(halt_msg),gp
+	;;
+	alloc r2=3Dar.pfs,8,0,2,0
 	;;
-	ld8 out0=3D[r2]
+	ld8 out0=3D[r3]
 	br.call.sptk.few b0=3Dconsole_print
 self:	br.sptk.few self		// endless loop
 END(_start)
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/ia64_ksyms.c lia=
64/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/ia64_ksyms.c	Thu Apr  5 09:53:49 2001
@@ -52,11 +52,6 @@
 EXPORT_SYMBOL_NOVERS(__down_write_failed);
 EXPORT_SYMBOL_NOVERS(__rwsem_wake);
=20
-#ifdef CONFIG_SMP
-#include <asm/pgalloc.h>
-EXPORT_SYMBOL(smp_flush_tlb_all);
-#endif
-
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
=20
@@ -69,8 +64,12 @@
 EXPORT_SYMBOL(last_cli_ip);
 #endif
=20
+#include <asm/pgalloc.h>
+
 #ifdef CONFIG_SMP
=20
+EXPORT_SYMBOL(smp_flush_tlb_all);
+
 #include <asm/current.h>
 #include <asm/hardirq.h>
 EXPORT_SYMBOL(synchronize_irq);
@@ -92,7 +91,11 @@
 EXPORT_SYMBOL(__global_save_flags);
 EXPORT_SYMBOL(__global_restore_flags);
=20
-#endif
+#else /* !CONFIG_SMP */
+
+EXPORT_SYMBOL(__flush_tlb_all);
+
+#endif /* !CONFIG_SMP */
=20
 #include <asm/uaccess.h>
 EXPORT_SYMBOL(__copy_user);
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/iosapic.c lia64/=
arch/ia64/kernel/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/iosapic.c	Thu Apr  5 09:53:59 2001
@@ -352,8 +352,8 @@
 		acpi_cf_get_pci_vectors(&pci_irq.route, &pci_irq.num_routes);
 #else
 		pci_irq.route -			(struct pci_vector_struct *) __va(ia64_boot_param.pci_=
vectors);
-		pci_irq.num_routes =3D ia64_boot_param.num_pci_vectors;
+			(struct pci_vector_struct *) __va(ia64_boot_param->pci_vectors);
+		pci_irq.num_routes =3D ia64_boot_param->num_pci_vectors;
 #endif
 	}
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/irq_ia64.c lia64=
/arch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/irq_ia64.c	Thu Apr  5 09:54:20 2001
@@ -61,6 +61,8 @@
 	return next_irq++;
 }
=20
+extern unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs);
+
 /*
  * That's where the IVT branches when we get an external
  * interrupt. This branches to the correct hardware IRQ handler via
@@ -89,7 +91,7 @@
 			static unsigned char count;
 			static long last_time;
=20
-			if (count > 5 && jiffies - last_time > 5*HZ)
+			if (jiffies - last_time > 5*HZ)
 				count =3D 0;
 			if (++count < 5) {
 				last_time =3D jiffies;
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/ivt.S lia64/arch=
/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/ivt.S	Thu Apr  5 09:54:33 2001
@@ -53,6 +53,16 @@
 # define PSR_DEFAULT_BITS	0
 #endif
=20
+#if 0
+  /*
+   * This lets you track the last eight faults that occurred on the CPU.  =
Make sure ar.k2 isn't
+   * needed for something else before enabling this...
+   */
+# define DBG_FAULT(i)	mov r16=3Dar.k2;;	shl r16=3Dr16,8;;	add r16=3D(i),r1=
6;;mov ar.k2=3Dr16
+#else
+# define DBG_FAULT(i)
+#endif
+
 #define MINSTATE_VIRT	/* needed by minstate.h */
 #include "minstate.h"
=20
@@ -79,10 +89,6 @@
  */
 #define BREAK_BUNDLE8(a); BREAK_BUNDLE4(a); BREAK_BUNDLE4(a)
=20
-	.psr abi64
-	.psr lsb
-	.lsb
-
 	.section .text.ivt,"ax"
=20
 	.align 32768	// align on 32KB boundary
@@ -91,6 +97,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0000 Entry 0 (size 64 bundles) VHPT Translation (8,20,47)
 ENTRY(vhpt_miss)
+	DBG_FAULT(0)
 	/*
 	 * The VHPT vector is invoked when the TLB entry for the virtual page tab=
le
 	 * is missing.  This happens only as a result of a previous
@@ -190,6 +197,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0400 Entry 1 (size 64 bundles) ITLB (21)
 ENTRY(itlb_miss)
+	DBG_FAULT(1)
 	/*
 	 * The ITLB handler accesses the L3 PTE via the virtually mapped linear
 	 * page table.  If a nested TLB miss occurs, we switch into physical
@@ -227,6 +235,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0800 Entry 2 (size 64 bundles) DTLB (9,48)
 ENTRY(dtlb_miss)
+	DBG_FAULT(2)
 	/*
 	 * The DTLB handler accesses the L3 PTE via the virtually mapped linear
 	 * page table.  If a nested TLB miss occurs, we switch into physical
@@ -264,6 +273,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
 ENTRY(alt_itlb_miss)
+	DBG_FAULT(3)
 	mov r16=3Dcr.ifa		// get address that caused the TLB miss
 	movl r17=3DPAGE_KERNEL
 	mov r21=3Dcr.ipsr
@@ -300,6 +310,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
 ENTRY(alt_dtlb_miss)
+	DBG_FAULT(4)
 	mov r16=3Dcr.ifa		// get address that caused the TLB miss
 	movl r17=3DPAGE_KERNEL
 	mov r20=3Dcr.isr
@@ -429,6 +440,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1800 Entry 6 (size 64 bundles) Instruction Key Miss (24)
 ENTRY(ikey_miss)
+	DBG_FAULT(6)
 	FAULT(6)
 END(ikey_miss)
=20
@@ -436,6 +448,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
 ENTRY(dkey_miss)
+	DBG_FAULT(7)
 	FAULT(7)
 END(dkey_miss)
=20
@@ -443,6 +456,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2000 Entry 8 (size 64 bundles) Dirty-bit (54)
 ENTRY(dirty_bit)
+	DBG_FAULT(8)
 	/*
 	 * What we do here is to simply turn on the dirty bit in the PTE.  We nee=
d to
 	 * update both the page-table and the TLB entry.  To efficiently access t=
he PTE,
@@ -498,6 +512,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2400 Entry 9 (size 64 bundles) Instruction Access-bit (27)
 ENTRY(iaccess_bit)
+	DBG_FAULT(9)
 	// Like Entry 8, except for instruction access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
@@ -576,6 +591,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2800 Entry 10 (size 64 bundles) Data Access-bit (15,55)
 ENTRY(daccess_bit)
+	DBG_FAULT(10)
 	// Like Entry 8, except for data access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
@@ -622,6 +638,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2c00 Entry 11 (size 64 bundles) Break instruction (33)
 ENTRY(break_fault)
+	DBG_FAULT(11)
 	mov r16=3Dcr.iim
 	mov r17=3D__IA64_BREAK_SYSCALL
 	mov r31=3Dpr		// prepare to save predicates
@@ -719,6 +736,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
 ENTRY(interrupt)
+	DBG_FAULT(12)
 	mov r31=3Dpr		// prepare to save predicates
 	;;
=20
@@ -744,16 +762,19 @@
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3400 Entry 13 (size 64 bundles) Reserved
+	DBG_FAULT(13)
 	FAULT(13)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3800 Entry 14 (size 64 bundles) Reserved
+	DBG_FAULT(14)
 	FAULT(14)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3c00 Entry 15 (size 64 bundles) Reserved
+	DBG_FAULT(15)
 	FAULT(15)
=20
 	/*
@@ -798,6 +819,7 @@
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4000 Entry 16 (size 64 bundles) Reserved
+	DBG_FAULT(16)
 	FAULT(16)
=20
 #ifdef CONFIG_IA32_SUPPORT
@@ -888,6 +910,7 @@
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4400 Entry 17 (size 64 bundles) Reserved
+	DBG_FAULT(17)
 	FAULT(17)
=20
 ENTRY(non_syscall)
@@ -919,6 +942,7 @@
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4800 Entry 18 (size 64 bundles) Reserved
+	DBG_FAULT(18)
 	FAULT(18)
=20
 	/*
@@ -952,6 +976,7 @@
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4c00 Entry 19 (size 64 bundles) Reserved
+	DBG_FAULT(19)
 	FAULT(19)
=20
 	/*
@@ -998,13 +1023,14 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5000 Entry 20 (size 16 bundles) Page Not Present (10,22,49)
 ENTRY(page_not_present)
+	DBG_FAULT(20)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
 	/*
 	 * The Linux page fault handler doesn't expect non-present pages to be in
 	 * the TLB.  Flush the existing entry now, so we meet that expectation.
 	 */
-	mov r17=3D_PAGE_SIZE_4K<<2
+	mov r17=3DPAGE_SHIFT<<2
 	;;
 	ptc.l r16,r17
 	;;
@@ -1017,6 +1043,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5100 Entry 21 (size 16 bundles) Key Permission (13,25,52)
 ENTRY(key_permission)
+	DBG_FAULT(21)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
 	mov r31=3Dpr
@@ -1029,6 +1056,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5200 Entry 22 (size 16 bundles) Instruction Access Rights (26)
 ENTRY(iaccess_rights)
+	DBG_FAULT(22)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
 	mov r31=3Dpr
@@ -1041,6 +1069,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5300 Entry 23 (size 16 bundles) Data Access Rights (14,53)
 ENTRY(daccess_rights)
+	DBG_FAULT(23)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
 	mov r31=3Dpr
@@ -1053,6 +1082,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5400 Entry 24 (size 16 bundles) General Exception (5,32,34,36,38,39)
 ENTRY(general_exception)
+	DBG_FAULT(24)
 	mov r16=3Dcr.isr
 	mov r31=3Dpr
 	;;
@@ -1067,6 +1097,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5500 Entry 25 (size 16 bundles) Disabled FP-Register (35)
 ENTRY(disabled_fp_reg)
+	DBG_FAULT(25)
 	rsm psr.dfh		// ensure we can access fph
 	;;
 	srlz.d
@@ -1079,6 +1110,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5600 Entry 26 (size 16 bundles) Nat Consumption (11,23,37,50)
 ENTRY(nat_consumption)
+	DBG_FAULT(26)
 	FAULT(26)
 END(nat_consumption)
=20
@@ -1086,6 +1118,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5700 Entry 27 (size 16 bundles) Speculation (40)
 ENTRY(speculation_vector)
+	DBG_FAULT(27)
 	/*
 	 * A [f]chk.[as] instruction needs to take the branch to the recovery cod=
e but
 	 * this part of the architecture is not implemented in hardware on some C=
PUs, such
@@ -1121,12 +1154,14 @@
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5800 Entry 28 (size 16 bundles) Reserved
+	DBG_FAULT(28)
 	FAULT(28)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5900 Entry 29 (size 16 bundles) Debug (16,28,56)
 ENTRY(debug_vector)
+	DBG_FAULT(29)
 	FAULT(29)
 END(debug_vector)
=20
@@ -1134,6 +1169,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5a00 Entry 30 (size 16 bundles) Unaligned Reference (57)
 ENTRY(unaligned_access)
+	DBG_FAULT(30)
 	mov r16=3Dcr.ipsr
 	mov r31=3Dpr		// prepare to save predicates
 	;;
@@ -1143,77 +1179,92 @@
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5b00 Entry 31 (size 16 bundles) Unsupported Data Reference (57)
+	DBG_FAULT(31)
 	FAULT(31)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5c00 Entry 32 (size 16 bundles) Floating-Point Fault (64)
+	DBG_FAULT(32)
 	FAULT(32)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5d00 Entry 33 (size 16 bundles) Floating Point Trap (66)
+	DBG_FAULT(33)
 	FAULT(33)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5e00 Entry 34 (size 16 bundles) Lower Privilege Tranfer Trap (66)
+	DBG_FAULT(34)
 	FAULT(34)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5f00 Entry 35 (size 16 bundles) Taken Branch Trap (68)
+	DBG_FAULT(35)
 	FAULT(35)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6000 Entry 36 (size 16 bundles) Single Step Trap (69)
+	DBG_FAULT(36)
 	FAULT(36)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6100 Entry 37 (size 16 bundles) Reserved
+	DBG_FAULT(37)
 	FAULT(37)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6200 Entry 38 (size 16 bundles) Reserved
+	DBG_FAULT(38)
 	FAULT(38)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6300 Entry 39 (size 16 bundles) Reserved
+	DBG_FAULT(39)
 	FAULT(39)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6400 Entry 40 (size 16 bundles) Reserved
+	DBG_FAULT(40)
 	FAULT(40)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6500 Entry 41 (size 16 bundles) Reserved
+	DBG_FAULT(41)
 	FAULT(41)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6600 Entry 42 (size 16 bundles) Reserved
+	DBG_FAULT(42)
 	FAULT(42)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6700 Entry 43 (size 16 bundles) Reserved
+	DBG_FAULT(43)
 	FAULT(43)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6800 Entry 44 (size 16 bundles) Reserved
+	DBG_FAULT(44)
 	FAULT(44)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6900 Entry 45 (size 16 bundles) IA-32 Exeception (17,18,29,41,42,43,4=
4,58,60,61,62,72,73,75,76,77)
 ENTRY(ia32_exception)
+	DBG_FAULT(45)
 	FAULT(45)
 END(ia32_exception)
=20
@@ -1221,6 +1272,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6a00 Entry 46 (size 16 bundles) IA-32 Intercept  (30,31,59,70,71)
 ENTRY(ia32_intercept)
+	DBG_FAULT(46)
 #ifdef	CONFIG_IA32_SUPPORT
 	mov r31=3Dpr
 	mov r16=3Dcr.isr
@@ -1250,6 +1302,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6b00 Entry 47 (size 16 bundles) IA-32 Interrupt  (74)
 ENTRY(ia32_interrupt)
+	DBG_FAULT(47)
 #ifdef CONFIG_IA32_SUPPORT
 	mov r31=3Dpr
 	br.sptk.many dispatch_to_ia32_handler
@@ -1261,99 +1314,119 @@
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6c00 Entry 48 (size 16 bundles) Reserved
+	DBG_FAULT(48)
 	FAULT(48)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6d00 Entry 49 (size 16 bundles) Reserved
+	DBG_FAULT(49)
 	FAULT(49)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6e00 Entry 50 (size 16 bundles) Reserved
+	DBG_FAULT(50)
 	FAULT(50)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6f00 Entry 51 (size 16 bundles) Reserved
+	DBG_FAULT(51)
 	FAULT(51)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7000 Entry 52 (size 16 bundles) Reserved
+	DBG_FAULT(52)
 	FAULT(52)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7100 Entry 53 (size 16 bundles) Reserved
+	DBG_FAULT(53)
 	FAULT(53)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7200 Entry 54 (size 16 bundles) Reserved
+	DBG_FAULT(54)
 	FAULT(54)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7300 Entry 55 (size 16 bundles) Reserved
+	DBG_FAULT(55)
 	FAULT(55)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7400 Entry 56 (size 16 bundles) Reserved
+	DBG_FAULT(56)
 	FAULT(56)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7500 Entry 57 (size 16 bundles) Reserved
+	DBG_FAULT(57)
 	FAULT(57)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7600 Entry 58 (size 16 bundles) Reserved
+	DBG_FAULT(58)
 	FAULT(58)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7700 Entry 59 (size 16 bundles) Reserved
+	DBG_FAULT(59)
 	FAULT(59)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7800 Entry 60 (size 16 bundles) Reserved
+	DBG_FAULT(60)
 	FAULT(60)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7900 Entry 61 (size 16 bundles) Reserved
+	DBG_FAULT(61)
 	FAULT(61)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7a00 Entry 62 (size 16 bundles) Reserved
+	DBG_FAULT(62)
 	FAULT(62)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7b00 Entry 63 (size 16 bundles) Reserved
+	DBG_FAULT(63)
 	FAULT(63)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7c00 Entry 64 (size 16 bundles) Reserved
+	DBG_FAULT(64)
 	FAULT(64)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7d00 Entry 65 (size 16 bundles) Reserved
+	DBG_FAULT(65)
 	FAULT(65)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7e00 Entry 66 (size 16 bundles) Reserved
+	DBG_FAULT(66)
 	FAULT(66)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7f00 Entry 67 (size 16 bundles) Reserved
+	DBG_FAULT(67)
 	FAULT(67)
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/mca_asm.S lia64/=
arch/ia64/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/mca_asm.S	Wed Mar 28 21:44:55 2001
@@ -22,10 +22,6 @@
=20
 #include "minstate.h"
=20
-	.psr abi64
-	.psr lsb
-	.lsb
-
 /*
  *	SAL_TO_OS_MCA_HANDOFF_STATE
  *		1. GR1 =3D OS GP
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/pal.S lia64/arch=
/ia64/kernel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/pal.S	Wed Mar 28 21:45:02 2001
@@ -14,11 +14,6 @@
 #include <asm/asmmacro.h>
 #include <asm/processor.h>
=20
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
 	.data
 pal_entry_point:
 	data8 ia64_pal_default_handler
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/process.c lia64/=
arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/process.c	Thu Apr  5 09:55:58 2001
@@ -294,7 +294,7 @@
 void
 do_copy_regs (struct unw_frame_info *info, void *arg)
 {
-	unsigned long ar_bsp, ndirty, *krbs, addr, mask, sp, nat_bits =3D 0, ip;
+	unsigned long ar_bsp, addr, mask, sp, nat_bits =3D 0, ip, ar_rnat;
 	elf_greg_t *dst =3D arg;
 	struct pt_regs *pt;
 	char nat;
@@ -309,18 +309,18 @@
 	unw_get_sp(info, &sp);
 	pt =3D (struct pt_regs *) (sp + 16);
=20
-	krbs =3D (unsigned long *) current + IA64_RBS_OFFSET/8;
-	ndirty =3D ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
-	ar_bsp =3D (unsigned long) ia64_rse_skip_regs((long *) pt->ar_bspstore, n=
dirty);
+	ar_bsp =3D ia64_get_user_bsp(current, pt);
=20
 	/*
-	 * Write portion of RSE backing store living on the kernel
-	 * stack to the VM of the process.
+	 * Write portion of RSE backing store living on the kernel stack to the V=
M of the
+	 * process.
 	 */
 	for (addr =3D pt->ar_bspstore; addr < ar_bsp; addr +=3D 8)
-		if (ia64_peek(pt, current, addr, &val) =3D 0)
+		if (ia64_peek(current, ar_bsp, addr, &val) =3D 0)
 			access_process_vm(current, addr, &val, sizeof(val), 1);
=20
+	ia64_peek(current, ar_bsp, (long) ia64_rse_rnat_addr((long *) addr - 1), =
&ar_rnat);
+
 	/*
 	 * coredump format:
 	 *	r0-r31
@@ -357,7 +357,7 @@
 	 */
 	dst[46] =3D ar_bsp;
 	dst[47] =3D pt->ar_bspstore;
-	unw_get_ar(info, UNW_AR_RNAT, &dst[48]);
+	dst[48] =3D ar_rnat;
 	unw_get_ar(info, UNW_AR_CCV, &dst[49]);
 	unw_get_ar(info, UNW_AR_UNAT, &dst[50]);
 	unw_get_ar(info, UNW_AR_FPSR, &dst[51]);
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/ptrace.c lia64/a=
rch/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/ptrace.c	Thu Apr  5 09:56:12 2001
@@ -1,8 +1,8 @@
 /*
  * Kernel support for the ptrace() and syscall tracing interfaces.
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Derived from the x86 and Alpha versions.  Most of the code in here
  * could actually be factored into a common set of routines.
@@ -290,9 +290,9 @@
 }
=20
 long
-ia64_peek (struct pt_regs *regs, struct task_struct *child, unsigned long =
addr, long *val)
+ia64_peek (struct task_struct *child, unsigned long user_bsp, unsigned lon=
g addr, long *val)
 {
-	unsigned long *bspstore, *krbs, krbs_num_regs, regnum, *rbs_end, *laddr;
+	unsigned long *bspstore, *krbs, regnum, *laddr, *ubsp =3D (long *) user_b=
sp;
 	struct switch_stack *child_stack;
 	struct pt_regs *child_regs;
 	size_t copied;
@@ -303,28 +303,19 @@
 	child_stack =3D (struct switch_stack *) (child->thread.ksp + 16);
 	bspstore =3D (unsigned long *) child_regs->ar_bspstore;
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
-	krbs_num_regs =3D ia64_rse_num_regs(krbs, (unsigned long *) child_stack->=
ar_bspstore);
-	rbs_end =3D ia64_rse_skip_regs(bspstore, krbs_num_regs);
-	if (laddr >=3D bspstore && laddr <=3D ia64_rse_rnat_addr(rbs_end)) {
-		/*
-		 * Attempt to read the RBS in an area that's actually
-		 * on the kernel RBS =3D> read the corresponding bits in
-		 * the kernel RBS.
+	if (laddr >=3D bspstore && laddr <=3D ia64_rse_rnat_addr(ubsp)) {
+		/*
+		 * Attempt to read the RBS in an area that's actually on the kernel RBS =
=3D>
+		 * read the corresponding bits in the kernel RBS.
 		 */
 		if (ia64_rse_is_rnat_slot(laddr))
 			ret =3D get_rnat(child_regs, child_stack, krbs, laddr);
 		else {
-			regnum =3D ia64_rse_num_regs(bspstore, laddr);
-			laddr =3D ia64_rse_skip_regs(krbs, regnum);
-			if (regnum >=3D krbs_num_regs) {
+			if (laddr >=3D ubsp)
 				ret =3D 0;
-			} else {
-				if  ((unsigned long) laddr >=3D (unsigned long) high_memory) {
-					printk("yikes: trying to access long at %p\n",
-					       (void *) laddr);
-					return -EIO;
-				}
-				ret =3D *laddr;
+			else {
+				regnum =3D ia64_rse_num_regs(bspstore, laddr);
+				ret =3D *ia64_rse_skip_regs(krbs, regnum);
 			}
 		}
 	} else {
@@ -337,9 +328,9 @@
 }
=20
 long
-ia64_poke (struct pt_regs *regs, struct task_struct *child, unsigned long =
addr, long val)
+ia64_poke (struct task_struct *child, unsigned long user_bsp, unsigned lon=
g addr, long val)
 {
-	unsigned long *bspstore, *krbs, krbs_num_regs, regnum, *rbs_end, *laddr;
+	unsigned long *bspstore, *krbs, regnum, *laddr, *ubsp =3D (long *) user_b=
sp;
 	struct switch_stack *child_stack;
 	struct pt_regs *child_regs;
=20
@@ -348,21 +339,17 @@
 	child_stack =3D (struct switch_stack *) (child->thread.ksp + 16);
 	bspstore =3D (unsigned long *) child_regs->ar_bspstore;
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
-	krbs_num_regs =3D ia64_rse_num_regs(krbs, (unsigned long *) child_stack->=
ar_bspstore);
-	rbs_end =3D ia64_rse_skip_regs(bspstore, krbs_num_regs);
-	if (laddr >=3D bspstore && laddr <=3D ia64_rse_rnat_addr(rbs_end)) {
-		/*
-		 * Attempt to write the RBS in an area that's actually
-		 * on the kernel RBS =3D> write the corresponding bits
-		 * in the kernel RBS.
+	if (laddr >=3D bspstore && laddr <=3D ia64_rse_rnat_addr(ubsp)) {
+		/*
+		 * Attempt to write the RBS in an area that's actually on the kernel RBS
+		 * =3D> write the corresponding bits in the kernel RBS.
 		 */
 		if (ia64_rse_is_rnat_slot(laddr))
 			put_rnat(child_regs, child_stack, krbs, laddr, val);
 		else {
+			if (laddr < ubsp) {
 			regnum =3D ia64_rse_num_regs(bspstore, laddr);
-			laddr =3D ia64_rse_skip_regs(krbs, regnum);
-			if (regnum < krbs_num_regs) {
-				*laddr =3D val;
+				*ia64_rse_skip_regs(krbs, regnum) =3D val;
 			}
 		}
 	} else if (access_process_vm(child, addr, &val, sizeof(val), 1) !=3D size=
of(val)) {
@@ -372,69 +359,76 @@
 }
=20
 /*
- * Synchronize (i.e, write) the RSE backing store living in kernel
- * space to the VM of the indicated child process.
- *
- * If new_bsp is non-zero, the bsp will (effectively) be updated to
- * the new value upon resumption of the child process.  This is
- * accomplished by setting the loadrs value to zero and the bspstore
- * value to the new bsp value.
- *
- * When new_bsp and force_loadrs_to_zero are both 0, the register
- * backing store in kernel space is written to user space and the
- * loadrs and bspstore values are left alone.
- *
- * When new_bsp is zero and force_loadrs_to_zero is 1 (non-zero),
- * loadrs is set to 0, and the bspstore value is set to the old bsp
- * value.  This will cause the stacked registers (r32 and up) to be
- * obtained entirely from the child's memory space rather than
- * from the kernel.  (This makes it easier to write code for
- * modifying the stacked registers in multi-threaded programs.)
- *
- * Note:  I had originally written this function without the
- * force_loadrs_to_zero parameter; it was written so that loadrs would
- * always be set to zero.  But I had problems with certain system
- * calls apparently causing a portion of the RBS to be zeroed.  (I
- * still don't understand why this was happening.) Anyway, it'd
- * definitely less intrusive to leave loadrs and bspstore alone if
- * possible.
+ * Calculate the user-level address that would have been in ar.bsp had the=
 user executed a
+ * "cover" instruction right before entering the kernel.
  */
-static long
-sync_kernel_register_backing_store (struct task_struct *child,
-                                    long new_bsp,
-                                    int force_loadrs_to_zero)
+unsigned long
+ia64_get_user_bsp (struct task_struct *child, struct pt_regs *pt)
 {
-	unsigned long *krbs, bspstore, *kbspstore, bsp, rbs_end, addr, val;
-	long ndirty, ret =3D 0;
-	struct pt_regs *child_regs =3D ia64_task_regs(child);
-
+	unsigned long *krbs, *bspstore, cfm;
 	struct unw_frame_info info;
-	unsigned long cfm, sof;
-
-	unw_init_from_blocked_task(&info, child);
-	if (unw_unwind_to_user(&info) < 0)
-		return -1;
-
-	unw_get_bsp(&info, (unsigned long *) &kbspstore);
+	long ndirty;
=20
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
-	ndirty =3D ia64_rse_num_regs(krbs, krbs + (child_regs->loadrs >> 19));
-	bspstore =3D child_regs->ar_bspstore;
-	bsp =3D (long) ia64_rse_skip_regs((long *)bspstore, ndirty);
+	bspstore =3D (unsigned long *) pt->ar_bspstore;
+	ndirty =3D ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
=20
-	cfm =3D child_regs->cr_ifs;
-	if (!(cfm & (1UL << 63)))
+	if ((long) pt->cr_ifs >=3D 0) {
+		/*
+		 * If bit 63 of cr.ifs is cleared, the kernel was entered via a system
+		 * call and we need to recover the CFM that existed on entry to the
+		 * kernel by unwinding the kernel stack.
+		 */
+		unw_init_from_blocked_task(&info, child);
+		if (unw_unwind_to_user(&info) =3D 0) {
 		unw_get_cfm(&info, &cfm);
-	sof =3D (cfm & 0x7f);
-	rbs_end =3D (long) ia64_rse_skip_regs((long *)bspstore, sof);
+			ndirty +=3D (cfm & 0x7f);
+		}
+	}
+	return (unsigned long) ia64_rse_skip_regs(bspstore, ndirty);
+}
+
+/*
+ * Synchronize (i.e, write) the RSE backing store living in kernel space t=
o the VM of the
+ * indicated child process.
+ *
+ * If new_bsp is non-zero, the bsp will (effectively) be updated to the ne=
w value upon
+ * resumption of the child process.  This is accomplished by setting the l=
oadrs value to
+ * zero and the bspstore value to the new bsp value.
+ *
+ * When new_bsp and flush_user_rbs are both 0, the register backing store =
in kernel space
+ * is written to user space and the loadrs and bspstore values are left al=
one.
+ *
+ * When new_bsp is zero and flush_user_rbs is 1 (non-zero), loadrs is set =
to 0, and the
+ * bspstore value is set to the old bsp value.  This will cause the stacke=
d registers (r32
+ * and up) to be obtained entirely from the child's memory space rather th=
an from the
+ * kernel.  (This makes it easier to write code for modifying the stacked =
registers in
+ * multi-threaded programs.)
+ *
+ * Note: I had originally written this function without the flush_user_rbs=
 parameter; it
+ * was written so that loadrs would always be set to zero.  But I had prob=
lems with
+ * certain system calls apparently causing a portion of the RBS to be zero=
ed.  (I still
+ * don't understand why this was happening.) Anyway, it'd definitely less =
intrusive to
+ * leave loadrs and bspstore alone if possible.
+ */
+static long
+sync_kernel_register_backing_store (struct task_struct *child, long user_b=
sp, long new_bsp,
+				    int flush_user_rbs)
+{
+	struct pt_regs *child_regs =3D ia64_task_regs(child);
+	unsigned long addr, val;
+	long ret;
=20
-	/* Return early if nothing to do */
-	if (bsp =3D new_bsp)
+	/*
+	 * Return early if nothing to do.  Note that new_bsp will be zero if the =
caller
+	 * wants to force synchronization without changing bsp.
+	 */
+	if (user_bsp =3D new_bsp)
 		return 0;
=20
 	/* Write portion of backing store living on kernel stack to the child's V=
M. */
-	for (addr =3D bspstore; addr < rbs_end; addr +=3D 8) {
-		ret =3D ia64_peek(child_regs, child, addr, &val);
+	for (addr =3D child_regs->ar_bspstore; addr < user_bsp; addr +=3D 8) {
+		ret =3D ia64_peek(child, user_bsp, addr, &val);
 		if (ret !=3D 0)
 			return ret;
 		if (access_process_vm(child, addr, &val, sizeof(val), 1) !=3D sizeof(val=
))
@@ -442,27 +436,26 @@
 	}
=20
 	if (new_bsp !=3D 0) {
-		force_loadrs_to_zero =3D 1;
-		bsp =3D new_bsp;
+		flush_user_rbs =3D 1;
+		user_bsp =3D new_bsp;
 	}
=20
-	if (force_loadrs_to_zero) {
+	if (flush_user_rbs) {
 		child_regs->loadrs =3D 0;
-		child_regs->ar_bspstore =3D bsp;
+		child_regs->ar_bspstore =3D user_bsp;
 	}
-
-	return ret;
+	return 0;
 }
=20
 static void
-sync_thread_rbs (struct task_struct *child, struct mm_struct *mm, int make=
_writable)
+sync_thread_rbs (struct task_struct *child, long bsp, struct mm_struct *mm=
, int make_writable)
 {
 	struct task_struct *p;
 	read_lock(&tasklist_lock);
 	{
 		for_each_task(p) {
 			if (p->mm =3D mm && p->state !=3D TASK_RUNNING)
-				sync_kernel_register_backing_store(p, 0, make_writable);
+				sync_kernel_register_backing_store(p, bsp, 0, make_writable);
 		}
 	}
 	read_unlock(&tasklist_lock);
@@ -535,7 +528,7 @@
 static int
 access_uarea (struct task_struct *child, unsigned long addr, unsigned long=
 *data, int write_access)
 {
-	unsigned long *ptr, *rbs, *bspstore, ndirty, regnum;
+	unsigned long *ptr, regnum, bsp, rnat_addr;
 	struct switch_stack *sw;
 	struct unw_frame_info info;
 	struct pt_regs *pt;
@@ -632,36 +625,16 @@
 		/* scratch state */
 		switch (addr) {
 		      case PT_AR_BSP:
+			bsp =3D ia64_get_user_bsp(child, pt);
 			if (write_access)
-				/* FIXME? Account for lack of ``cover'' in the syscall case */
-				return sync_kernel_register_backing_store(child, *data, 1);
+				return sync_kernel_register_backing_store(child, bsp, *data, 1);
 			else {
-				rbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
-				bspstore =3D (unsigned long *) pt->ar_bspstore;
-				ndirty =3D ia64_rse_num_regs(rbs, rbs + (pt->loadrs >> 19));
-
-				/*
-				 * If we're in a system call, no ``cover'' was done.  So to
-				 * make things uniform, we'll add the appropriate displacement
-				 * onto bsp if we're in a system call.
-				 */
-				if (!(pt->cr_ifs & (1UL << 63))) {
-					struct unw_frame_info info;
-					unsigned long cfm;
-
-					unw_init_from_blocked_task(&info, child);
-					if (unw_unwind_to_user(&info) < 0)
-						return -1;
-
-					unw_get_cfm(&info, &cfm);
-					ndirty +=3D cfm & 0x7f;
-				}
-				*data =3D (unsigned long) ia64_rse_skip_regs(bspstore, ndirty);
+				*data =3D bsp;
 				return 0;
 			}
=20
 		      case PT_CFM:
-			if (pt->cr_ifs & (1UL << 63)) {
+			if ((long) pt->cr_ifs < 0) {
 				if (write_access)
 					pt->cr_ifs =3D ((pt->cr_ifs & ~0x3fffffffffUL)
 						      | (*data & 0x3fffffffffUL));
@@ -692,6 +665,14 @@
 				*data =3D (pt->cr_ipsr & IPSR_READ_MASK);
 			return 0;
=20
+		      case PT_AR_RNAT:
+			bsp =3D ia64_get_user_bsp(child, pt);
+			rnat_addr =3D (long) ia64_rse_rnat_addr((long *) bsp - 1);
+			if (write_access)
+				return ia64_poke(child, bsp, rnat_addr, *data);
+			else
+				return ia64_peek(child, bsp, rnat_addr, data);
+
 		      		   case PT_R1:  case PT_R2:  case PT_R3:
 		      case PT_R8:  case PT_R9:  case PT_R10: case PT_R11:
 		      case PT_R12: case PT_R13: case PT_R14: case PT_R15:
@@ -703,7 +684,7 @@
 		      case PT_F6:  case PT_F6+8: case PT_F7: case PT_F7+8:
 		      case PT_F8:  case PT_F8+8: case PT_F9: case PT_F9+8:
 		      case PT_AR_BSPSTORE:
-		      case PT_AR_RSC: case PT_AR_UNAT: case PT_AR_PFS: case PT_AR_RNAT:
+		      case PT_AR_RSC: case PT_AR_UNAT: case PT_AR_PFS:
 		      case PT_AR_CCV: case PT_AR_FPSR: case PT_CR_IIP: case PT_PR:
 			/* scratch register */
 			ptr =3D (unsigned long *) ((long) pt + addr - PT_CR_IPSR);
@@ -756,9 +737,9 @@
 sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long dat=
a,
 	    long arg4, long arg5, long arg6, long arg7, long stack)
 {
-	struct pt_regs *regs =3D (struct pt_regs *) &stack;
+	struct pt_regs *pt, *regs =3D (struct pt_regs *) &stack;
 	struct task_struct *child;
-	unsigned long flags;
+	unsigned long flags, bsp;
 	long ret;
=20
 	lock_kernel();
@@ -827,9 +808,12 @@
 	if (child->p_pptr !=3D current)
 		goto out_tsk;
=20
+	pt =3D ia64_task_regs(child);
+
 	switch (request) {
 	      case PTRACE_PEEKTEXT:
 	      case PTRACE_PEEKDATA:		/* read word at location addr */
+		bsp =3D ia64_get_user_bsp(child, pt);
 	        if (!(child->thread.flags & IA64_THREAD_KRBS_SYNCED)) {
 			struct mm_struct *mm;
 			long do_sync;
@@ -841,9 +825,9 @@
 			}
 			task_unlock(child);
 			if (do_sync)
-				sync_thread_rbs(child, mm, 0);
+				sync_thread_rbs(child, bsp, mm, 0);
 		}
-		ret =3D ia64_peek(regs, child, addr, &data);
+		ret =3D ia64_peek(child, bsp, addr, &data);
 		if (ret =3D 0) {
 			ret =3D data;
 			regs->r8 =3D 0;	/* ensure "ret" is not mistaken as an error code */
@@ -852,6 +836,7 @@
=20
 	      case PTRACE_POKETEXT:
 	      case PTRACE_POKEDATA:		/* write the word at location addr */
+		bsp =3D ia64_get_user_bsp(child, pt);
 	        if (!(child->thread.flags & IA64_THREAD_KRBS_SYNCED)) {
 			struct mm_struct *mm;
 			long do_sync;
@@ -863,9 +848,9 @@
 			}
 			task_unlock(child);
 			if (do_sync)
-				sync_thread_rbs(child, mm, 1);
+				sync_thread_rbs(child, bsp, mm, 1);
 		}
-		ret =3D ia64_poke(regs, child, addr, data);
+		ret =3D ia64_poke(child, bsp, addr, data);
 		goto out_tsk;
=20
 	      case PTRACE_PEEKUSR:		/* read the word at addr in the USER area */
@@ -887,21 +872,19 @@
=20
 	      case PTRACE_GETSIGINFO:
 		ret =3D -EIO;
-		if (!access_ok(VERIFY_WRITE, data, sizeof (siginfo_t))
-		    || child->thread.siginfo =3D 0)
+		if (!access_ok(VERIFY_WRITE, data, sizeof (siginfo_t)) || !child->thread=
.siginfo)
 			goto out_tsk;
-		copy_to_user((siginfo_t *) data, child->thread.siginfo, sizeof (siginfo_=
t));
-		ret =3D 0;
+		ret =3D copy_siginfo_to_user((siginfo_t *) data, child->thread.siginfo);
 		goto out_tsk;
-		break;
+
 	      case PTRACE_SETSIGINFO:
 		ret =3D -EIO;
 		if (!access_ok(VERIFY_READ, data, sizeof (siginfo_t))
 		    || child->thread.siginfo =3D 0)
 			goto out_tsk;
-		copy_from_user(child->thread.siginfo, (siginfo_t *) data, sizeof (siginf=
o_t));
-		ret =3D 0;
+		ret =3D copy_siginfo_from_user(child->thread.siginfo, (siginfo_t *) data=
);
 		goto out_tsk;
+
 	      case PTRACE_SYSCALL:	/* continue and stop at next (return from) sys=
call */
 	      case PTRACE_CONT:		/* restart after signal. */
 		ret =3D -EIO;
@@ -914,8 +897,8 @@
 		child->exit_code =3D data;
=20
 		/* make sure the single step/take-branch tra bits are not set: */
-		ia64_psr(ia64_task_regs(child))->ss =3D 0;
-		ia64_psr(ia64_task_regs(child))->tb =3D 0;
+		ia64_psr(pt)->ss =3D 0;
+		ia64_psr(pt)->tb =3D 0;
=20
 		/* Turn off flag indicating that the KRBS is sync'd with child's VM: */
 		child->thread.flags &=3D ~IA64_THREAD_KRBS_SYNCED;
@@ -935,8 +918,8 @@
 		child->exit_code =3D SIGKILL;
=20
 		/* make sure the single step/take-branch tra bits are not set: */
-		ia64_psr(ia64_task_regs(child))->ss =3D 0;
-		ia64_psr(ia64_task_regs(child))->tb =3D 0;
+		ia64_psr(pt)->ss =3D 0;
+		ia64_psr(pt)->tb =3D 0;
=20
 		/* Turn off flag indicating that the KRBS is sync'd with child's VM: */
 		child->thread.flags &=3D ~IA64_THREAD_KRBS_SYNCED;
@@ -953,9 +936,9 @@
=20
 		child->ptrace &=3D ~PT_TRACESYS;
 		if (request =3D PTRACE_SINGLESTEP) {
-			ia64_psr(ia64_task_regs(child))->ss =3D 1;
+			ia64_psr(pt)->ss =3D 1;
 		} else {
-			ia64_psr(ia64_task_regs(child))->tb =3D 1;
+			ia64_psr(pt)->tb =3D 1;
 		}
 		child->exit_code =3D data;
=20
@@ -981,8 +964,8 @@
 		write_unlock_irqrestore(&tasklist_lock, flags);
=20
 		/* make sure the single step/take-branch tra bits are not set: */
-		ia64_psr(ia64_task_regs(child))->ss =3D 0;
-		ia64_psr(ia64_task_regs(child))->tb =3D 0;
+		ia64_psr(pt)->ss =3D 0;
+		ia64_psr(pt)->tb =3D 0;
=20
 		/* Turn off flag indicating that the KRBS is sync'd with child's VM: */
 		child->thread.flags &=3D ~IA64_THREAD_KRBS_SYNCED;
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/setup.c lia64/ar=
ch/ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/setup.c	Thu Apr  5 09:56:52 2001
@@ -52,7 +52,7 @@
 struct cpuinfo_ia64 cpu_data[NR_CPUS] __attribute__ ((section ("__special_=
page_section")));
=20
 unsigned long ia64_cycles_per_usec;
-struct ia64_boot_param ia64_boot_param;
+struct ia64_boot_param *ia64_boot_param;
 struct screen_info screen_info;
 /* This tells _start which CPU is booting.  */
 int cpu_now_booting;
@@ -123,14 +123,7 @@
=20
 	unw_init();
=20
-	/*
-	 * The secondary bootstrap loader passes us the boot
-	 * parameters at the beginning of the ZERO_PAGE, so let's
-	 * stash away those values before ZERO_PAGE gets cleared out.
-	 */
-	memcpy(&ia64_boot_param, (void *) ZERO_PAGE_ADDR, sizeof(ia64_boot_param)=
);
-
-	*cmdline_p =3D __va(ia64_boot_param.command_line);
+	*cmdline_p =3D __va(ia64_boot_param->command_line);
 	strncpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
 	saved_command_line[COMMAND_LINE_SIZE-1] =3D '\0';		/* for safety */
=20
@@ -144,9 +137,8 @@
 	 * change APIs, they'd do things for the better.  Grumble...
 	 */
 	bootmap_start =3D PAGE_ALIGN(__pa(&_end));
-	if (ia64_boot_param.initrd_size)
-		bootmap_start =3D PAGE_ALIGN(bootmap_start
-					   + ia64_boot_param.initrd_size);
+	if (ia64_boot_param->initrd_size)
+		bootmap_start =3D PAGE_ALIGN(bootmap_start + ia64_boot_param->initrd_siz=
e);
 	bootmap_size =3D init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
=20
 	efi_memmap_walk(free_available_memory, 0);
@@ -154,7 +146,7 @@
 	reserve_bootmem(bootmap_start, bootmap_size);
=20
 #ifdef CONFIG_BLK_DEV_INITRD
-	initrd_start =3D ia64_boot_param.initrd_start;
+	initrd_start =3D ia64_boot_param->initrd_start;
=20
 	if (initrd_start) {
 		u64 start, size;
@@ -171,12 +163,12 @@
 			 * The loader ONLY passes physical addresses
 			 */
 			initrd_start =3D (unsigned long)__va(initrd_start);
-		initrd_end =3D initrd_start+ia64_boot_param.initrd_size;
+		initrd_end =3D initrd_start+ia64_boot_param->initrd_size;
 		start      =3D initrd_start;
-		size       =3D ia64_boot_param.initrd_size;
+		size       =3D ia64_boot_param->initrd_size;
=20
 		printk("Initial ramdisk at: 0x%p (%lu bytes)\n",
-		       (void *) initrd_start, ia64_boot_param.initrd_size);
+		       (void *) initrd_start, ia64_boot_param->initrd_size);
=20
 		/*
 		 * The kernel end and the beginning of initrd can be
@@ -398,6 +390,14 @@
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
=20
+	/*
+	 * We can't pass "local_cpu_data" do identify_cpu() because we haven't ca=
lled
+	 * ia64_mmu_init() yet.  And we can't call ia64_mmu_init() first because =
it
+	 * depends on the data returned by identify_cpu().  We break the dependen=
cy by
+	 * accessing cpu_data[] the old way, through identity mapped space.
+	 */
+	identify_cpu(&cpu_data[smp_processor_id()]);
+
 	/* Clear the stack memory reserved for pt_regs: */
 	memset(ia64_task_regs(current), 0, sizeof(struct pt_regs));
=20
@@ -417,8 +417,6 @@
=20
 	ia64_mmu_init();
=20
-	identify_cpu(local_cpu_data);
-
 #ifdef	CONFIG_IA32_SUPPORT
 	/* initialize global ia32 state - CR0 and CR4 */
 	__asm__("mov ar.cflg =3D %0"
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/signal.c lia64/a=
rch/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/signal.c	Thu Apr  5 09:57:11 2001
@@ -194,6 +194,43 @@
 		}
 		return err;
 	}
+}
+
+int
+copy_siginfo_from_user (siginfo_t *to, siginfo_t *from)
+{
+	if (!access_ok(VERIFY_READ, from, sizeof(siginfo_t)))
+		return -EFAULT;
+	if (__copy_from_user(to, from, sizeof(siginfo_t)) !=3D 0)
+		return -EFAULT;
+
+	if (SI_FROMUSER(to))
+		return 0;
+
+	to->si_code &=3D ~__SI_MASK;
+	if (to->si_code !=3D 0) {
+		switch (to->si_signo) {
+		      case SIGILL: case SIGFPE: case SIGSEGV: case SIGBUS: case SIGTRAP:
+			to->si_code |=3D __SI_FAULT;
+			break;
+
+		      case SIGCHLD:
+			to->si_code |=3D __SI_CHLD;
+			break;
+
+		      case SIGPOLL:
+			to->si_code |=3D __SI_POLL;
+			break;
+
+		      case SIGPROF:
+			to->si_code |=3D __SI_PROF;
+			break;
+
+		      default:
+			break;
+		}
+	}
+	return 0;
 }
=20
 long
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/smpboot.c lia64/=
arch/ia64/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/smpboot.c	Thu Apr  5 09:57:30 2001
@@ -1,52 +1,4 @@
 /*
- * Application processor startup code, moved from smp.c to better support =
kernel profile
- *
- * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 2000 Asit Mallick <Asit.K.Mallick@intel.com>
  */
=20
-#include <asm/kregs.h>
-#include <asm/pgtable.h>
-#include <asm/processor.h>
-
-/*=20
- * SAL shoves the AP's here when we start them.  Physical mode, no kernel =
TR,=20
- * no RRs set, better than even chance that psr is bogus.  Fix all that an=
d=20
- * call _start.  In effect, pretend to be lilo.
- *
- * Stolen from lilo_start.c.  Thanks David!=20
- */
-void
-start_ap (void)
-{
-	extern void _start (void);
-	unsigned long flags;
-
-	/*
-	 * Install a translation register that identity maps the kernel's 256MB p=
age(s).
-	 */
-	ia64_clear_ic(flags);
-	ia64_set_rr(PAGE_OFFSET, (ia64_rid(0, PAGE_OFFSET) << 8) | (_PAGE_SIZE_25=
6M << 2));
-	ia64_srlz_d();
-	ia64_itr(0x3, IA64_TR_KERNEL, PAGE_OFFSET,
-		 pte_val(mk_pte_phys(0, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
-		 _PAGE_SIZE_256M);
-	ia64_srlz_i();
-
-	flags =3D (IA64_PSR_IT | IA64_PSR_IC | IA64_PSR_DT | IA64_PSR_RT | IA64_P=
SR_DFH |=20
-		 IA64_PSR_BN);
-=09
-	asm volatile ("movl r8 =3D 1f\n"
-		      ";;\n"
-		      "mov cr.ipsr=3D%0\n"
-		      "mov cr.iip=3Dr8\n"=20
-		      "mov cr.ifs=3Dr0\n"
-		      ";;\n"
-		      "rfi;;"
-		      "1:\n"
-		      "movl r1 =3D __gp" :: "r"(flags) : "r8");
-	_start();
-}
-
-
+/* place holder... */
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/sys_ia64.c lia64=
/arch/ia64/kernel/sys_ia64.c
--- linux-davidm/arch/ia64/kernel/sys_ia64.c	Mon Apr  2 19:00:18 2001
+++ lia64/arch/ia64/kernel/sys_ia64.c	Thu Apr  5 09:57:58 2001
@@ -25,13 +25,14 @@
 get_unmapped_area (unsigned long addr, unsigned long len)
 {
 	struct vm_area_struct * vmm;
+	long map_shared =3D (current->thread.flags & IA64_THREAD_MAP_SHARED) !=3D=
 0;
=20
 	if (len > RGN_MAP_LIMIT)
 		return 0;
 	if (!addr)
 		addr =3D TASK_UNMAPPED_BASE;
=20
-	if (current->thread.flags & IA64_THREAD_MAP_SHARED)
+	if (map_shared)
 		addr =3D COLOR_ALIGN(addr);
 	else
 		addr =3D PAGE_ALIGN(addr);
@@ -45,6 +46,8 @@
 		if (!vmm || addr + len <=3D vmm->vm_start)
 			return addr;
 		addr =3D vmm->vm_end;
+		if (map_shared)
+			addr =3D COLOR_ALIGN(addr);
 	}
 }
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/traps.c lia64/ar=
ch/ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/traps.c	Thu Apr  5 09:59:25 2001
@@ -45,31 +45,10 @@
 void __init
 trap_init (void)
 {
-	printk("fpswa interface at %lx\n", ia64_boot_param.fpswa);
-	if (ia64_boot_param.fpswa) {
-#define OLD_FIRMWARE
-#ifdef OLD_FIRMWARE
-		/*
-		 * HACK to work around broken firmware.  This code
-		 * applies the label fixup to the FPSWA interface and
-		 * works both with old and new (fixed) firmware.
-		 */
-		unsigned long addr =3D (unsigned long) __va(ia64_boot_param.fpswa);
-		unsigned long gp_val =3D *(unsigned long *)(addr + 8);
-
-		/* go indirect and indexed to get table address */
-		addr =3D gp_val;
-		gp_val =3D *(unsigned long *)(addr + 8);
-
-		while (gp_val =3D *(unsigned long *)(addr + 8)) {
-			*(unsigned long *)addr |=3D PAGE_OFFSET;
-			*(unsigned long *)(addr + 8) |=3D PAGE_OFFSET;
-			addr +=3D 16;
-		}
-#endif
+	printk("fpswa interface at %lx\n", ia64_boot_param->fpswa);
+	if (ia64_boot_param->fpswa)
 		/* FPSWA fixup: make the interface pointer a kernel virtual address: */
-		fpswa_interface =3D __va(ia64_boot_param.fpswa);
-	}
+		fpswa_interface =3D __va(ia64_boot_param->fpswa);
 }
=20
 void
@@ -238,6 +217,7 @@
 {
 	fp_state_t fp_state;
 	fpswa_ret_t ret;
+#define FPSWA_BUG
 #ifdef FPSWA_BUG
 	struct ia64_fpreg f6_15[10];
 #endif
@@ -317,7 +297,7 @@
 	if (copy_from_user(bundle, (void *) fault_ip, sizeof(bundle)))
 		return -1;
=20
-	if (fpu_swa_count > 5 && jiffies - last_time > 5*HZ)
+	if (jiffies - last_time > 5*HZ)
 		fpu_swa_count =3D 0;
 	if (++fpu_swa_count < 5) {
 		last_time =3D jiffies;
@@ -441,7 +421,7 @@
 		unsigned long n =3D vector;
 		char buf[32], *cp;
=20
-		if (count > 5 && jiffies - last_time > 5*HZ)
+		if (jiffies - last_time > 5*HZ)
 			count =3D 0;
=20
 		if (count++ < 5) {
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/unaligned.c lia6=
4/arch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/unaligned.c	Thu Apr  5 09:59:47 2001
@@ -10,6 +10,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/smp_lock.h>
+
 #include <asm/uaccess.h>
 #include <asm/rse.h>
 #include <asm/processor.h>
@@ -324,11 +325,11 @@
=20
 	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%px\n", (void *) ubs_end, (void *) b=
sp, (void *) addr);
=20
-	ia64_poke(regs, current, (unsigned long) addr, val);
+	ia64_poke(current, (unsigned long) ubs_end, (unsigned long) addr, val);
=20
 	rnat_addr =3D ia64_rse_rnat_addr(addr);
=20
-	ia64_peek(regs, current, (unsigned long) rnat_addr, &rnats);
+	ia64_peek(current, (unsigned long) ubs_end, (unsigned long) rnat_addr, &r=
nats);
 	DPRINT("rnat @%p =3D 0x%lx nat=3D%d old nat=3D%ld\n",
 	       (void *) rnat_addr, rnats, nat, (rnats >> ia64_rse_slot_num(addr))=
 & 1);
=20
@@ -337,7 +338,7 @@
 		rnats |=3D  nat_mask;
 	else
 		rnats &=3D ~nat_mask;
-	ia64_poke(regs, current, (unsigned long) rnat_addr, rnats);
+	ia64_poke(current, (unsigned long) ubs_end, (unsigned long) rnat_addr, rn=
ats);
=20
 	DPRINT("rnat changed to @%p =3D 0x%lx\n", (void *) rnat_addr, rnats);
 }
@@ -393,7 +394,7 @@
=20
 	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%p\n", (void *) ubs_end, (void *) bs=
p, (void *) addr);
 =09
-	ia64_peek(regs, current, (unsigned long) addr, val);
+	ia64_peek(current, (unsigned long) ubs_end, (unsigned long) addr, val);
=20
 	if (nat) {
 		rnat_addr =3D ia64_rse_rnat_addr(addr);
@@ -401,7 +402,7 @@
=20
 		DPRINT("rnat @%p =3D 0x%lx\n", (void *) rnat_addr, rnats);
=20
-		ia64_peek(regs, current, (unsigned long) rnat_addr, &rnats);
+		ia64_peek(current, (unsigned long) ubs_end, (unsigned long) rnat_addr, &=
rnats);
 		*nat =3D (rnats & nat_mask) !=3D 0;
 	}
 }
@@ -424,8 +425,8 @@
 	}
=20
 	/*
-	 * Using r0 as a target raises a General Exception fault which has=20
-	 * higher priority than the Unaligned Reference fault.
+	 * Using r0 as a target raises a General Exception fault which has higher=
 priority
+	 * than the Unaligned Reference fault.
 	 */=20
=20
 	/*
@@ -1242,7 +1243,7 @@
 {
 	static unsigned long count, last_time;
=20
-	if (count > 5 && jiffies - last_time > 5*HZ)
+	if (jiffies - last_time > 5*HZ)
 		count =3D 0;
 	if (++count < 5) {
 		last_time =3D jiffies;
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/unwind.c lia64/a=
rch/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/kernel/unwind.c	Wed Mar 28 21:45:47 2001
@@ -1835,16 +1835,6 @@
 	unw_init_frame_info(info, t, sw);
 }
=20
-void
-unw_init_from_current (struct unw_frame_info *info, struct pt_regs *regs)
-{
-	struct switch_stack *sw =3D (struct switch_stack *) regs - 1;
-
-	unw_init_frame_info(info, current, sw);
-	/* skip over interrupt frame: */
-	unw_unwind(info);
-}
-
 static void
 init_unwind_table (struct unw_table *table, const char *name, unsigned lon=
g segment_base,
 		   unsigned long gp, void *table_start, void *table_end)
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/clear_user.S lia64/=
arch/ia64/lib/clear_user.S
--- linux-davidm/arch/ia64/lib/clear_user.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/lib/clear_user.S	Wed Mar 28 21:46:07 2001
@@ -51,22 +51,6 @@
 //	have side effects (same thing for writing).
 //
=20
-	.section "__ex_table", "a"		// declare section & section attributes
-	.previous
-
-// The label comes first because our store instruction contains a comma
-// and confuse the preprocessor otherwise
-
-#if __GNUC__ >=3D 3
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
-  [99:]	x
-#else
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
-  99:	x
-#endif
-
 GLOBAL_ENTRY(__do_clear_user)
 	.prologue
 	.save ar.pfs, saved_pfs
@@ -160,9 +144,7 @@
 	// (unlikely)  error recovery code
 	//
=20
-2:
-
-	EX(.Lexit3, st8 [buf]=3Dr0,16 )
+2:	EX(.Lexit3, st8 [buf]=3Dr0,16 )
 	;;				// needed to get len correct when error
 	st8 [buf2]=3Dr0,16
 	adds len=3D-16,len
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/copy_user.S lia64/a=
rch/ia64/lib/copy_user.S
--- linux-davidm/arch/ia64/lib/copy_user.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/lib/copy_user.S	Thu Apr  5 09:14:26 2001
@@ -30,22 +30,6 @@
  */
=20
 #include <asm/asmmacro.h>
-
-// The label comes first because our store instruction contains a comma
-// and confuse the preprocessor otherwise
-//
-#undef DEBUG
-#ifdef DEBUG
-#define EX(y,x...)				\
-99:	x
-#else
-#define EX(y,x...)				\
-	.section __ex_table,"a";		\
-	data4 @gprel(99f);			\
-	data4 y-99f;				\
-	.previous;				\
-99:	x
-#endif
=20
 //
 // Tuneable parameters
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/strlen_user.S lia64=
/arch/ia64/lib/strlen_user.S
--- linux-davidm/arch/ia64/lib/strlen_user.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/lib/strlen_user.S	Thu Apr  5 09:14:26 2001
@@ -69,19 +69,6 @@
 //	- Clearly performance tuning is required.
 //
=20
-	.section "__ex_table", "a"		// declare section & section attributes
-	.previous
-
-#if __GNUC__ >=3D 3
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
-  [99:]	x
-#else
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
-  99:	x
-#endif
-
 #define saved_pfs	r11
 #define	tmp		r10
 #define base		r16
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/strncpy_from_user.S=
 lia64/arch/ia64/lib/strncpy_from_user.S
--- linux-davidm/arch/ia64/lib/strncpy_from_user.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/lib/strncpy_from_user.S	Wed Mar 28 21:46:42 2001
@@ -18,19 +18,6 @@
=20
 #include <asm/asmmacro.h>
=20
-	.section "__ex_table", "a"		// declare section & section attributes
-	.previous
-
-#if __GNUC__ >=3D 3
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
-  [99:]	x
-#else
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
-  99:	x
-#endif
-
 GLOBAL_ENTRY(__strncpy_from_user)
 	alloc r2=3Dar.pfs,3,0,0,0
 	mov r8=3D0
@@ -52,13 +39,6 @@
 	;;
 (p6)	mov r8=3Din2		// buffer filled up---return buffer length
 (p7)	sub r8=3Din1,r9,1		// return string length (excluding NUL character)
-#if __GNUC__ >=3D 3
 [.Lexit:]
 	br.ret.sptk.few rp
-#else
-	br.ret.sptk.few rp
-
-.Lexit:
-	br.ret.sptk.few rp
-#endif
 END(__strncpy_from_user)
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/strnlen_user.S lia6=
4/arch/ia64/lib/strnlen_user.S
--- linux-davidm/arch/ia64/lib/strnlen_user.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/lib/strnlen_user.S	Wed Mar 28 21:46:53 2001
@@ -14,20 +14,6 @@
=20
 #include <asm/asmmacro.h>
=20
-	.section "__ex_table", "a"		// declare section & section attributes
-	.previous
-
-/* If a fault occurs, r8 gets set to -EFAULT and r9 gets cleared.  */
-#if __GNUC__ >=3D 3
-# define EXC(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
-  [99:]	x
-#else
-# define EXC(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
-  99:	x
-#endif
-
 GLOBAL_ENTRY(__strnlen_user)
 	.prologue
 	alloc r2=3Dar.pfs,2,0,0,0
@@ -43,7 +29,7 @@
 	;;
 	// XXX braindead strlen loop---this needs to be optimized
 .Loop1:
-	EXC(.Lexit, ld1 r8=3D[in0],1)
+	EXCLR(.Lexit, ld1 r8=3D[in0],1)
 	add r9=3D1,r9
 	;;
 	cmp.eq p6,p0=3Dr8,r0
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/swiotlb.c lia64/arc=
h/ia64/lib/swiotlb.c
--- linux-davidm/arch/ia64/lib/swiotlb.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/lib/swiotlb.c	Thu Apr  5 10:01:35 2001
@@ -169,8 +169,8 @@
 		 * sleep because we are called from with in interrupts!
 		 */
 		panic("map_single: could not allocate software IO TLB (%ld bytes)", size=
);
-found:
 	}
+  found:
 	spin_unlock_irqrestore(&io_tlb_lock, flags);
=20
 	/*
diff -urN --ignore-all-space linux-davidm/arch/ia64/mm/init.c lia64/arch/ia=
64/mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/mm/init.c	Thu Apr  5 10:02:20 2001
@@ -28,98 +28,12 @@
 /* References to section boundaries: */
 extern char _stext, _etext, _edata, __init_begin, __init_end;
=20
-/*
- * These are allocated in head.S so that we get proper page alignment.
- * If you change the size of these then change head.S as well.
- */
-extern char empty_bad_page[PAGE_SIZE];
-extern pmd_t empty_bad_pmd_table[PTRS_PER_PMD];
-extern pte_t empty_bad_pte_table[PTRS_PER_PTE];
-
 extern void ia64_tlb_init (void);
=20
 unsigned long MAX_DMA_ADDRESS =3D PAGE_OFFSET + 0x100000000UL;
=20
 static unsigned long totalram_pages;
=20
-/*
- * Fill in empty_bad_pmd_table with entries pointing to
- * empty_bad_pte_table and return the address of this PMD table.
- */
-static pmd_t *
-get_bad_pmd_table (void)
-{
-	pmd_t v;
-	int i;
-
-	pmd_set(&v, empty_bad_pte_table);
-
-	for (i =3D 0; i < PTRS_PER_PMD; ++i)
-		empty_bad_pmd_table[i] =3D v;
-
-	return empty_bad_pmd_table;
-}
-
-/*
- * Fill in empty_bad_pte_table with PTEs pointing to empty_bad_page
- * and return the address of this PTE table.
- */
-static pte_t *
-get_bad_pte_table (void)
-{
-	pte_t v;
-	int i;
-
-	set_pte(&v, pte_mkdirty(mk_pte_phys(__pa(empty_bad_page), PAGE_SHARED)));
-
-	for (i =3D 0; i < PTRS_PER_PTE; ++i)
-		empty_bad_pte_table[i] =3D v;
-
-	return empty_bad_pte_table;
-}
-
-void
-__handle_bad_pgd (pgd_t *pgd)
-{
-	pgd_ERROR(*pgd);
-	pgd_set(pgd, get_bad_pmd_table());
-}
-
-void
-__handle_bad_pmd (pmd_t *pmd)
-{
-	pmd_ERROR(*pmd);
-	pmd_set(pmd, get_bad_pte_table());
-}
-
-/*
- * Allocate and initialize an L3 directory page and set
- * the L2 directory entry PMD to the newly allocated page.
- */
-pte_t*
-get_pte_slow (pmd_t *pmd, unsigned long offset)
-{
-	pte_t *pte;
-
-	pte =3D (pte_t *) __get_free_page(GFP_KERNEL);
-	if (pmd_none(*pmd)) {
-		if (pte) {
-			/* everything A-OK */
-			clear_page(pte);
-			pmd_set(pmd, pte);
-			return pte + offset;
-		}
-		pmd_set(pmd, get_bad_pte_table());
-		return NULL;
-	}
-	free_page((unsigned long) pte);
-	if (pmd_bad(*pmd)) {
-		__handle_bad_pmd(pmd);
-		return NULL;
-	}
-	return (pte_t *) pmd_page(*pmd) + offset;
-}
-
 int
 do_check_pgt_cache (int low, int high)
 {
@@ -128,11 +42,11 @@
 	if (pgtable_cache_size > high) {
 		do {
 			if (pgd_quicklist)
-				free_page((unsigned long)get_pgd_fast()), ++freed;
+				free_page((unsigned long)pgd_alloc_one_fast()), ++freed;
 			if (pmd_quicklist)
-				free_page((unsigned long)get_pmd_fast()), ++freed;
+				free_page((unsigned long)pmd_alloc_one_fast(0, 0)), ++freed;
 			if (pte_quicklist)
-				free_page((unsigned long)get_pte_fast()), ++freed;
+				free_page((unsigned long)pte_alloc_one_fast(0, 0)), ++freed;
 		} while (pgtable_cache_size > low);
 	}
 	return freed;
@@ -289,25 +203,23 @@
 		       page_address(page));
=20
 	pgd =3D pgd_offset_k(address);		/* note: this is NOT pgd_offset()! */
-	pmd =3D pmd_alloc(pgd, address);
-	if (!pmd) {
-		__free_page(page);
-		panic("Out of memory.");
-		return 0;
-	}
-	pte =3D pte_alloc(pmd, address);
-	if (!pte) {
-		__free_page(page);
-		panic("Out of memory.");
-		return 0;
-	}
+
+	spin_lock(&init_mm.page_table_lock);
+	{
+		pmd =3D pmd_alloc(&init_mm, pgd, address);
+		if (!pmd)
+			goto out;
+		pte =3D pte_alloc(&init_mm, pmd, address);
+		if (!pte)
+			goto out;
 	if (!pte_none(*pte)) {
 		pte_ERROR(*pte);
-		__free_page(page);
-		return 0;
+			goto out;
 	}
 	flush_page_to_ram(page);
 	set_pte(pte, mk_pte(page, PAGE_GATE));
+	}
+  out:	spin_unlock(&init_mm.page_table_lock);
 	/* no need for flush_tlb */
 	return page;
 }
@@ -323,14 +235,14 @@
 #	define VHPT_ENABLE_BIT	1
 #endif
=20
-	/* Set up the kernel identity mappings (regions 6 & 7) and the vmalloc ar=
ea (region 5): */
+	/*
+	 * Set up the kernel identity mapping for regions 6 and 5.  The mapping f=
or region
+	 * 7 is setup up in _start().
+	 */
 	ia64_clear_ic(flags);
=20
 	rid =3D ia64_rid(IA64_REGION_ID_KERNEL, __IA64_UNCACHED_OFFSET);
-	ia64_set_rr(__IA64_UNCACHED_OFFSET, (rid << 8) | (_PAGE_SIZE_256M << 2));
-
-	rid =3D ia64_rid(IA64_REGION_ID_KERNEL, PAGE_OFFSET);
-	ia64_set_rr(PAGE_OFFSET, (rid << 8) | (_PAGE_SIZE_256M << 2));
+	ia64_set_rr(__IA64_UNCACHED_OFFSET, (rid << 8) | (_PAGE_SIZE_64M << 2));
=20
 	rid =3D ia64_rid(IA64_REGION_ID_KERNEL, VMALLOC_START);
 	ia64_set_rr(VMALLOC_START, (rid << 8) | (PAGE_SHIFT << 2) | 1);
diff -urN --ignore-all-space linux-davidm/arch/ia64/vmlinux.lds.S lia64/arc=
h/ia64/vmlinux.lds.S
--- linux-davidm/arch/ia64/vmlinux.lds.S	Thu Apr  5 12:02:10 2001
+++ lia64/arch/ia64/vmlinux.lds.S	Thu Apr  5 10:02:57 2001
@@ -5,7 +5,7 @@
=20
 OUTPUT_FORMAT("elf64-ia64-little")
 OUTPUT_ARCH(ia64)
-ENTRY(_start)
+ENTRY(phys_start)
 SECTIONS
 {
   /* Sections to be discarded */
@@ -16,6 +16,7 @@
 	}
=20
   v =3D PAGE_OFFSET;	/* this symbol is here to make debugging easier... */
+  phys_start =3D _start - PAGE_OFFSET;
=20
   . =3D KERNEL_START;
=20
@@ -41,7 +42,7 @@
=20
   /* Read-only data */
=20
-  __gp =3D ALIGN(8) + 0x200000;
+  __gp =3D ALIGN(16) + 0x200000;	/* gp must be 16-byte aligned for exc. ta=
ble */
=20
   /* Global data */
   _data =3D .;
@@ -67,9 +68,15 @@
 	{ *(__ksymtab) }
   __stop___ksymtab =3D .;
=20
+  __start___kallsyms =3D .;	/* All kernel symbols for debugging */
+  __kallsyms : AT(ADDR(__kallsyms) - PAGE_OFFSET)
+	{ *(__kallsyms) }
+  __stop___kallsyms =3D .;
+
   /* Unwind info & table: */
   .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - PAGE_OFFSET)
 	{ *(.IA_64.unwind_info*) }
+  . =3D ALIGN(8);
   ia64_unw_start =3D .;
   .IA_64.unwind : AT(ADDR(.IA_64.unwind) - PAGE_OFFSET)
 	{ *(.IA_64.unwind*) }
diff -urN --ignore-all-space linux-davidm/drivers/char/agp/agpgart_be.c lia=
64/drivers/char/agp/agpgart_be.c
--- linux-davidm/drivers/char/agp/agpgart_be.c	Thu Apr  5 12:02:10 2001
+++ lia64/drivers/char/agp/agpgart_be.c	Thu Apr  5 10:03:27 2001
@@ -1774,8 +1774,7 @@
 	}
 }
=20
-void *agp_add_fixup(struct vm_area_struct *vma, unsigned long size,=20
-							unsigned long offset)
+void *agp_add_fixup(struct vm_area_struct *vma, unsigned long size, unsign=
ed long offset)
 {
 	agp_fixup_entry_t *entry;
 	void *handle;
@@ -1822,10 +1821,8 @@
 	}
=20
 	spin_lock(&agp_fixup_lock);=09
-	for (pt =3D agp_fixup_list, prev =3D NULL; pt; prev =3D pt, pt =3D pt->ne=
xt)
-	{
-		if ((vma =3D NULL && pt->handle =3D ((unsigned long) handle)) ||
-			(pt->vma =3D vma)) {=20
+	for (pt =3D agp_fixup_list, prev =3D NULL; pt; prev =3D pt, pt =3D pt->ne=
xt) {
+		if ((vma =3D NULL && pt->handle =3D ((unsigned long) handle)) || (pt->vm=
a =3D vma)) {
=20
 			if (prev) {
 				prev->next =3D pt->next;
@@ -1844,9 +1841,8 @@
  * Look up and return the pte corresponding to addr.  Take into account th=
at
  * addr might be part of a vmmap in the vmalloc area.
  */
-static pte_t * agp_lookup_pte(struct vm_area_struct *vma, unsigned long ad=
dr,=20
-								int kernel) {
-
+static pte_t * agp_lookup_pte(struct vm_area_struct *vma, unsigned long ad=
dr, int kernel)
+{
 	pgd_t			*dir;
 	pmd_t			*pmd;
 	pte_t			*pte;
@@ -1977,14 +1973,12 @@
 				 * to previous fixups.
 				 */
 				if(old_pa !=3D offset)
-					atomic_dec(&virt_to_page(__va(old_pa))
-								->count);
+					atomic_dec(&virt_to_page(__va(old_pa))->count);
 				/*
 				 * Replace the physical page referenced by pte
 				 * with the new one.
 				 */
-				*pte =3D mk_pte_phys(new_pa,=20
-					__pgprot(pte_val(*pte) & ~_PFN_MASK));
+				*pte =3D mk_pte_phys(new_pa, __pgprot(pte_val(*pte) & ~_PFN_MASK));
=20
 				/*
 				 * Indicate that we're using this page. (This
@@ -2008,8 +2002,7 @@
 		 */=09
 		} else if(old_pa !=3D offset) {
 			atomic_dec(&virt_to_page(__va(old_pa))->count);
-			*pte =3D mk_pte_phys(offset,=20
-				__pgprot(pte_val(*pte) & ~_PFN_MASK));
+			*pte =3D mk_pte_phys(offset, __pgprot(pte_val(*pte) & ~_PFN_MASK));
 		}
=20
 		/*
diff -urN --ignore-all-space linux-davidm/drivers/char/agp/vmmap.c lia64/dr=
ivers/char/agp/vmmap.c
--- linux-davidm/drivers/char/agp/vmmap.c	Thu Apr  5 12:02:10 2001
+++ lia64/drivers/char/agp/vmmap.c	Thu Apr  5 10:03:51 2001
@@ -133,7 +133,7 @@
 	if (end > PGDIR_SIZE)
 		end =3D PGDIR_SIZE;
 	do {
-		pte_t * pte =3D pte_alloc_kernel(pmd, address);
+		pte_t * pte =3D pte_alloc(&init_mm, pmd, address);
 		if (!pte)
 			return -ENOMEM;
 		if (agp_alloc_area_pte(pte, address, end - address, target, prot))
@@ -154,11 +154,11 @@
=20
 	dir =3D pgd_offset_k(address);
 	flush_cache_all();
-	lock_kernel();
+	spin_lock(&init_mm.page_table_lock);
 	do {
 		pmd_t *pmd;
 	=09
-		pmd =3D pmd_alloc_kernel(dir, address);
+		pmd =3D pmd_alloc(&init_mm, dir, address);
 		ret =3D -ENOMEM;
 		if (!pmd)
 			break;
@@ -173,7 +173,7 @@
=20
 		ret =3D 0;
 	} while (address && (address < end));
-	unlock_kernel();
+	spin_unlock(&init_mm.page_table_lock);
 	flush_tlb_all();
 	return ret;
 }
@@ -193,8 +193,8 @@
 		if (tmp->addr =3D addr) {
 			*p =3D tmp->next;
 			agp_vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
-			kfree(tmp);
 			write_unlock(&vmlist_lock);
+			kfree(tmp);
 			return;
 		}
 	}
diff -urN --ignore-all-space linux-davidm/drivers/char/efirtc.c lia64/drive=
rs/char/efirtc.c
--- linux-davidm/drivers/char/efirtc.c	Mon Sep 18 14:57:01 2000
+++ lia64/drivers/char/efirtc.c	Thu Apr  5 10:04:04 2001
@@ -40,7 +40,7 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>
=20
-#define EFI_RTC_VERSION		"0.2"
+#define EFI_RTC_VERSION		"0.3"
=20
 #define EFI_ISDST (EFI_TIME_ADJUST_DAYLIGHT|EFI_TIME_IN_DAYLIGHT)
 /*
@@ -315,17 +315,12 @@
 	spin_unlock_irqrestore(&efi_rtc_lock,flags);
=20
 	p +=3D sprintf(p,
-		     "Time      :\n"
-		     "Year      : %u\n"
-		     "Month     : %u\n"
-		     "Day       : %u\n"
-		     "Hour      : %u\n"
-		     "Minute    : %u\n"
-		     "Second    : %u\n"
-		     "Nanosecond: %u\n"
+		     "Time          : %u:%u:%u.%09u\n"
+		     "Date          : %u-%u-%u\n"
 		     "Daylight  : %u\n",
-		     eft.year, eft.month, eft.day, eft.hour, eft.minute,
-		     eft.second, eft.nanosecond, eft.daylight);
+		     eft.hour, eft.minute, eft.second, eft.nanosecond,=20
+		     eft.year, eft.month, eft.day,
+		     eft.daylight);
=20
 	if ( eft.timezone =3D EFI_UNSPECIFIED_TIMEZONE)
 		p +=3D sprintf(p, "Timezone  : unspecified\n");
@@ -335,33 +330,27 @@
 	=09
=20
 	p +=3D sprintf(p,
-		     "\nWakeup Alm:\n"
+		     "Alarm Time     : %u:%u:%u.%09u\n"
+		     "Alarm Date     : %u-%u-%u\n"
+		     "Alarm Daylight : %u\n"
 		     "Enabled   : %s\n"
-		     "Pending   : %s\n"
-		     "Year      : %u\n"
-		     "Month     : %u\n"
-		     "Day       : %u\n"
-		     "Hour      : %u\n"
-		     "Minute    : %u\n"
-		     "Second    : %u\n"
-		     "Nanosecond: %u\n"
-		     "Daylight  : %u\n",
-		     enabled =3D 1 ? "Yes" : "No",
-		     pending =3D 1 ? "Yes" : "No",
-		     alm.year, alm.month, alm.day, alm.hour, alm.minute,
-		     alm.second, alm.nanosecond, alm.daylight);
+		     "Pending        : %s\n",
+		     alm.hour, alm.minute, alm.second, alm.nanosecond,=20
+		     alm.year, alm.month, alm.day,=20
+		     alm.daylight,
+		     enabled =3D 1 ? "yes" : "no",
+		     pending =3D 1 ? "yes" : "no");
=20
 	if ( eft.timezone =3D EFI_UNSPECIFIED_TIMEZONE)
 		p +=3D sprintf(p, "Timezone  : unspecified\n");
 	else
 		/* XXX fixme: convert to string? */
-		p +=3D sprintf(p, "Timezone  : %u\n", eft.timezone);
+		p +=3D sprintf(p, "Timezone       : %u\n", alm.timezone);
=20
 	/*
 	 * now prints the capabilities
 	 */
 	p +=3D sprintf(p,
-		     "\nClock Cap :\n"
 		     "Resolution: %u\n"
 		     "Accuracy  : %u\n"
 		     "SetstoZero: %u\n",
@@ -390,7 +379,7 @@
=20
 	misc_register(&efi_rtc_dev);
=20
-	create_proc_read_entry ("efirtc", 0, NULL, efi_rtc_read_proc, NULL);
+	create_proc_read_entry ("driver/efirtc", 0, NULL, efi_rtc_read_proc, NULL=
);
=20
 	return 0;
 }
diff -urN --ignore-all-space linux-davidm/fs/binfmt_elf.c lia64/fs/binfmt_e=
lf.c
--- linux-davidm/fs/binfmt_elf.c	Mon Apr  2 19:01:51 2001
+++ lia64/fs/binfmt_elf.c	Thu Apr  5 10:05:23 2001
@@ -140,7 +140,7 @@
 	 */
 	sp =3D (elf_addr_t *)((~15UL & (unsigned long)(u_platform)) - 16UL);
 	csp =3D sp;
-	csp -=3D ((exec ? DLINFO_ITEMS*2 : 4) + (k_platform ? 2 : 0));
+	csp -=3D DLINFO_ITEMS*2 + (k_platform ? 2 : 0);
 	csp -=3D envc+1;
 	csp -=3D argc+1;
 	csp -=3D (!ibcs ? 3 : 1);	/* argc itself */
@@ -160,25 +160,20 @@
 		sp -=3D 2;
 		NEW_AUX_ENT(0, AT_PLATFORM, (elf_addr_t)(unsigned long) u_platform);
 	}
-	sp -=3D 3*2;
+	sp -=3D DLINFO_ITEMS*2;
 	NEW_AUX_ENT(0, AT_HWCAP, hwcap);
 	NEW_AUX_ENT(1, AT_PAGESZ, ELF_EXEC_PAGESIZE);
 	NEW_AUX_ENT(2, AT_CLKTCK, CLOCKS_PER_SEC);
-
-	if (exec) {
-		sp -=3D 10*2;
-
-		NEW_AUX_ENT(0, AT_PHDR, load_addr + exec->e_phoff);
-		NEW_AUX_ENT(1, AT_PHENT, sizeof (struct elf_phdr));
-		NEW_AUX_ENT(2, AT_PHNUM, exec->e_phnum);
-		NEW_AUX_ENT(3, AT_BASE, interp_load_addr);
-		NEW_AUX_ENT(4, AT_FLAGS, 0);
-		NEW_AUX_ENT(5, AT_ENTRY, load_bias + exec->e_entry);
-		NEW_AUX_ENT(6, AT_UID, (elf_addr_t) current->uid);
-		NEW_AUX_ENT(7, AT_EUID, (elf_addr_t) current->euid);
-		NEW_AUX_ENT(8, AT_GID, (elf_addr_t) current->gid);
-		NEW_AUX_ENT(9, AT_EGID, (elf_addr_t) current->egid);
-	}
+	NEW_AUX_ENT( 3, AT_PHDR, load_addr + exec->e_phoff);
+	NEW_AUX_ENT( 4, AT_PHENT, sizeof (struct elf_phdr));
+	NEW_AUX_ENT( 5, AT_PHNUM, exec->e_phnum);
+	NEW_AUX_ENT( 6, AT_BASE, interp_load_addr);
+	NEW_AUX_ENT( 7, AT_FLAGS, 0);
+	NEW_AUX_ENT( 8, AT_ENTRY, load_bias + exec->e_entry);
+	NEW_AUX_ENT( 9, AT_UID, (elf_addr_t) current->uid);
+	NEW_AUX_ENT(10, AT_EUID, (elf_addr_t) current->euid);
+	NEW_AUX_ENT(11, AT_GID, (elf_addr_t) current->gid);
+	NEW_AUX_ENT(12, AT_EGID, (elf_addr_t) current->egid);
 #undef NEW_AUX_ENT
=20
 	sp -=3D envc+1;
@@ -694,7 +689,7 @@
 	  create_elf_tables((char *)bprm->p,
 			bprm->argc,
 			bprm->envc,
-			(interpreter_type =3D INTERPRETER_ELF ? &elf_ex : NULL),
+			&elf_ex,
 			load_addr, load_bias,
 			interp_load_addr,
 			(interpreter_type =3D INTERPRETER_AOUT ? 0 : 1));
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/a.out.h lia64/in=
clude/asm-ia64/a.out.h
--- linux-davidm/include/asm-ia64/a.out.h	Thu Jan  4 22:40:20 2001
+++ lia64/include/asm-ia64/a.out.h	Thu Apr  5 11:51:41 2001
@@ -30,7 +30,8 @@
 #define N_TXTOFF(x)	0
=20
 #ifdef __KERNEL__
-# define STACK_TOP	(0x8000000000000000UL + (1UL << (4*PAGE_SHIFT - 12)))
+# include <asm/page.h>
+# define STACK_TOP	(0x8000000000000000UL + (1UL << (4*PAGE_SHIFT - 12)) - =
PAGE_SIZE)
 # define IA64_RBS_BOT	(STACK_TOP - 0x80000000L)	/* bottom of register back=
ing store */
 #endif
=20
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/asmmacro.h lia64=
/include/asm-ia64/asmmacro.h
--- linux-davidm/include/asm-ia64/asmmacro.h	Thu Apr  5 12:02:11 2001
+++ lia64/include/asm-ia64/asmmacro.h	Wed Mar 28 21:47:53 2001
@@ -29,4 +29,27 @@
 #define ASM_UNW_PRLG_PR			0x1
 #define ASM_UNW_PRLG_GRSAVE(ninputs)	(32+(ninputs))
=20
+/*
+ * Helper macros for accessing user memory.
+ */
+
+	.section "__ex_table", "a"		// declare section & section attributes
+	.previous
+
+#if __GNUC__ >=3D 3
+# define EX(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  [99:]	x
+# define EXCLR(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
+  [99:]	x
+#else
+# define EX(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  99:	x
+# define EXCLR(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
+  99:	x
+#endif
+
 #endif /* _ASM_IA64_ASMMACRO_H */
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/io.h lia64/inclu=
de/asm-ia64/io.h
--- linux-davidm/include/asm-ia64/io.h	Thu Jan  4 22:40:20 2001
+++ lia64/include/asm-ia64/io.h	Thu Apr  5 11:51:41 2001
@@ -13,8 +13,8 @@
  * over and over again with slight variations and possibly making a
  * mistake somewhere.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  */
@@ -82,21 +82,11 @@
 }
=20
 /*
- * For the in/out instructions, we need to do:
- *
- *	o "mf" _before_ doing the I/O access to ensure that all prior
- *	  accesses to memory occur before the I/O access
- *	o "mf.a" _after_ doing the I/O access to ensure that the access
- *	  has completed before we're doing any other I/O accesses
- *
- * The former is necessary because we might be doing normal (cached) memory
- * accesses, e.g., to set up a DMA descriptor table and then do an "outX()"
- * to tell the DMA controller to start the DMA operation.  The "mf" ahead
- * of the I/O operation ensures that the DMA table is correct when the I/O
- * access occurs.
- *
- * The mf.a is necessary to ensure that all I/O access occur in program
- * order. --davidm 99/12/07=20
+ * For the in/out routines, we need to do "mf.a" _after_ doing the I/O acc=
ess to ensure
+ * that the access has completed before executing other I/O accesses.  Sin=
ce we're doing
+ * the accesses through an uncachable (UC) translation, the CPU will execu=
te them in
+ * program order.  However, we still need to tell the compiler not to shuf=
fle them around
+ * during optimization, which is why we use "volatile" pointers.
  */
=20
 static inline unsigned int
@@ -378,11 +368,10 @@
 #endif
=20
 /*
- * An "address" in IO memory space is not clearly either an integer
- * or a pointer. We will accept both, thus the casts.
+ * An "address" in IO memory space is not clearly either an integer or a p=
ointer. We will
+ * accept both, thus the casts.
  *
- * On ia-64, we access the physical I/O memory space through the
- * uncached kernel region.
+ * On ia-64, we access the physical I/O memory space through the uncached =
kernel region.
  */
 static inline void *
 ioremap (unsigned long offset, unsigned long size)
@@ -412,75 +401,6 @@
   __ia64_memcpy_toio((unsigned long)(to),(from),(len))
 #define memset_io(addr,c,len) \
   __ia64_memset_c_io((unsigned long)(addr),0x0101010101010101UL*(u8)(c),(l=
en))
-
-#define __HAVE_ARCH_MEMSETW_IO
-#define memsetw_io(addr,c,len) \
-  _memset_c_io((unsigned long)(addr),0x0001000100010001UL*(u16)(c),(len))
-
-/*
- * XXX - We don't have csum_partial_copy_fromio() yet, so we cheat here an=
d=20
- * just copy it. The net code will then do the checksum later. Presently=20
- * only used by some shared memory 8390 Ethernet cards anyway.
- */
-
-#define eth_io_copy_and_sum(skb,src,len,unused)		memcpy_fromio((skb)->data=
,(src),(len))
-
-#if 0
-
-/*
- * XXX this is the kind of legacy stuff we want to get rid of with IA-64..=
. --davidm 99/12/02
- */
-
-/*
- * This is used for checking BIOS signatures.  It's not clear at all
- * why this is here.  This implementation seems to be the same on
- * all architectures.  Strange.
- */
-static inline int
-check_signature (unsigned long io_addr, const unsigned char *signature, in=
t length)
-{
-	int retval =3D 0;
-	do {
-		if (readb(io_addr) !=3D *signature)
-			goto out;
-		io_addr++;
-		signature++;
-		length--;
-	} while (length);
-	retval =3D 1;
-out:
-	return retval;
-}
-
-#define RTC_PORT(x)		(0x70 + (x))
-#define RTC_ALWAYS_BCD		0
-
-#endif
-
-/*
- * The caches on some architectures aren't DMA-coherent and have need
- * to handle this in software.  There are two types of operations that
- * can be applied to dma buffers.
- *
- * - dma_cache_inv(start, size) invalidates the affected parts of the
- *   caches.  Dirty lines of the caches may be written back or simply
- *   be discarded.  This operation is necessary before dma operations
- *   to the memory.
- *
- * - dma_cache_wback(start, size) makes caches and memory coherent
- *   by writing the content of the caches back to memory, if necessary
- *   (cache flush).
- *
- * - dma_cache_wback_inv(start, size) Like dma_cache_wback() but the
- *   function also invalidates the affected part of the caches as
- *   necessary before DMA transfers from outside to memory.
- *
- * Fortunately, the IA-64 architecture mandates cache-coherent DMA, so
- * these functions can be implemented as no-ops.
- */
-#define dma_cache_inv(_start,_size)		do { } while (0)
-#define dma_cache_wback(_start,_size)		do { } while (0)
-#define dma_cache_wback_inv(_start,_size)	do { } while (0)
=20
 # endif /* __KERNEL__ */
 #endif /* _ASM_IA64_IO_H */
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/mmu_context.h li=
a64/include/asm-ia64/mmu_context.h
--- linux-davidm/include/asm-ia64/mmu_context.h	Thu Apr  5 12:02:11 2001
+++ lia64/include/asm-ia64/mmu_context.h	Thu Apr  5 11:51:42 2001
@@ -6,11 +6,6 @@
  * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
-#include <linux/sched.h>
-#include <linux/spinlock.h>
-
-#include <asm/processor.h>
-
 /*
  * Routines to manage the allocation of task context numbers.  Task contex=
t numbers are
  * used to reduce or eliminate the need to perform TLB flushes due to cont=
ext switches.
@@ -24,6 +19,15 @@
=20
 #define IA64_REGION_ID_KERNEL	0 /* the kernel's region id (tlb.c depends o=
n this being 0) */
=20
+#define ia64_rid(ctx,addr)	(((ctx) << 3) | (addr >> 61))
+
+# ifndef __ASSEMBLY__
+
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+
+#include <asm/processor.h>
+
 struct ia64_ctx {
 	spinlock_t lock;
 	unsigned int next;	/* next context number to use */
@@ -40,12 +44,6 @@
 {
 }
=20
-static inline unsigned long
-ia64_rid (unsigned long context, unsigned long region_addr)
-{
-	return context << 3 | (region_addr >> 61);
-}
-
 static inline void
 get_new_mmu_context (struct mm_struct *mm)
 {
@@ -123,4 +121,5 @@
=20
 #define switch_mm(prev_mm,next_mm,next_task,cpu)	activate_mm(prev_mm, next=
_mm)
=20
+# endif /* ! __ASSEMBLY__ */
 #endif /* _ASM_IA64_MMU_CONTEXT_H */
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/pgalloc.h lia64/=
include/asm-ia64/pgalloc.h
--- linux-davidm/include/asm-ia64/pgalloc.h	Thu Apr  5 12:02:11 2001
+++ lia64/include/asm-ia64/pgalloc.h	Thu Apr  5 11:52:05 2001
@@ -33,63 +33,55 @@
 #define pte_quicklist		(local_cpu_data->pte_quick)
 #define pgtable_cache_size	(local_cpu_data->pgtable_cache_sz)
=20
-static __inline__ pgd_t*
-get_pgd_slow (void)
-{
-	pgd_t *ret =3D (pgd_t *)__get_free_page(GFP_KERNEL);
-	if (ret)
-		clear_page(ret);
-	return ret;
-}
-
-static __inline__ pgd_t*
-get_pgd_fast (void)
+static inline pgd_t*
+pgd_alloc_one_fast (void)
 {
 	unsigned long *ret =3D pgd_quicklist;
=20
-	if (ret !=3D NULL) {
+	if (__builtin_expect(ret !=3D NULL, 1)) {
 		pgd_quicklist =3D (unsigned long *)(*ret);
 		ret[0] =3D 0;
 		--pgtable_cache_size;
-	}
+	} else
+		ret =3D NULL;
 	return (pgd_t *)ret;
 }
=20
-static __inline__ pgd_t*
+static inline pgd_t*
 pgd_alloc (void)
 {
-	pgd_t *pgd;
+	/* the VM system never calls pgd_alloc_one_fast(), so we do it here. */
+	pgd_t *pgd =3D pgd_alloc_one_fast();
=20
-	pgd =3D get_pgd_fast();
-	if (!pgd)
-		pgd =3D get_pgd_slow();
+	if (__builtin_expect(pgd =3D NULL, 0)) {
+		pgd =3D (pgd_t *)__get_free_page(GFP_KERNEL);
+		if (__builtin_expect(pgd !=3D NULL, 1))
+			clear_page(pgd);
+	}
 	return pgd;
 }
=20
-static __inline__ void
-free_pgd_fast (pgd_t *pgd)
+static inline void
+pgd_free (pgd_t *pgd)
 {
 	*(unsigned long *)pgd =3D (unsigned long) pgd_quicklist;
 	pgd_quicklist =3D (unsigned long *) pgd;
 	++pgtable_cache_size;
 }
=20
-static __inline__ pmd_t *
-get_pmd_slow (void)
+static inline void
+pgd_populate (struct mm_struct *mm, pgd_t *pgd_entry, pmd_t *pmd)
 {
-	pmd_t *pmd =3D (pmd_t *) __get_free_page(GFP_KERNEL);
-
-	if (pmd)
-		clear_page(pmd);
-	return pmd;
+	pgd_val(*pgd_entry) =3D __pa(pmd);
 }
=20
-static __inline__ pmd_t *
-get_pmd_fast (void)
+
+static inline pmd_t*
+pmd_alloc_one_fast (struct mm_struct *mm, unsigned long addr)
 {
 	unsigned long *ret =3D (unsigned long *)pmd_quicklist;
=20
-	if (ret !=3D NULL) {
+	if (__builtin_expect(ret !=3D NULL, 1)) {
 		pmd_quicklist =3D (unsigned long *)(*ret);
 		ret[0] =3D 0;
 		--pgtable_cache_size;
@@ -97,28 +89,36 @@
 	return (pmd_t *)ret;
 }
=20
-static __inline__ void
-free_pmd_fast (pmd_t *pmd)
+static inline pmd_t*
+pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
+{
+	pmd_t *pmd =3D (pmd_t *) __get_free_page(GFP_KERNEL);
+
+	if (__builtin_expect(pmd !=3D NULL, 1))
+		clear_page(pmd);
+	return pmd;
+}
+
+static inline void
+pmd_free (pmd_t *pmd)
 {
 	*(unsigned long *)pmd =3D (unsigned long) pmd_quicklist;
 	pmd_quicklist =3D (unsigned long *) pmd;
 	++pgtable_cache_size;
 }
=20
-static __inline__ void
-free_pmd_slow (pmd_t *pmd)
+static inline void
+pmd_populate (struct mm_struct *mm, pmd_t *pmd_entry, pte_t *pte)
 {
-	free_page((unsigned long)pmd);
+	pmd_val(*pmd_entry) =3D __pa(pte);
 }
=20
-extern pte_t *get_pte_slow (pmd_t *pmd, unsigned long address_preadjusted);
-
-static __inline__ pte_t *
-get_pte_fast (void)
+static inline pte_t*
+pte_alloc_one_fast (struct mm_struct *mm, unsigned long addr)
 {
 	unsigned long *ret =3D (unsigned long *)pte_quicklist;
=20
-	if (ret !=3D NULL) {
+	if (__builtin_expect(ret !=3D NULL, 1)) {
 		pte_quicklist =3D (unsigned long *)(*ret);
 		ret[0] =3D 0;
 		--pgtable_cache_size;
@@ -126,71 +126,25 @@
 	return (pte_t *)ret;
 }
=20
-static __inline__ void
-free_pte_fast (pte_t *pte)
-{
-	*(unsigned long *)pte =3D (unsigned long) pte_quicklist;
-	pte_quicklist =3D (unsigned long *) pte;
-	++pgtable_cache_size;
-}
=20
-#define pte_free_kernel(pte)	free_pte_fast(pte)
-#define pte_free(pte)		free_pte_fast(pte)
-#define pmd_free_kernel(pmd)	free_pmd_fast(pmd)
-#define pmd_free(pmd)		free_pmd_fast(pmd)
-#define pgd_free(pgd)		free_pgd_fast(pgd)
-
-extern void __handle_bad_pgd (pgd_t *pgd);
-extern void __handle_bad_pmd (pmd_t *pmd);
-
-static __inline__ pte_t*
-pte_alloc (pmd_t *pmd, unsigned long vmaddr)
+static inline pte_t*
+pte_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	unsigned long offset;
-
-	offset =3D (vmaddr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
-	if (pmd_none(*pmd)) {
-		pte_t *pte_page =3D get_pte_fast();
+	pte_t *pte =3D (pte_t *) __get_free_page(GFP_KERNEL);
=20
-		if (!pte_page)
-			return get_pte_slow(pmd, offset);
-		pmd_set(pmd, pte_page);
-		return pte_page + offset;
-	}
-	if (pmd_bad(*pmd)) {
-		__handle_bad_pmd(pmd);
-		return NULL;
-	}
-	return (pte_t *) pmd_page(*pmd) + offset;
+	if (__builtin_expect(pte !=3D NULL, 1))
+		clear_page(pte);
+	return pte;
 }
=20
-static __inline__ pmd_t*
-pmd_alloc (pgd_t *pgd, unsigned long vmaddr)
+static inline void
+pte_free (pte_t *pte)
 {
-	unsigned long offset;
-
-	offset =3D (vmaddr >> PMD_SHIFT) & (PTRS_PER_PMD - 1);
-	if (pgd_none(*pgd)) {
-		pmd_t *pmd_page =3D get_pmd_fast();
-
-		if (!pmd_page)
-			pmd_page =3D get_pmd_slow();
-		if (pmd_page) {
-			pgd_set(pgd, pmd_page);
-			return pmd_page + offset;
-		} else
-			return NULL;
-	}
-	if (pgd_bad(*pgd)) {
-		__handle_bad_pgd(pgd);
-		return NULL;
-	}
-	return (pmd_t *) pgd_page(*pgd) + offset;
+	*(unsigned long *)pte =3D (unsigned long) pte_quicklist;
+	pte_quicklist =3D (unsigned long *) pte;
+	++pgtable_cache_size;
 }
=20
-#define pte_alloc_kernel(pmd, addr)	pte_alloc(pmd, addr)
-#define pmd_alloc_kernel(pgd, addr)	pmd_alloc(pgd, addr)
-
 extern int do_check_pgt_cache (int, int);
=20
 /*
@@ -219,7 +173,7 @@
 /*
  * Flush a specified user mapping
  */
-static __inline__ void
+static inline void
 flush_tlb_mm (struct mm_struct *mm)
 {
 	if (mm) {
@@ -237,7 +191,7 @@
 /*
  * Page-granular tlb flush.
  */
-static __inline__ void
+static inline void
 flush_tlb_page (struct vm_area_struct *vma, unsigned long addr)
 {
 #ifdef CONFIG_SMP
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/pgtable.h lia64/=
include/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Thu Apr  5 12:02:11 2001
+++ lia64/include/asm-ia64/pgtable.h	Thu Apr  5 11:51:44 2001
@@ -205,25 +205,12 @@
 #define set_pte(ptep, pteval)	(*(ptep) =3D (pteval))
=20
 #define RGN_SIZE	(1UL << 61)
-#define RGN_MAP_LIMIT	(1UL << (4*PAGE_SHIFT - 12))	/* limit of mappable ar=
ea in region */
+#define RGN_MAP_LIMIT	((1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)	/* per re=
gion addr limit */
 #define RGN_KERNEL	7
=20
 #define VMALLOC_START		(0xa000000000000000 + 3*PAGE_SIZE)
 #define VMALLOC_VMADDR(x)	((unsigned long)(x))
-#define VMALLOC_END		(0xa000000000000000 + RGN_MAP_LIMIT)
-
-/*
- * BAD_PAGETABLE is used when we need a bogus page-table, while
- * BAD_PAGE is used for a bogus page.
- *
- * ZERO_PAGE is a global shared page that is always zero:  used
- * for zero-mapped memory areas etc..
- */
-extern pte_t ia64_bad_page (void);
-extern pmd_t *ia64_bad_pagetable (void);
-
-#define BAD_PAGETABLE	ia64_bad_pagetable()
-#define BAD_PAGE	ia64_bad_page()
+#define VMALLOC_END		(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
=20
 /*
  * Conversion functions: convert a page and protection to a page entry,
@@ -253,14 +240,12 @@
 /* pte_page() returns the "struct page *" corresponding to the PTE: */
 #define pte_page(pte)			(mem_map + (unsigned long) ((pte_val(pte) & _PFN_M=
ASK) >> PAGE_SHIFT))
=20
-#define pmd_set(pmdp, ptep) 		(pmd_val(*(pmdp)) =3D __pa(ptep))
 #define pmd_none(pmd)			(!pmd_val(pmd))
 #define pmd_bad(pmd)			(!ia64_phys_addr_valid(pmd_val(pmd)))
 #define pmd_present(pmd)		(pmd_val(pmd) !=3D 0UL)
 #define pmd_clear(pmdp)			(pmd_val(*(pmdp)) =3D 0UL)
 #define pmd_page(pmd)			((unsigned long) __va(pmd_val(pmd) & _PFN_MASK))
=20
-#define pgd_set(pgdp, pmdp)		(pgd_val(*(pgdp)) =3D __pa(pmdp))
 #define pgd_none(pgd)			(!pgd_val(pgd))
 #define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
 #define pgd_present(pgd)		(pgd_val(pgd) !=3D 0UL)
@@ -303,7 +288,11 @@
  * works bypasses the caches, but does allow for consecutive writes to
  * be combined into single (but larger) write transactions.
  */
+#ifdef CONFIG_MCKINLEY_A0_SPECIFIC
+# define pgprot_writecombine(prot)	prot
+#else
 #define pgprot_writecombine(prot)	__pgprot((pgprot_val(prot) & ~_PAGE_MA_M=
ASK) | _PAGE_MA_WC)
+#endif
=20
 /*
  * Return the region index for virtual address ADDRESS.
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/ptrace.h lia64/i=
nclude/asm-ia64/ptrace.h
--- linux-davidm/include/asm-ia64/ptrace.h	Thu Apr  5 12:02:11 2001
+++ lia64/include/asm-ia64/ptrace.h	Thu Apr  5 11:51:41 2001
@@ -220,10 +220,11 @@
   struct task_struct;			/* forward decl */
=20
   extern void show_regs (struct pt_regs *);
-  extern long ia64_peek (struct pt_regs *, struct task_struct *, unsigned =
long addr, long *val);
-  extern long ia64_poke (struct pt_regs *, struct task_struct *, unsigned =
long addr, long val);
-  extern void ia64_flush_fph (struct task_struct *t);
-  extern void ia64_sync_fph (struct task_struct *t);
+  extern unsigned long ia64_get_user_bsp (struct task_struct *, struct pt_=
regs *);
+  extern long ia64_peek (struct task_struct *, unsigned long, unsigned lon=
g, long *);
+  extern long ia64_poke (struct task_struct *, unsigned long, unsigned lon=
g, long);
+  extern void ia64_flush_fph (struct task_struct *);
+  extern void ia64_sync_fph (struct task_struct *);
=20
   /* get nat bits for scratch registers such that bit N=3D1 iff scratch re=
gister rN is a NaT */
   extern unsigned long ia64_get_scratch_nat_bits (struct pt_regs *pt, unsi=
gned long scratch_unat);
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/siginfo.h lia64/=
include/asm-ia64/siginfo.h
--- linux-davidm/include/asm-ia64/siginfo.h	Thu Apr  5 12:02:11 2001
+++ lia64/include/asm-ia64/siginfo.h	Thu Apr  5 11:51:41 2001
@@ -216,10 +216,9 @@
 /*
  * sigevent definitions
  *=20
- * It seems likely that SIGEV_THREAD will have to be handled from=20
- * userspace, libpthread transmuting it to SIGEV_SIGNAL, which the
- * thread manager then catches and does the appropriate nonsense.
- * However, everything is written out here so as to not get lost.
+ * It seems likely that SIGEV_THREAD will have to be handled from userspac=
e, libpthread
+ * transmuting it to SIGEV_SIGNAL, which the thread manager then catches a=
nd does the
+ * appropriate nonsense.  However, everything is written out here so as to=
 not get lost.
  */
 #define SIGEV_SIGNAL	0	/* notify via signal */
 #define SIGEV_NONE	1	/* other notification: meaningless */
@@ -259,6 +258,7 @@
 }
=20
 extern int copy_siginfo_to_user(siginfo_t *to, siginfo_t *from);
+extern int copy_siginfo_from_user(siginfo_t *to, siginfo_t *from);
=20
 #endif /* __KERNEL__ */
=20
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/system.h lia64/i=
nclude/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Thu Apr  5 12:02:11 2001
+++ lia64/include/asm-ia64/system.h	Thu Apr  5 11:51:41 2001
@@ -16,14 +16,15 @@
=20
 #include <asm/page.h>
=20
-#define KERNEL_START		(PAGE_OFFSET + 0x500000)
+#define KERNEL_START		(PAGE_OFFSET + 68*1024*1024)
=20
 /*
  * The following #defines must match with vmlinux.lds.S:
  */
+#define IVT_ADDR		(KERNEL_START)
 #define IVT_END_ADDR		(KERNEL_START + 0x8000)
-#define ZERO_PAGE_ADDR		(IVT_END_ADDR + 0*PAGE_SIZE)
-#define SWAPPER_PGD_ADDR	(IVT_END_ADDR + 1*PAGE_SIZE)
+#define ZERO_PAGE_ADDR		PAGE_ALIGN(IVT_END_ADDR)
+#define SWAPPER_PGD_ADDR	(ZERO_PAGE_ADDR + 1*PAGE_SIZE)
=20
 #define GATE_ADDR		(0xa000000000000000 + PAGE_SIZE)
 #define PERCPU_ADDR		(0xa000000000000000 + 2*PAGE_SIZE)
@@ -63,12 +64,10 @@
 		__u16 orig_x;	/* cursor's x position */
 		__u16 orig_y;	/* cursor's y position */
 	} console_info;
-	__u16 num_pci_vectors;	/* number of ACPI derived PCI IRQ's*/
-	__u64 pci_vectors;	/* physical address of PCI data (pci_vector_struct)*/
 	__u64 fpswa;		/* physical address of the fpswa interface */
 	__u64 initrd_start;
 	__u64 initrd_size;
-} ia64_boot_param;
+} *ia64_boot_param;
=20
 static inline void
 ia64_insn_group_barrier (void)
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/uaccess.h lia64/=
include/asm-ia64/uaccess.h
--- linux-davidm/include/asm-ia64/uaccess.h	Thu Apr  5 12:02:11 2001
+++ lia64/include/asm-ia64/uaccess.h	Thu Apr  5 11:51:48 2001
@@ -33,6 +33,8 @@
 #include <linux/errno.h>
 #include <linux/sched.h>
=20
+#include <asm/pgtable.h>
+
 /*
  * For historical reasons, the following macros are grossly misnamed:
  */
@@ -49,16 +51,13 @@
 #define segment_eq(a,b)	((a).seg =3D (b).seg)
=20
 /*
- * When accessing user memory, we need to make sure the entire area
- * really is in user-level space.  In order to do this efficiently, we
- * make sure that the page at address TASK_SIZE is never valid (we do
- * this by selecting VMALLOC_START as TASK_SIZE+PAGE_SIZE).  This way,
- * we can simply check whether the starting address is < TASK_SIZE
- * and, if so, start accessing the memory.  If the user specified bad
- * length, we will fault on the NaT page and then return the
- * appropriate error.
+ * When accessing user memory, we need to make sure the entire area really=
 is in
+ * user-level space.  In order to do this efficiently, we make sure that t=
he page at
+ * address TASK_SIZE is never valid.  We also need to make sure that the a=
ddress doesn't
+ * point inside the virtually mapped linear page table.
  */
-#define __access_ok(addr,size,segment)	(((unsigned long) (addr)) <=3D (seg=
ment).seg)
+#define __access_ok(addr,size,segment)	(((unsigned long) (addr)) <=3D (seg=
ment).seg		\
+	 && ((segment).seg =3D KERNEL_DS.seg || rgn_offset((unsigned long) (addr)=
) < RGN_MAP_LIMIT))
 #define access_ok(type,addr,size)	__access_ok((addr),(size),get_fs())
=20
 static inline int
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/unwind.h lia64/i=
nclude/asm-ia64/unwind.h
--- linux-davidm/include/asm-ia64/unwind.h	Mon Oct  9 17:55:01 2000
+++ lia64/include/asm-ia64/unwind.h	Thu Apr  5 10:10:04 2001
@@ -109,22 +109,6 @@
 				 struct switch_stack *sw);
=20
 /*
- * Prepare to unwind the current task.  For this to work, the kernel
- * stack identified by REGS must look like this:
- *
- *	//		      //
- *	|		      |
- *	|   kernel stack      |
- *	|		      |
- *	+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+
- *	|   struct pt_regs    |
- *	+---------------------+ <--- REGS
- *	| struct switch_stack |
- *	+---------------------+
- */
-extern void unw_init_from_current (struct unw_frame_info *info, struct pt_=
regs *regs);
-
-/*
  * Prepare to unwind the currently running thread.
  */
 extern void unw_init_running (void (*callback)(struct unw_frame_info *info=
, void *arg), void *arg);
@@ -144,42 +128,42 @@
=20
 #define unw_is_intr_frame(info)	(((info)->flags & UNW_FLAG_INTERRUPT_FRAME=
) !=3D 0)
=20
-static inline unsigned long
+static inline int
 unw_get_ip (struct unw_frame_info *info, unsigned long *valp)
 {
 	*valp =3D (info)->ip;
 	return 0;
 }
=20
-static inline unsigned long
+static inline int
 unw_get_sp (struct unw_frame_info *info, unsigned long *valp)
 {
 	*valp =3D (info)->sp;
 	return 0;
 }
=20
-static inline unsigned long
+static inline int
 unw_get_psp (struct unw_frame_info *info, unsigned long *valp)
 {
 	*valp =3D (info)->psp;
 	return 0;
 }
=20
-static inline unsigned long
+static inline int
 unw_get_bsp (struct unw_frame_info *info, unsigned long *valp)
 {
 	*valp =3D (info)->bsp;
 	return 0;
 }
=20
-static inline unsigned long
+static inline int
 unw_get_cfm (struct unw_frame_info *info, unsigned long *valp)
 {
 	*valp =3D *(info)->cfm_loc;
 	return 0;
 }
=20
-static inline unsigned long
+static inline int
 unw_set_cfm (struct unw_frame_info *info, unsigned long val)
 {
 	*(info)->cfm_loc =3D val;

