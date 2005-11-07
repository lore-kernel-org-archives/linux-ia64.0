From: Zou Nan hai <nanhai.zou@intel.com>
Date: Mon, 07 Nov 2005 23:27:49 +0000
Subject: [Patch]IA64 kexec
Message-Id: <1131406068.2524.15.camel@linux-znh>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-XTG6sW8q/6IX5NuHgC+v"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-XTG6sW8q/6IX5NuHgC+v
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Here is my patches of kexec on IA64.

The kernel patch is against 2.6.14
The kexec-tools patch is against kexec-tools-1.101

I have tested it on a Tiger-4 and a ZX1 machine.

Please test and review it.

Thanks.
Zou Nan hai






--=-XTG6sW8q/6IX5NuHgC+v
Content-Description: 
Content-Disposition: attachment; filename=kexec-tools-ia64.patch
Content-Type: text/x-patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -Nraup a/kexec/arch/ia64/kexec-elf-ia64.c b/kexec/arch/ia64/kexec-elf-ia64.c
--- a/kexec/arch/ia64/kexec-elf-ia64.c	2004-12-22 04:01:37.000000000 +0800
+++ b/kexec/arch/ia64/kexec-elf-ia64.c	2005-11-09 03:39:16.000000000 +0800
@@ -6,6 +6,7 @@
  * Copyright (C) 2004 Silicon Graphics, Inc.
  *   Jesse Barnes <jbarnes@sgi.com>
  * Copyright (C) 2004 Khalid Aziz <khalid.aziz@hp.com> Hewlett Packard Co
+ * Copyright (C) 2005 Zou Nan hai <nanhai.zou@intel.com> Intel Corp
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -34,6 +35,7 @@
 #include <fcntl.h>
 #include <unistd.h>
 #include <getopt.h>
+#include <limits.h>
 #include <elf.h>
 #include <boot/elf_boot.h>
 #include <ip_checksum.h>
@@ -74,23 +76,29 @@ void elf_ia64_usage(void)
 {
 	printf(
 		"    --command-line=STRING Set the kernel command line to STRING.\n"
-		"    --append=STRING       Set the kernel command line to STRING.\n");
+		"    --append=STRING       Set the kernel command line to STRING.\n"
+		"    --initrd=STRING       Set the kernel initrd to STRING.\n");
 }
 
 int elf_ia64_load(int argc, char **argv, const char *buf, off_t len,
 	struct kexec_info *info)
 {
 	struct mem_ehdr ehdr;
-	const char *command_line;
-	int command_line_len;
-	unsigned long entry, max_addr;
+	const char *command_line, *ramdisk=0;
+	char *ramdisk_buf;
+	off_t ramdisk_size = 0;
+	unsigned long command_line_len;
+	unsigned long entry, max_addr, gp_value;
+	unsigned command_line_base, ramdisk_base;
 	int result;
 	int opt;
 #define OPT_APPEND	(OPT_ARCH_MAX+0)
+#define OPT_RAMDISK	(OPT_ARCH_MAX+1)
 	static const struct option options[] = {
 		KEXEC_ARCH_OPTIONS
 		{"command-line", 1, 0, OPT_APPEND},
 		{"append",       1, 0, OPT_APPEND},
+		{"initrd",       1, 0, OPT_RAMDISK},
 		{0, 0, 0, 0},
 	};
 
@@ -110,11 +118,14 @@ int elf_ia64_load(int argc, char **argv,
 		case OPT_APPEND:
 			command_line = optarg;
 			break;
+		case OPT_RAMDISK:
+			ramdisk = optarg;
+			break;
 		}
 	}
 	command_line_len = 0;
 	if (command_line) {
-		command_line_len = strlen(command_line) + 1;
+		command_line_len = strlen(command_line) + 16;
 	}
 
 	/* Parse the Elf file */
