From: Khalid Aziz <khalid_aziz@hp.com>
Date: Tue, 25 Oct 2005 22:46:11 +0000
Subject: [PATCH] kexec-tools patch for ia64
Message-Id: <1130280371.15053.3.camel@lyra.fc.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-/tMhXV7rDsTHXQtYwDPg"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-/tMhXV7rDsTHXQtYwDPg
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I have ported my patch for kexec-tools to kexec-tools 1.101. kexec tools
work on ia64 with his patch with a kernel patched with kexec patch for
ia64 that will follow this mail.

Please apply.

-- 
Khalid

====================================================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

--=-/tMhXV7rDsTHXQtYwDPg
Content-Disposition: attachment; filename=kexec-tools-1.101-ia64.patch
Content-Type: text/x-patch; name=kexec-tools-1.101-ia64.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -urNp kexec-tools-1.101/kexec-tools-1.101/kexec/arch/ia64/kexec-elf-ia64.c kexec-tools-kh/kexec/arch/ia64/kexec-elf-ia64.c
--- kexec-tools-1.101/kexec-tools-1.101/kexec/arch/ia64/kexec-elf-ia64.c	2004-12-21 13:01:37.000000000 -0700
+++ kexec-tools-kh/kexec/arch/ia64/kexec-elf-ia64.c	2005-10-25 14:34:01.000000000 -0600
@@ -43,6 +43,8 @@
 
 static const int probe_debug = 0;
 