@@ -129,13 +140,45 @@ int elf_ia64_load(int argc, char **argv,
 
 	/* Load the Elf data */
 	result = elf_exec_load(&ehdr, info);
-	free_elf_info(&ehdr);
 	if (result < 0) {
 		fprintf(stderr, "ELF load failed\n");
 		return result;
 	}
+
+
+	/* Load the setup code */
+	elf_rel_build_load(info, &info->rhdr, purgatory, purgatory_size,
+			0x80000, ULONG_MAX, 1);
+
+	if (command_line_len) {
+		char *cmdline = xmalloc(command_line_len);
+		strcpy(cmdline, command_line);
+		command_line_len = (command_line_len + 15)&(~15);
+		elf_rel_set_symbol(&info->rhdr, "__command_line_len",
+				&command_line_len, sizeof(long));
+		command_line_base = add_buffer(info, cmdline,
+					command_line_len, command_line_len,
+					16, 0, max_addr, 1);
+		elf_rel_set_symbol(&info->rhdr, "__command_line",
+				&command_line_base, sizeof(long));
+	}
 	
-	/* For now we don't have arguments to pass :( */
-	info->entry = (void *)entry;
+	if (ramdisk) {
+		ramdisk_buf = slurp_file(ramdisk, &ramdisk_size);
+		ramdisk_base = add_buffer(info, ramdisk_buf, ramdisk_size,
+				ramdisk_size,
+				getpagesize(), 0, max_addr, 1);
+		elf_rel_set_symbol(&info->rhdr, "__ramdisk_base",
+				&ramdisk_base, sizeof(long));
+		elf_rel_set_symbol(&info->rhdr, "__ramdisk_size",
+				&ramdisk_size, sizeof(long));
+	}
+
+	gp_value = info->rhdr.rel_addr + 0x200000;
+        elf_rel_set_symbol(&info->rhdr, "__gp_value", &gp_value,
+                        sizeof(gp_value));
+
+	elf_rel_set_symbol(&info->rhdr, "__kernel_entry", &entry, sizeof(entry));
+	free_elf_info(&ehdr);
 	return 0;
 }
diff -Nraup a/kexec/arch/ia64/kexec-elf-rel-ia64.c b/kexec/arch/ia64/kexec-elf-rel-ia64.c
--- a/kexec/arch/ia64/kexec-elf-rel-ia64.c	2004-12-21 06:43:23.000000000 +0800
+++ b/kexec/arch/ia64/kexec-elf-rel-ia64.c	2005-11-09 03:39:16.000000000 +0800
@@ -1,8 +1,14 @@
+/*  Most of the code in this file is
+ *  based on arch/ia64/kernel/module.c in Linux kernel
+ */
+
 #include <stdio.h>
 #include <elf.h>
 #include "../../kexec.h"
 #include "../../kexec-elf.h"
 
+#define MAX_LTOFF       ((uint64_t) (1 << 22))
+
 int machine_verify_elf_rel(struct mem_ehdr *ehdr)
 {
 	if (ehdr->ei_data != ELFDATA2LSB) {
@@ -17,12 +23,40 @@ int machine_verify_elf_rel(struct mem_eh
 	return 1;
 }
 
+static void
+ia64_patch (uint64_t insn_addr, uint64_t mask, uint64_t val)
+{
+        uint64_t m0, m1, v0, v1, b0, b1, *b = (uint64_t *) (insn_addr & -16);
+#       define insn_mask ((1UL << 41) - 1)
+        unsigned long shift;
+
+        b0 = b[0]; b1 = b[1];
+        shift = 5 + 41 * (insn_addr % 16); /* 5 bits of template, then 3 x 41-bit instructions */
+        if (shift >= 64) {
+                m1 = mask << (shift - 64);
+                v1 = val << (shift - 64);
+        } else {
+                m0 = mask << shift; m1 = mask >> (64 - shift);
+                v0 = val  << shift; v1 = val >> (64 - shift);
+                b[0] = (b0 & ~m0) | (v0 & m0);
+        }
+        b[1] = (b1 & ~m1) | (v1 & m1);
+}
+
+static inline uint64_t
+bundle (const uint64_t insn)
+{
+        return insn & ~0xfUL;
+}
+
 void machine_apply_elf_rel(struct mem_ehdr *ehdr, unsigned long r_type,
 	void *location, unsigned long address, unsigned long value)
 {
+	uint64_t gp_value = ehdr->rel_addr + 0x200000;
 	switch(r_type) {
 	case R_IA64_NONE:
 		break;
+	case R_IA64_SEGREL64LSB:
 	case R_IA64_DIR64LSB:
 		*((uint64_t *)location) = value;
 		break;
@@ -31,15 +65,67 @@ void machine_apply_elf_rel(struct mem_eh
 		if (value != *((uint32_t *)location))
 			goto overflow;
 		break;
-	case R_IA64_PCREL21B:
+	case R_IA64_IMM64:
+		ia64_patch((uint64_t)location, 0x01fffefe000UL, 
+				/* bit 63 -> 36 */
+				(((value & 0x8000000000000000UL) >> 27) 
+				/* bit 21 -> 21 */
+				  | ((value & 0x0000000000200000UL) <<  0) 
+				/* bit 16 -> 22 */
+				  | ((value & 0x00000000001f0000UL) <<  6) 
+				/* bit 7 -> 27 */
+				  | ((value & 0x000000000000ff80UL) << 20) 
+				/* bit 0 -> 13 */
+				  | ((value & 0x000000000000007fUL) << 13)));
+		ia64_patch((uint64_t)location - 1, 0x1ffffffffffUL, value>>22);
+		break;
+	case R_IA64_IMM22:
+		if (value + (1 << 21) >= (1 << 22))
+                	die("value out of IMM22 range\n");
+		ia64_patch((uint64_t)location, 0x01fffcfe000UL,
+				/* bit 21 -> 36 */
+				(((value & 0x200000UL) << 15)
+				/* bit 16 -> 22 */
+				 | ((value & 0x1f0000UL) <<  6)
+				/* bit  7 -> 27 */
+				 | ((value & 0x00ff80UL) << 20)
+				/* bit  0 -> 13 */
+				 | ((value & 0x00007fUL) << 13) ));
+		break;
+	case R_IA64_PCREL21B: {
+		uint64_t delta = ((int64_t)value - (int64_t)address)/16;
+		if (delta + (1 << 20) >= (1 << 21))
+			die("value out of IMM21B range\n");
+		value = ((int64_t)(value - bundle(address)))/16;
+		ia64_patch((uint64_t)location, 0x11ffffe000UL,
+				(((value & 0x100000UL) << 16) /* bit 20 -> 36 */
+				 | ((value & 0x0fffffUL) << 13) /* bit  0 -> 13 */));
+		}
+		break;
+	case R_IA64_LTOFF22X:
+		if (value - gp_value + MAX_LTOFF/2 >= MAX_LTOFF)
+			die("value out of gp relative range");
+		value -= gp_value;
+		ia64_patch((uint64_t)location, 0x01fffcfe000UL,
+				(((value & 0x200000UL) << 15) /* bit 21 -> 36 */
+				   |((value & 0x1f0000UL) <<  6) /* bit 16 -> 22 */
+				   |((value & 0x00ff80UL) << 20) /* bit  7 -> 27 */
+				   |((value & 0x00007fUL) << 13) /* bit  0 -> 13 */));
+		break;
+	case R_IA64_LDXMOV:
+		if (value - gp_value + MAX_LTOFF/2 >= MAX_LTOFF)
+			die("value out of gp relative range");
+		ia64_patch((uint64_t)location, 0x1fff80fe000UL, 0x10000000000UL);
+	        break;
 	case R_IA64_LTOFF22:
-	case R_IA64_SEGREL64LSB:
+
 	default:
-		die("Unknown rela relocation: %lu\n", r_type);
+		die("Unknown rela relocation: 0x%lx 0x%lx\n",
+				r_type, address);
 		break;
 	}
 	return;
- overflow:
+overflow:
 	die("overflow in relocation type %lu val %Lx\n", 
-		r_type, value);
+			r_type, value);
 }
diff -Nraup a/kexec/arch/ia64/kexec-ia64.c b/kexec/arch/ia64/kexec-ia64.c
--- a/kexec/arch/ia64/kexec-ia64.c	2005-01-11 14:28:36.000000000 +0800
+++ b/kexec/arch/ia64/kexec-ia64.c	2005-11-09 03:41:06.000000000 +0800
@@ -27,6 +27,7 @@
 #include <stdint.h>
 #include <string.h>
 #include <getopt.h>
+#include <sched.h>
 #include <sys/utsname.h>
 #include "../../kexec.h"
 #include "../../kexec-syscall.h"
@@ -56,7 +57,7 @@ int get_memory_ranges(struct memory_rang
 	 */
 	fprintf(stderr, "Warning assuming memory at 0-64MB is present\n");
 	memory_ranges = 0;
-	memory_range[memory_ranges].start = 0x00010000;
+	memory_range[memory_ranges].start = 0x00100000;
 	memory_range[memory_ranges].end   = 0x10000000;
 	memory_range[memory_ranges].type  = RANGE_RAM;
 	memory_ranges++;
@@ -76,9 +77,6 @@ void arch_usage(void)
 {
 }
 
-static struct {
-} arch_options = {
-};
 int arch_process_options(int argc, char **argv)
 {
 	static const struct option options[] = {
@@ -87,8 +85,11 @@ int arch_process_options(int argc, char 
 	};
 	static const char short_options[] = KEXEC_ARCH_OPT_STR;
 	int opt;
-	unsigned long value;
-	char *end;
+	/* execute from BP */
+        cpu_set_t affinity;
+	CPU_ZERO(&affinity);
+	CPU_SET(0, &affinity);
+        sched_setaffinity(0, sizeof(affinity), &affinity);
 
 	opterr = 0; /* Don't complain about unrecognized options here */
 	while((opt = getopt_long(argc, argv, short_options, options, 0)) != -1) {
@@ -115,32 +116,7 @@ int arch_compat_trampoline(struct kexec_
 	}
 	if (strcmp(utsname.machine, "ia64") == 0)
 	{
-		*flags |= KEXEC_ARCH_X86_64;
-	}
-	else {
-		fprintf(stderr, "Unsupported machine type: %s\n",
-			utsname.machine);
-		return -1;
-	}
-	return 0;
-}
-
-int arch_compat_trampoline(struct kexec_info *info, unsigned long *flags)
-{
-	int result;
-	struct utsname utsname;
-	result = uname(&utsname);
-	if (result < 0) {
-		fprintf(stderr, "uname failed: %s\n",
-			strerror(errno));
-		return -1;
-	}
-	if (strcmp(utsname.machine, "ia64") == 0)
-	{
-		/* For compatibility with older patches 
-		 * use KEXEC_ARCH_DEFAULT instead of KEXEC_ARCH_IA64 here.
-		 */
-		*flags |= KEXEC_ARCH_DEFAULT;
+		*flags |= KEXEC_ARCH_IA_64;
 	}
 	else {
 		fprintf(stderr, "Unsupported machine type: %s\n",
diff -Nraup a/kexec/kexec.c b/kexec/kexec.c
--- a/kexec/kexec.c	2005-01-13 21:24:29.000000000 +0800
+++ b/kexec/kexec.c	2005-11-09 03:39:16.000000000 +0800
@@ -187,7 +187,7 @@ unsigned long locate_hole(struct kexec_i
 	}
 
 	/* Compute the free memory ranges */
-	max_mem_ranges = memory_ranges + (info->nr_segments -1);
+	max_mem_ranges = memory_ranges + info->nr_segments;
 	mem_range = malloc(max_mem_ranges *sizeof(struct memory_range));
 	mem_ranges = 0;
 		
diff -Nraup a/purgatory/arch/ia64/entry.S b/purgatory/arch/ia64/entry.S
--- a/purgatory/arch/ia64/entry.S	1970-01-01 08:00:00.000000000 +0800
+++ b/purgatory/arch/ia64/entry.S	2005-11-09 03:39:16.000000000 +0800
@@ -0,0 +1,85 @@
+/*
+ * purgatory:  setup code
+ *
+ * Copyright (C) 2005  Zou Nan hai (nanhai.zou@intel.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation (version 2 of the License).
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+.global __dummy_efi_function
+.align  32
+.proc  __dummy_efi_function
+__dummy_efi_function:
+	mov r8=r0;;
+	br.ret.sptk.many rp;;
+.global __dummy_efi_function_end
+__dummy_efi_function_end:
+.endp 	__dummy_efi_function
+
+.global purgatory_start
+.align  32
+.proc   purgatory_start
+purgatory_start:
+	movl r2=__gp_value;;
+	ld8 gp=[r2];;
+	br.call.sptk.many b0=purgatory
+	;;
+	alloc r2 = ar.pfs, 0, 0, 5, 0
+	;;
+	mov out0=r28
+
+	movl r2=__command_line;;
+	ld8 out1=[r2];;
+	movl r2=__command_line_len;;
+	ld8 out2=[r2];;
+	movl r2=__ramdisk_base;;
+	ld8 out3=[r2];;
+	movl r2=__ramdisk_size;;
+	ld8 out4=[r2];;
+	br.call.sptk.many b0=ia64_env_setup
+	movl r10=__kernel_entry;;
+	ld8 r14=[r10];;
+	mov b6=r14;;
+	mov ar.lc=r0
+	mov ar.ec=r0
+	cover;;
+	invala;;
+	br.call.sptk.many  b0=b6
+.endp   purgatory_start
+
+.align  32
+.global __kernel_entry
+.size	__kernel_entry, 8
+__kernel_entry:
+        data8 0x0
+.global __command_line
+.size	__command_line, 8
+__command_line:
+        data8 0x0
+.global __command_line_len
+.size	__command_line_len, 8
+__command_line_len:
+        data8 0x0
+.global __ramdisk_base
+.size	__ramdisk_base, 8
+__ramdisk_base:
+        data8 0x0
+.global __ramdisk_size
+.size	__ramdisk_size, 8
+__ramdisk_size:
+        data8 0x0
+.global __gp_value
+.size	__gp_value, 8
+__gp_value:
+        data8 0x0
diff -Nraup a/purgatory/arch/ia64/Makefile b/purgatory/arch/ia64/Makefile
--- a/purgatory/arch/ia64/Makefile	2004-12-21 06:44:22.000000000 +0800
+++ b/purgatory/arch/ia64/Makefile	2005-11-09 03:39:35.000000000 +0800
@@ -1,8 +1,8 @@
 #
 # Purgatory ia64
 #
-
-PURGATORY_S_SRCS+=
+PCFLAGS		+= -ffixed-r28
+PURGATORY_S_SRCS+= purgatory/arch/ia64/entry.S
 PURGATORY_C_SRCS+= purgatory/arch/ia64/purgatory-ia64.c
 PURGATORY_C_SRCS+= purgatory/arch/ia64/console-ia64.c
 PURGATORY_C_SRCS+=
diff -Nraup a/purgatory/arch/ia64/purgatory-ia64.c b/purgatory/arch/ia64/purgatory-ia64.c
--- a/purgatory/arch/ia64/purgatory-ia64.c	2004-12-21 06:45:21.000000000 +0800
+++ b/purgatory/arch/ia64/purgatory-ia64.c	2005-11-09 03:39:16.000000000 +0800
@@ -1,7 +1,113 @@
 #include <purgatory.h>
+#include <stdint.h>
+#include <string.h>
 #include "purgatory-ia64.h"
 
+#define PAGE_OFFSET             0xe000000000000000
+
+typedef struct {
+        uint64_t signature;
+        uint32_t revision;
+        uint32_t headersize;
+        uint32_t crc32;
+        uint32_t reserved;
+} efi_table_hdr_t;
+
+typedef struct {
+        efi_table_hdr_t hdr;
+        unsigned long get_time;
+        unsigned long set_time;
+        unsigned long get_wakeup_time;
+        unsigned long set_wakeup_time;
+        unsigned long set_virtual_address_map;
+        unsigned long convert_pointer;
+        unsigned long get_variable;
+        unsigned long get_next_variable;
+        unsigned long set_variable;
+        unsigned long get_next_high_mono_count;
+        unsigned long reset_system;
+} efi_runtime_services_t;
+
+typedef struct {
+        efi_table_hdr_t hdr;
+        unsigned long fw_vendor;        /* physical addr of CHAR16 vendor string
+ */
+        uint32_t fw_revision;
+        unsigned long con_in_handle;
+        unsigned long con_in;
+        unsigned long con_out_handle;
+        unsigned long con_out;
+        unsigned long stderr_handle;
+        unsigned long stderr;
+        unsigned long runtime;
+        unsigned long boottime;
+        unsigned long nr_tables;
+        unsigned long tables;
+} efi_system_table_t;
+
+struct ia64_boot_param {
+        uint64_t command_line;             /* physical address of command line arguments */
+        uint64_t efi_systab;               /* physical address of EFI system table */
+        uint64_t efi_memmap;               /* physical address of EFI memory map */
+        uint64_t efi_memmap_size;          /* size of EFI memory map */
+        uint64_t efi_memdesc_size;         /* size of an EFI memory map descriptor */
+        uint32_t efi_memdesc_version;      /* memory descriptor version */
+        struct {
+                uint16_t num_cols; /* number of columns on console output device */
+                uint16_t num_rows; /* number of rows on console output device */
+                uint16_t orig_x;   /* cursor's x position */
+                uint16_t orig_y;   /* cursor's y position */
+        } console_info;
+        uint64_t fpswa;            /* physical address of the fpswa interface */
+        uint64_t initrd_start;
+        uint64_t initrd_size;
+};
+
 void setup_arch(void)
 {
 	/* Nothing for now */
 }
+inline unsigned long PA(unsigned long addr)
+{
+	return addr - PAGE_OFFSET;
+}
+
+void flush_icache_range(char *start, unsigned long len)
+{
+	unsigned long i;
+	for (i = 0;i < len; i += 32)
+	  asm volatile("fc.i %0"::"r"(start+i):"memory");
+	asm volatile (";;sync.i;;":::"memory");
+	asm volatile ("srlz.i":::"memory");
+}
+
+extern char __dummy_efi_function[], __dummy_efi_function_end[];
+
+void ia64_env_setup(struct ia64_boot_param *boot_param,
+	uint64_t command_line, uint64_t command_line_len,
+	uint64_t ramdisk_base, uint64_t ramdisk_size)
+{
+	unsigned long len;
+        efi_system_table_t *systab;
+        efi_runtime_services_t *runtime;
+	unsigned long *set_virtual_address_map;
+
+	// patch efi_runtime->set_virtual_address_map to a
+	// dummy function
+	len = __dummy_efi_function_end - __dummy_efi_function;
+	memcpy((char *)command_line + command_line_len, __dummy_efi_function,
+	len);
+	systab = (efi_system_table_t *)boot_param->efi_systab;
+	runtime = (efi_runtime_services_t *)PA(systab->runtime);
+	set_virtual_address_map =
+		(unsigned long *)PA(runtime->set_virtual_address_map);
+	*(set_virtual_address_map)=
+		(unsigned long)((char *)command_line + command_line_len);
+	flush_icache_range((char *)command_line+command_line_len, len);
+
+	boot_param->command_line = command_line;
+	boot_param->console_info.orig_x = 0;
+	boot_param->console_info.orig_y = 0;
+	boot_param->initrd_start = ramdisk_base;
+	boot_param->initrd_size =  ramdisk_size;
+}

--=-XTG6sW8q/6IX5NuHgC+v
Content-Disposition: attachment; filename=kexec-ia64.patch
Content-Type: text/x-patch; name=kexec-ia64.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -Nraup a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	2005-11-08 06:06:05.000000000 +0800
+++ b/arch/ia64/Kconfig	2005-11-08 06:08:14.000000000 +0800
@@ -334,6 +334,17 @@ config IA64_PALINFO
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
+config KEXEC
+       bool "kexec system call (EXPERIMENTAL)"
+       depends on EXPERIMENTAL && (!SMP || HOTPLUG_CPU)
+       help
+         kexec is a system call that implements the ability to shutdown your
+         current kernel, and to start another kernel.  It is like a reboot
+         but it is indepedent of the system firmware.   And like a reboot
+         you can start any kernel with it, not just Linux.
+
+         The name comes from the similiarity to the exec system call.
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
diff -Nraup a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
--- a/arch/ia64/kernel/crash.c	1970-01-01 08:00:00.000000000 +0800
+++ b/arch/ia64/kernel/crash.c	2005-11-08 06:08:14.000000000 +0800
@@ -0,0 +1,22 @@
+/*
+ *  arch/ia64/kernel/crash.c
+ *
+ *  Copyright (C) 2005 Intel Corp
+ *  Zou Nan hai <nanhai.zou@intel.com>
+ */
+#include <linux/smp.h>
+#include <linux/kexec.h>
+
+note_buf_t crash_notes[NR_CPUS];
+void machine_crash_shutdown(void)
+{
+       /* This function is only called after the system
+        * has paniced or is otherwise in a critical state.
+        * The minimum amount of code to allow a kexec'd kernel
+        * to run successfully needs to happen here.
+        *
+        * In practice this means shooting down the other cpus in
+        * an SMP system.
+        */
+}
+
diff -Nraup a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-11-08 06:06:05.000000000 +0800
+++ b/arch/ia64/kernel/entry.S	2005-11-08 06:08:14.000000000 +0800
@@ -1588,7 +1588,7 @@ sys_call_table:
 	data8 sys_mq_timedreceive		// 1265
 	data8 sys_mq_notify
 	data8 sys_mq_getsetattr
-	data8 sys_ni_syscall			// reserved for kexec_load
+	data8 sys_kexec_load
 	data8 sys_ni_syscall			// reserved for vserver
 	data8 sys_waitid			// 1270
 	data8 sys_add_key
diff -Nraup a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
--- a/arch/ia64/kernel/machine_kexec.c	1970-01-01 08:00:00.000000000 +0800
+++ b/arch/ia64/kernel/machine_kexec.c	2005-11-08 06:08:55.000000000 +0800
@@ -0,0 +1,67 @@
+/*
+ *  arch/ia64/kernel/machine_exec.c
+ *
+ *  Copyright (C) 2005 Intel Corp
+ *  Zou Nan hai <nanhai.zou@intel.com>
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/cpu.h>
+#include <linux/kexec.h>
+#include <asm/meminit.h>
+#include <asm/delay.h>
+
+int
+machine_kexec_prepare(struct kimage * image)
+{
+       return 0;
+}
+
+void
+machine_kexec_cleanup(struct kimage *image)
+{
+}
+
+void
+machine_shutdown(void)
+{
+	printk(KERN_INFO "kexec: machine_shutdown called\n");
+}
+
+const extern unsigned char relocate_new_kernel[];
+const extern unsigned long relocate_new_kernel_size;
+typedef void (*relocate_kernel_t) (unsigned long, kimage_entry_t, void *,
+	unsigned long);
+
+extern void *efi_get_pal_addr(void);
+
+NORET_TYPE void
+machine_kexec(struct kimage *image)
+{
+	relocate_kernel_t relocator;
+	void *pal_addr = efi_get_pal_addr();
+	unsigned long
+	code_addr = (unsigned long)page_address(image->control_code_page);
+
+#ifdef CONFIG_SMP
+	int cpu;
+        for_each_online_cpu(cpu) {
+                if (cpu != smp_processor_id())
+                        cpu_down(cpu);
+        }
+#endif
+	ia64_set_itv(1<<16);
+	local_irq_disable();
+	relocator = (relocate_kernel_t)&code_addr;
+        memcpy((void *)code_addr, relocate_new_kernel,
+			relocate_new_kernel_size);
+	flush_icache_range(code_addr, code_addr + relocate_new_kernel_size);
+
+	(*relocator)(image->start, image->head, ia64_boot_param,
+			GRANULEROUNDDOWN((unsigned long) pal_addr));
+	BUG();
+
+	for(;;);
+
+}
diff -Nraup a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2005-11-08 06:06:05.000000000 +0800
+++ b/arch/ia64/kernel/Makefile	2005-11-08 06:08:14.000000000 +0800
@@ -23,6 +23,7 @@ obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o jprobes.o
+obj-$(CONFIG_KEXEC)             += machine_kexec.o crash.o relocate_kernel.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 
diff -Nraup a/arch/ia64/kernel/relocate_kernel.S b/arch/ia64/kernel/relocate_kernel.S
--- a/arch/ia64/kernel/relocate_kernel.S	1970-01-01 08:00:00.000000000 +0800
+++ b/arch/ia64/kernel/relocate_kernel.S	2005-11-08 06:08:14.000000000 +0800
@@ -0,0 +1,187 @@
+/*
+ *  arch/ia64/kernel/relocate_kernel.S
+ *
+ *  Copyright (C) 2005 Intel Corp
+ *  Zou Nan hai <nanhai.zou@intel.com>
+ */
+#include <asm/asmmacro.h>
+#include <asm/kregs.h>
+#include <asm/pgtable.h>
+#include <asm/mca_asm.h>
+
+/* relocate new kernel
+ * => switch to physical mode
+ * => purge all TC and TR entries
+ * => go through kimage page_list to copy segments
+ * => clear system state
+ * => call to entry in physical mode
+ */
+
+GLOBAL_ENTRY(relocate_new_kernel)
+	.prologue
+	alloc r31=ar.pfs,4,0,0,0
+        .body
+.here:
+{
+	rsm psr.i| psr.ic
+	mov r15=ip
+}
+	;;
+{
+        flushrs                         // must be first insn in group
+        srlz.i
+}
+	;;
+
+	//first switch to physical mode
+	add r3=1f-.here, r15
+	movl r16 = IA64_PSR_AC|IA64_PSR_BN|IA64_PSR_IC
+	mov ar.rsc=0	          	// put RSE in enforced lazy mode
+	;;
+	add r2=__reloc_stack-.here, r15
+	;;
+	add sp=8192-16, r2
+	;;
+	tpa sp=sp
+	tpa r3=r3
+	;;
+	mov r18=ar.rnat
+	mov ar.bspstore=r2
+	;;
+        mov cr.ipsr=r16
+        mov cr.iip=r3
+        mov cr.ifs=r0
+	srlz.i
+	;;
+	mov ar.rnat=r18
+	rfi
+	;;
+1:
+	//physical mode code begin
+	mov b6=in0
+	tpa r28=in2			// tpa must before TLB purge
+
+	// purge all TC entries
+#define O(member)       IA64_CPUINFO_##member##_OFFSET
+        GET_THIS_PADDR(r2, cpu_info)    // load phys addr of cpu_info into r2
+        ;;
+        addl r17=O(PTCE_STRIDE),r2
+        addl r2=O(PTCE_BASE),r2
+        ;;
+        ld8 r18=[r2],(O(PTCE_COUNT)-O(PTCE_BASE));;    	// r18=ptce_base
+        ld4 r19=[r2],4                                  // r19=ptce_count[0]
+        ld4 r21=[r17],4                                 // r21=ptce_stride[0]
+        ;;
+        ld4 r20=[r2]                                    // r20=ptce_count[1]
+        ld4 r22=[r17]                                   // r22=ptce_stride[1]
+        mov r24=r0
+        ;;
+        adds r20=-1,r20
+        ;;
+#undef O
+2:
+        cmp.ltu p6,p7=r24,r19
+(p7)    br.cond.dpnt.few 4f
+        mov ar.lc=r20
+3:
+        ptc.e r18
+        ;;
+        add r18=r22,r18
+        br.cloop.sptk.few 3b
+        ;;
+        add r18=r21,r18
+        add r24=1,r24
+        ;;
+        br.sptk.few 2b
+4:
+        srlz.i
+        ;;
+	//purge TR entry for kernel text and data
+        movl r16=KERNEL_START
+        mov r18=KERNEL_TR_PAGE_SHIFT<<2
+        ;;
+        ptr.i r16, r18
+        ptr.d r16, r18
+        ;;
+        srlz.i
+        ;;
+
+	// purge TR entry for percpu data
+        movl r16=PERCPU_ADDR
+        mov r18=PERCPU_PAGE_SHIFT<<2
+        ;;
+        ptr.d r16,r18
+        ;;
+        srlz.d
+
+        // purge TR entry for stack
+        mov r16=IA64_KR(CURRENT_STACK)
+        ;;
+        shl r16=r16,IA64_GRANULE_SHIFT
+        movl r19=PAGE_OFFSET
+        ;;
+        add r16=r19,r16
+        mov r18=IA64_GRANULE_SHIFT<<2
+        ;;
+        ptr.d r16,r18
+        ;;
+        srlz.i
+	;;
+
+        // purge TR entry for pal code
+        mov r16=in3
+        mov r18=IA64_GRANULE_SHIFT<<2
+        ;;
+        ptr.i r16,r18
+        ;;
+        srlz.i
+	;;
+
+	// copy segments
+	movl r16=PAGE_MASK
+	mov  r30=in1			// in1 is page_list
+	br.sptk.few .dest_page
+	;;
+.loop:
+	ld8  r30=[in1], 8;;
+.dest_page:
+	tbit.z p0, p6=r30, 0;;    	// 0x1 dest page
+(p6)	and r17=r30, r16
+(p6)	br.cond.sptk.few .loop;;
+
+	tbit.z p0, p6=r30, 1;;		// 0x2 indirect page
+(p6)	and in1=r30, r16
+(p6)	br.cond.sptk.few .loop;;
+
+	tbit.z p0, p6=r30, 2;;		// 0x4 end flag
+(p6)	br.cond.sptk.few .end_loop;;
+
+	tbit.z p6, p0=r30, 3;;		// 0x8 source page
+(p6)	br.cond.sptk.few .loop
+
+	and r18=r30, r16
+
+	// simple copy page, may optimize later
+	movl r14=PAGE_SIZE/8 - 1;;
+	mov ar.lc=r14;;
+1:
+	ld8 r14=[r18], 8;;
+	st8 [r17]=r14, 8;;
+	fc.i r17
+	br.ctop.sptk.few 1b
+	br.sptk.few .loop
+	;;
+
+.end_loop:
+	sync.i			// for fc.i
+	;;
+	srlz.i
+	;;
+	br.call.sptk.many b0=b6;;
+__reloc_stack:
+.skip 8192
+relocate_new_kernel_end:
+END(relocate_new_kernel)
+	.global relocate_new_kernel_size
+relocate_new_kernel_size:
+	data8	relocate_new_kernel_end - relocate_new_kernel
diff -Nraup a/include/asm-ia64/kexec.h b/include/asm-ia64/kexec.h
--- a/include/asm-ia64/kexec.h	1970-01-01 08:00:00.000000000 +0800
+++ b/include/asm-ia64/kexec.h	2005-11-08 06:08:14.000000000 +0800
@@ -0,0 +1,29 @@
+#ifndef _IA64_KEXEC_H
+#define _IA64_KEXEC_H
+
+/*
+ * KEXEC_SOURCE_MEMORY_LIMIT maximum page get_free_page can return.
+ * I.e. Maximum page that is mapped directly into kernel memory,
+ * and kmap is not required.
+ *
+ * Someone correct me if FIXADDR_START - PAGEOFFSET is not the correct
+ * calculation for the amount of memory directly mappable into the
+ * kernel memory space.
+ */
+
+/* Maximum physical address we can use pages from */
+#define KEXEC_SOURCE_MEMORY_LIMIT (-1UL)
+/* Maximum address we can reach in physical address mode */
+#define KEXEC_DESTINATION_MEMORY_LIMIT (-1UL)
+/* Maximum address we can use for the control code buffer */
+#define KEXEC_CONTROL_MEMORY_LIMIT TASK_SIZE
+
+#define KEXEC_CONTROL_CODE_SIZE        (1UL << 14)
+
+/* The native architecture */
+#define KEXEC_ARCH KEXEC_ARCH_IA_64
+
+#define MAX_NOTE_BYTES 1024
+typedef u32 note_buf_t[MAX_NOTE_BYTES/4];
+extern note_buf_t crash_notes[];
+#endif

--=-XTG6sW8q/6IX5NuHgC+v--