+#define ROUNDUP(x,a)    (((x) + (a) - 1) & ~((a) - 1))
+
 /*
  * elf_ia64_probe - sanity check the elf image
  *
@@ -74,7 +76,8 @@ void elf_ia64_usage(void)
 {
 	printf(
 		"    --command-line=STRING Set the kernel command line to STRING.\n"
-		"    --append=STRING       Set the kernel command line to STRING.\n");
+		"    --append=STRING       Set the kernel command line to STRING.\n"
+		"    --initrd=FILE         Use FILE as the kernel's initial ramdisk.\n");
 }
 
 int elf_ia64_load(int argc, char **argv, const char *buf, off_t len,
@@ -83,14 +86,21 @@ int elf_ia64_load(int argc, char **argv,
 	struct mem_ehdr ehdr;
 	const char *command_line;
 	int command_line_len;
-	unsigned long entry, max_addr;
-	int result;
+	const char *ramdisk = NULL;
+	const unsigned char *ramdisk_buf;
+	off_t ramdisk_length;
+	unsigned char *cmdbuf;
+	unsigned long entry, max_addr, kernel_start, kernel_end;
+	unsigned long mstart, pagesize;
+	int i, result;
 	int opt;
 #define OPT_APPEND	(OPT_ARCH_MAX+0)
+#define OPT_RAMDISK	(OPT_MAX+1)
 	static const struct option options[] = {
 		KEXEC_ARCH_OPTIONS
 		{"command-line", 1, 0, OPT_APPEND},
 		{"append",       1, 0, OPT_APPEND},
+		{"initrd", 1, 0, OPT_RAMDISK},
 		{0, 0, 0, 0},
 	};
 
@@ -110,6 +120,9 @@ int elf_ia64_load(int argc, char **argv,
 		case OPT_APPEND:
 			command_line = optarg;
 			break;
+		case OPT_RAMDISK:
+			ramdisk = optarg;
+			break;
 		}
 	}
 	command_line_len = 0;
@@ -117,6 +130,8 @@ int elf_ia64_load(int argc, char **argv,
 		command_line_len = strlen(command_line) + 1;
 	}
 
+	pagesize = getpagesize();
+
 	/* Parse the Elf file */
 	result = build_elf_exec_info(buf, len, &ehdr);
 	if (result < 0) {
@@ -127,15 +142,82 @@ int elf_ia64_load(int argc, char **argv,
 	entry = ehdr.e_entry;
 	max_addr = elf_max_addr(&ehdr);
 
+	/*
+	 * Find the first page after the end of kernel
+	 */
+	kernel_start =  0xffffffffffffffff;
+	kernel_end =  0;
+	for (i=0; i < ehdr.e_phnum; i++) {
+		if (ehdr.e_phdr[i].p_type != PT_LOAD)
+			continue;
+		if (ehdr.e_phdr[i].p_paddr < kernel_start)
+			kernel_start = ehdr.e_phdr[i].p_paddr;
+		if (ehdr.e_phdr[i].p_paddr > kernel_end)
+			kernel_end = ehdr.e_phdr[i].p_paddr + ehdr.e_phdr[i].p_memsz;
+	}
+	kernel_end = (kernel_end + pagesize) & (~(pagesize -1 ));
+
+	/* 
+	 * On ia64 there is no fixed location for ramdisk and kernel
+	 * parameters. Boot loader allocates some memory to hold boot
+	 * parameters and ramdisk. It then places addresses of these locations
+	 * in a boot param structure and places the address of this boot
+	 * param structure in r28. We will do something similar for kexec.
+	 * We let kernel pick identity mapped location for boot param,
+	 * load ramdisk at the end of kernel, build boot param structure 
+	 * on kexec and pass the pointer to this structure to the next 
+	 * kernel in r28. So, we can not know the memory address for
+	 * boot parameter in userspace kexec tool when loading a new kernel.
+	 * We will pass boot parameters in segment[0] and ramdisk in 
+	 * last segment so kernel always knows where to find them. When
+	 * kernel loads the command line arguments, it reuses the space
+	 * that was originally allocated by EFI. We will pretend to place
+	 * this segment just before kernel and set memsz to command 
+	 * line length. Kernel will save the command line arguments in 
+	 * a buffer when we kexec -l and will ignore memsz.
+	 */
+	cmdbuf = NULL;
+	if (command_line_len != 0) {
+		if ((cmdbuf = malloc(command_line_len)) == NULL) {
+			fprintf(stderr, "Failed to allocate space for command line: %s\n", strerror(errno));
+			return -1;
+		}
+		memset(cmdbuf, 0, command_line_len);
+		strncpy(cmdbuf, command_line, command_line_len);
+	}
+	add_segment(info, cmdbuf, command_line_len, kernel_start - pagesize, pagesize);
+
+	/* 
+	 * We will load initrd right after the kernel, starting with the 
+	 * next page.
+	 */
+	ramdisk_buf = NULL;
+	ramdisk_length = pagesize;
+	if (ramdisk) {
+		ramdisk_buf = slurp_file(ramdisk, &ramdisk_length);
+	}
+	add_segment(info, ramdisk_buf, ramdisk_length, kernel_end, ramdisk_length);
+	if (!ramdisk) {
+		info->segment[1].memsz = 0;
+		info->segment[1].bufsz = 0;
+	}
+	
 	/* Load the Elf data */
 	result = elf_exec_load(&ehdr, info);
-	free_elf_info(&ehdr);
 	if (result < 0) {
 		fprintf(stderr, "ELF load failed\n");
+		free_elf_info(&ehdr);
 		return result;
 	}
-	
-	/* For now we don't have arguments to pass :( */
+
+	/* 
+	 * Update initrd load location. We will load initrd right after
+	 * the kernel starting with the next full kernel page. Find the
+	 * starting address for next page.
+	 */
+	mstart = (unsigned long)info->segment[info->nr_segments-1].mem + info->segment[info->nr_segments-1].memsz;
+	info->segment[1].mem = (void *)ROUNDUP(mstart, pagesize);
+
 	info->entry = (void *)entry;
 	return 0;
 }
diff -urNp kexec-tools-1.101/kexec-tools-1.101/kexec/arch/ia64/kexec-ia64.c kexec-tools-kh/kexec/arch/ia64/kexec-ia64.c
--- kexec-tools-1.101/kexec-tools-1.101/kexec/arch/ia64/kexec-ia64.c	2005-01-10 23:28:36.000000000 -0700
+++ kexec-tools-kh/kexec/arch/ia64/kexec-ia64.c	2005-10-24 17:09:06.000000000 -0600
@@ -87,7 +87,6 @@ int arch_process_options(int argc, char 
 	};
 	static const char short_options[] = KEXEC_ARCH_OPT_STR;
 	int opt;
-	unsigned long value;
 	char *end;
 
 	opterr = 0; /* Don't complain about unrecognized options here */
@@ -103,6 +102,7 @@ int arch_process_options(int argc, char 
 	return 0;
 }
 
+#if 1
 int arch_compat_trampoline(struct kexec_info *info, unsigned long *flags)
 {
 	int result;
@@ -115,7 +115,7 @@ int arch_compat_trampoline(struct kexec_
 	}
 	if (strcmp(utsname.machine, "ia64") == 0)
 	{
-		*flags |= KEXEC_ARCH_X86_64;
+		*flags |= KEXEC_ARCH_IA_64;
 	}
 	else {
 		fprintf(stderr, "Unsupported machine type: %s\n",
@@ -125,6 +125,7 @@ int arch_compat_trampoline(struct kexec_
 	return 0;
 }
 
+#else
 int arch_compat_trampoline(struct kexec_info *info, unsigned long *flags)
 {
 	int result;
@@ -149,6 +150,7 @@ int arch_compat_trampoline(struct kexec_
 	}
 	return 0;
 }
+#endif
 
 void arch_update_purgatory(struct kexec_info *info)
 {
diff -urNp kexec-tools-1.101/kexec-tools-1.101/kexec/kexec.c kexec-tools-kh/kexec/kexec.c
--- kexec-tools-1.101/kexec-tools-1.101/kexec/kexec.c	2005-01-13 06:24:29.000000000 -0700
+++ kexec-tools-kh/kexec/kexec.c	2005-10-25 14:34:25.000000000 -0600
@@ -298,7 +298,12 @@ void add_segment(struct kexec_info *info
 	}
 	
 	last = base + memsz -1;
-	if (!valid_memory_range(base, last)) {
+	/* 
+	 * Don't check destination address for validity if this segment 
+	 * will not be loaded in memory by the relocator before booting
+	 * into new kernel.
+	 */
+	if ((memsz != 0) && !valid_memory_range(base, last)) {
 		die("Invalid memory segment %p - %p\n",
 			(void *)base, (void *)last);
 	}
@@ -569,7 +574,13 @@ static int my_load(const char *type, int
 	}
 	/* Verify all of the segments load to a valid location in memory */
 	for (i = 0; i < info.nr_segments; i++) {
-		if (!valid_memory_segment(info.segment +i)) {
+		/* 
+		 * Don't check destination address for validity if this 
+		 * segment will not be loaded in memory by the relocator 
+		 * before booting into new kernel.
+		 */
+		if ((info.segment[i].memsz != 0) && 
+					!valid_memory_segment(info.segment +i)) {
 			fprintf(stderr, "Invalid memory segment %p - %p\n",
 				info.segment[i].mem,
 				((char *)info.segment[i].mem) + 

--=-/tMhXV7rDsTHXQtYwDPg--

