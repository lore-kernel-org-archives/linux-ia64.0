From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 14 Feb 2005 17:47:16 +0000
Subject: Re: qemu on ia64 linux
Message-Id: <16912.58404.524860.478145@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200502121037.j1CAb7es030843@napali.hpl.hp.com>
In-Reply-To: <200502121037.j1CAb7es030843@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, several people privately expressed interested in the qemu patch,
so here is an _extremely_ preliminary version of it.  With the patch
applied, you should be able to type:

	$ make

in the top-level directory and get a working binary in
i386-softmmu/qemu.  I only tried this on Debian/unstable with gcc-3.4,
but I don't expect any problems on other distributions or with
slightly different compilers.

The binary in i386-user/qemu is know NOT to work, so don't bother with
it for now.

The only test I have run so far is to download the linux-test image from
the qemu web site and boot Linux like this:

	$ i386-softmu linux-test/linux.img

On a dual 1.5GHz Madison, this boots to a prompt in about 13 seconds,
which seems reasonable (and quite a bit faster than Bochs, IIRC).

There are at least two things wrong with the patch at the moment:

 (1) It's not yet using a separate linker-script.  I didn't quite
     realize that at the beginning, but it appears that qemu is
     relying on a linker script that ensures that the qemu binary gets
     linked below 4GB even on 64-bit platforms.  Once we use a custom
     linker-script, it ought to be possible to get i386-user/qemu to
     work.

 (2) The patch is too big.  Due to not using a custom linker-script, I
     had to fix some 64-bit issues (use int64_6 in place of int32_t in
     a few places).  Also, with the custom linker-script, it may be
     possible to make the qemu binary compact enough that we don't
     need PLT stubs.

In other words: give it a shot and if things break, let me know.  I do
hope to work a bit more on it tonight and switch things over to a
custom-linker script.

Enjoy,

	--david

Index: Makefile.target
=================================RCS file: /cvsroot/qemu/qemu/Makefile.target,v
retrieving revision 1.56
diff -u -r1.56 Makefile.target
--- Makefile.target	30 Jan 2005 22:43:42 -0000	1.56
+++ Makefile.target	14 Feb 2005 17:34:42 -0000
@@ -185,6 +185,7 @@
 
 ifeq ($(ARCH),ia64)
 OP_CFLAGS=$(CFLAGS)
+LDFLAGS+=-Wl,--defsym -Wl,__gp=_GLOBAL_OFFSET_TABLE_+0x200000
 endif
 
 ifeq ($(ARCH),arm)
@@ -363,6 +364,9 @@
 VL_LIBS=-lutil
 endif
 endif
+ifeq ($(ARCH),ia64)
+VL_LDFLAGS+=-Wl,--defsym -Wl,__gp=_GLOBAL_OFFSET_TABLE_+0x200000
+endif
 
 $(QEMU_SYSTEM): $(VL_OBJS) libqemu.a
 	$(CC) $(VL_LDFLAGS) -o $@ $^ $(LIBS) $(SDL_LIBS) $(VL_LIBS)
Index: cpu-exec.c
=================================RCS file: /cvsroot/qemu/qemu/cpu-exec.c,v
retrieving revision 1.45
diff -u -r1.45 cpu-exec.c
--- cpu-exec.c	31 Jan 2005 20:45:12 -0000	1.45
+++ cpu-exec.c	14 Feb 2005 17:34:42 -0000
@@ -74,7 +74,8 @@
 
 int cpu_exec(CPUState *env1)
 {
-    int saved_T0, saved_T1, saved_T2;
+    uint64_t saved_T0;
+    int saved_T1, saved_T2;
     CPUState *saved_env;
 #ifdef reg_EAX
     int saved_EAX;
@@ -440,7 +441,7 @@
 #endif
                     ) {
                     spin_lock(&tb_lock);
-                    tb_add_jump((TranslationBlock *)(long)(T0 & ~3), T0 & 3, tb);
+                    tb_add_jump((TranslationBlock *)(long)(T0 & ~3UL), T0 & 3, tb);
 #if defined(USE_CODE_COPY)
                     /* propagates the FP use info */
                     ((TranslationBlock *)(T0 & ~3))->cflags |= 
@@ -540,6 +541,15 @@
             );
     }
 }
+#elif defined(__ia64)
+		struct fptr {
+			void *ip;
+			void *gp;
+		} fp;
+
+		fp.ip = tc_ptr;
+		fp.gp = code_gen_buffer + 2 * (1 << 20);
+		(*(void (*)(void)) &fp)();
 #else
                 gen_func();
 #endif
@@ -1033,6 +1043,40 @@
                              &uc->uc_sigmask, puc);
 }
 
+#elif defined(__ia64)
+
+#ifndef __ISR_VALID
+  /* This ought to be in <bits/siginfo.h>... */
+# define __ISR_VALID	1
+# define si_flags	_sifields._sigfault._si_pad0
+#endif
+
+int cpu_signal_handler(int host_signum, struct siginfo *info, void *puc)
+{
+    struct ucontext *uc = puc;
+    unsigned long ip;
+    int is_write = 0;
+
+    ip = uc->uc_mcontext.sc_ip;
+    switch (host_signum) {
+      case SIGILL:
+      case SIGFPE:
+      case SIGSEGV:
+      case SIGBUS:
+      case SIGTRAP:
+	  if (info->si_code && (info->si_flags & __ISR_VALID))
+	      /* ISR.W (write-access) is bit 33:  */
+	      is_write = (info->si_isr >> 33) & 1;
+	  break;
+
+      default:
+	  break;
+    }
+    return handle_cpu_signal(ip, (unsigned long)info->si_addr,
+                             is_write,
+                             &uc->uc_sigmask, puc);
+}
+
 #else
 
 #error host CPU specific signal handler needed
Index: disas.c
=================================RCS file: /cvsroot/qemu/qemu/disas.c,v
retrieving revision 1.19
diff -u -r1.19 disas.c
--- disas.c	31 Jan 2005 23:32:31 -0000	1.19
+++ disas.c	14 Feb 2005 17:34:42 -0000
@@ -143,7 +143,8 @@
 #elif defined(TARGET_PPC)
     print_insn = print_insn_ppc;
 #else
-    fprintf(out, "Asm output not supported on this arch\n");
+    fprintf(out, "0x" TARGET_FMT_lx
+	    ": Asm output not supported on this arch\n", code);
     return;
 #endif
 
@@ -202,7 +203,8 @@
 #elif defined(__arm__) 
     print_insn = print_insn_arm;
 #else
-    fprintf(out, "Asm output not supported on this arch\n");
+    fprintf(out, "0x%lx: Asm output not supported on this arch\n",
+	    (long) code);
     return;
 #endif
     for (pc = (unsigned long)code; pc < (unsigned long)code + size; pc += count) {
@@ -311,7 +313,8 @@
 #elif defined(TARGET_PPC)
     print_insn = print_insn_ppc;
 #else
-    term_printf("Asm output not supported on this arch\n");
+    term_printf("0x" TARGET_FMT_lx
+		": Asm output not supported on this arch\n", pc);
     return;
 #endif
 
Index: dyngen-exec.h
=================================RCS file: /cvsroot/qemu/qemu/dyngen-exec.h,v
retrieving revision 1.20
diff -u -r1.20 dyngen-exec.h
--- dyngen-exec.h	26 Jan 2005 21:30:57 -0000	1.20
+++ dyngen-exec.h	14 Feb 2005 17:34:42 -0000
@@ -24,26 +24,9 @@
    point because host CPU registers are used as global variables. Some
    host headers do not allow that. */
 #include <stddef.h>
+#include <inttypes.h>
 
-typedef unsigned char uint8_t;
-typedef unsigned short uint16_t;
-typedef unsigned int uint32_t;
-/* XXX may be done for all 64 bits targets ? */
-#if defined (__x86_64__)
-typedef unsigned long uint64_t;
-#else
-typedef unsigned long long uint64_t;
-#endif
-
-typedef signed char int8_t;
-typedef signed short int16_t;
-typedef signed int int32_t;
-#if defined (__x86_64__)
-typedef signed long int64_t;
-#else
-typedef signed long long int64_t;
-#endif
-
+#if 0
 #define INT8_MIN		(-128)
 #define INT16_MIN		(-32767-1)
 #define INT32_MIN		(-2147483647-1)
@@ -56,6 +39,7 @@
 #define UINT16_MAX		(65535)
 #define UINT32_MAX		(4294967295U)
 #define UINT64_MAX		((uint64_t)(18446744073709551615))
+#endif
 
 typedef struct FILE FILE;
 extern int fprintf(FILE *, const char *, ...);
@@ -159,10 +143,10 @@
 #define AREG4 "%d5"
 #endif
 #ifdef __ia64__
-#define AREG0 "r27"
-#define AREG1 "r24"
-#define AREG2 "r25"
-#define AREG3 "r26"
+#define AREG0 "r7"
+#define AREG1 "r4"
+#define AREG2 "r5"
+#define AREG3 "r6"
 #endif
 
 /* force GCC to generate only one epilog at the end of the function */
@@ -234,6 +218,8 @@
 #endif
 #ifdef __ia64__
 #define EXIT_TB() asm volatile ("br.ret.sptk.many b0;;")
+#define GOTO_LABEL_PARAM(n) asm volatile ("br.sptk.many " \
+					  ASM_NAME(__op_gen_label) #n)
 #endif
 #ifdef __sparc__
 #define EXIT_TB() asm volatile ("jmpl %i0 + 8, %g0\n" \
Index: dyngen.c
=================================RCS file: /cvsroot/qemu/qemu/dyngen.c,v
retrieving revision 1.37
diff -u -r1.37 dyngen.c
--- dyngen.c	23 Jan 2005 20:42:06 -0000	1.37
+++ dyngen.c	14 Feb 2005 17:34:43 -0000
@@ -1205,6 +1205,48 @@
     }
 }
 
+#ifdef HOST_IA64
+
+#define PLT_ENTRY_SIZE	16	/* 1 bundle containing "brl" */
+
+struct plt_entry {
+    struct plt_entry *next;
+    const char *name;
+    unsigned long addend;
+} *plt_list;
+
+static int
+get_plt_index (const char *name, unsigned long addend)
+{
+    struct plt_entry *plt, *prev= NULL;
+    int index = 0;
+
+    /* see if we already have an entry for this target: */
+    for (plt = plt_list; plt; ++index, prev = plt, plt = plt->next)
+	if (strcmp(plt->name, name) = 0 && plt->addend = addend)
+	    return index;
+
+    /* nope; create a new PLT entry: */
+
+    plt = malloc(sizeof(*plt));
+    if (!plt) {
+	perror("malloc");
+	exit(1);
+    }
+    memset(plt, 0, sizeof(*plt));
+    plt->name = strdup(name);
+    plt->addend = addend;
+
+    /* append to plt-list: */
+    if (prev)
+	prev->next = plt;
+    else
+	plt_list = plt;
+    return index;
+}
+
+#endif
+
 #ifdef HOST_ARM
 
 int arm_emit_ldr_info(const char *name, unsigned long start_offset,
@@ -1394,7 +1436,11 @@
         /* 08 00 84 00 */
         if (get32((uint32_t *)p) != 0x00840008)
             error("br.ret.sptk.many b0;; expected at the end of %s", name);
+# if 0
         copy_size = p - p_start;
+# else
+	copy_size = p_end - p_start;
+# endif
     }
 #elif defined(HOST_SPARC)
     {
@@ -1531,7 +1577,7 @@
             }
             fprintf(outfile, ";\n");
         }
-        fprintf(outfile, "    extern void %s();\n", name);
+        fprintf(outfile, "    extern char %s;\n", name);
 
         for(i = 0, rel = relocs;i < nb_relocs; i++, rel++) {
             host_ulong offset = get_rel_offset(rel);
@@ -1552,9 +1598,24 @@
 			continue;
 		    }
 #endif
-#ifdef __APPLE__
+#if defined(__APPLE__)
 /* set __attribute((unused)) on darwin because we wan't to avoid warning when we don't use the symbol */
                     fprintf(outfile, "extern char %s __attribute__((unused));\n", sym_name);
+#elif defined(HOST_IA64)
+		    {
+			int is_branch = 0;
+
+			if (ELF64_R_TYPE(rel->r_info) = R_IA64_PCREL21B)
+			      is_branch = 1;
+			/*
+			 * PCREL21 br.call targets generally are out
+			 * of range and need to go through an "import
+			 * stub".
+			 */
+			if (!is_branch)
+			    fprintf(outfile, "    extern char %s;\n",
+				    sym_name);
+		    }
 #else
                     fprintf(outfile, "extern char %s;\n", sym_name);
 #endif
@@ -1961,25 +2022,78 @@
             }
 #elif defined(HOST_IA64)
             {
+		unsigned long sym_idx;
+		long code_offset;
                 char name[256];
                 int type;
-                int addend;
+                long addend;
+
                 for(i = 0, rel = relocs;i < nb_relocs; i++, rel++) {
-                    if (rel->r_offset >= start_offset && rel->r_offset < start_offset + copy_size) {
-                        sym_name = strtab + symtab[ELF64_R_SYM(rel->r_info)].st_name;
-                        get_reloc_expr(name, sizeof(name), sym_name);
-                        type = ELF64_R_TYPE(rel->r_info);
-                        addend = rel->r_addend;
-                        switch(type) {
-			case R_IA64_LTOFF22:
-			    error("must implemnt R_IA64_LTOFF22 relocation");
-			case R_IA64_PCREL21B:
-			    error("must implemnt R_IA64_PCREL21B relocation");
-                        default:
-                            error("unsupported ia64 relocation (%d)", type);
-                        }
-                    }
+		    sym_idx = ELF64_R_SYM(rel->r_info);
+                    if (rel->r_offset < start_offset
+			|| rel->r_offset >= start_offset + copy_size)
+			continue;
+		    sym_name = (strtab + symtab[sym_idx].st_name);
+		    if (strstart(sym_name, "__op_jmp", &p)) {
+			int n;
+			n = strtol(p, NULL, 10);
+			/* __op_jmp relocations are done at
+			   runtime to do translated block
+			   chaining: the offset of the instruction
+			   needs to be stored */
+			fprintf(outfile, "    jmp_offsets[%d] ="
+				"%ld + (gen_code_ptr - gen_code_buf);\n",
+				n, rel->r_offset - start_offset);
+			continue;
+		    }
+		    get_reloc_expr(name, sizeof(name), sym_name);
+		    type = ELF64_R_TYPE(rel->r_info);
+		    addend = rel->r_addend;
+		    code_offset = rel->r_offset - start_offset;
+		    switch(type) {
+		      case R_IA64_IMM64:
+			  fprintf(outfile,
+				  "    ia64_imm64(gen_code_ptr + %ld, "
+				  "%s + %ld);\n",
+				  code_offset, name, addend);
+			  break;
+		      case R_IA64_LTOFF22X:
+		      case R_IA64_LTOFF22:
+			  fprintf(outfile, "    IA64_LTOFF(gen_code_ptr + %ld,"
+				  " %s + %ld, %d);\n",
+				  code_offset, name, addend,
+				  (type = R_IA64_LTOFF22X));
+			  break;
+		      case R_IA64_LDXMOV:
+			  fprintf(outfile,
+				  "    ia64_ldxmov(gen_code_ptr + %ld,"
+				  " %s + %ld);\n", code_offset, name, addend);
+			  break;
+
+		      case R_IA64_PCREL21B:
+			  if (strstart(sym_name, "__op_gen_label", NULL)) {
+			      fprintf(outfile,
+				      "    ia64_imm21b(gen_code_ptr + %ld,"
+				      " (long) (%s + %ld -\n\t\t"
+				      "((long) gen_code_ptr + %ld)) >> 4);\n",
+				      code_offset, name, addend,
+				      code_offset & ~0xfUL);
+			  } else {
+			      fprintf(outfile,
+				      "    IA64_PLT(gen_code_ptr + %ld, "
+				      "%d);\t/* %s + %ld */\n",
+				      code_offset,
+				      get_plt_index(sym_name, addend),
+				      sym_name, addend);
+			  }
+			  break;
+		      default:
+			  error("unsupported ia64 relocation (0x%x)",
+				type);
+		    }
                 }
+		fprintf(outfile, "    ia64_nop_b(gen_code_ptr + %d);\n",
+			copy_size - 16 + 2);
             }
 #elif defined(HOST_SPARC)
             {
@@ -2221,11 +2335,11 @@
 fprintf(outfile,
 "int dyngen_code(uint8_t *gen_code_buf,\n"
 "                uint16_t *label_offsets, uint16_t *jmp_offsets,\n"
-"                const uint16_t *opc_buf, const uint32_t *opparam_buf, const long *gen_labels)\n"
+"                const uint16_t *opc_buf, const uint64_t *opparam_buf, const long *gen_labels)\n"
 "{\n"
 "    uint8_t *gen_code_ptr;\n"
 "    const uint16_t *opc_ptr;\n"
-"    const uint32_t *opparam_ptr;\n");
+"    const uint64_t *opparam_ptr;\n");
 
 #ifdef HOST_ARM
 fprintf(outfile,
@@ -2233,6 +2347,63 @@
 "    LDREntry *arm_ldr_ptr = arm_ldr_table;\n"
 "    uint32_t *arm_data_ptr = arm_data_table;\n");
 #endif
+#ifdef HOST_IA64
+    {
+	long addend, not_first = 0;
+	unsigned long sym_idx;
+	int index, max_index;
+	const char *sym_name;
+	EXE_RELOC *rel;
+
+	max_index = -1;
+	for (i = 0, rel = relocs;i < nb_relocs; i++, rel++) {
+	    sym_idx = ELF64_R_SYM(rel->r_info);
+	    sym_name = (strtab + symtab[sym_idx].st_name);
+	    if (strstart(sym_name, "__op_gen_label", NULL))
+		continue;
+	    if (ELF64_R_TYPE(rel->r_info) != R_IA64_PCREL21B)
+		continue;
+
+	    addend = rel->r_addend;
+	    index = get_plt_index(sym_name, addend);
+	    if (index <= max_index)
+		continue;
+	    max_index = index;
+	    fprintf(outfile, "    extern void %s(void);\n", sym_name);
+	}
+
+	fprintf(outfile,
+		"    struct ia64_fixup *plt_fixes = NULL, "
+		"*ltoff_fixes = NULL;\n"
+		"    static long plt_target[] = {\n\t");
+
+	max_index = -1;
+	for (i = 0, rel = relocs;i < nb_relocs; i++, rel++) {
+	    sym_idx = ELF64_R_SYM(rel->r_info);
+	    sym_name = (strtab + symtab[sym_idx].st_name);
+	    if (strstart(sym_name, "__op_gen_label", NULL))
+		continue;
+	    if (ELF64_R_TYPE(rel->r_info) != R_IA64_PCREL21B)
+		continue;
+
+	    addend = rel->r_addend;
+	    index = get_plt_index(sym_name, addend);
+	    if (index <= max_index)
+		continue;
+	    max_index = index;
+
+	    if (not_first)
+		fprintf(outfile, ",\n\t");
+	    not_first = 1;
+	    if (addend)
+		fprintf(outfile, "(long) &%s + %ld", sym_name, addend);
+	    else
+		fprintf(outfile, "(long) &%s", sym_name);
+	}
+	fprintf(outfile, "\n    };\n"
+	    "    unsigned int plt_offset[%u] = { 0 };\n", max_index + 1);
+    }
+#endif
 
 fprintf(outfile,
 "\n"
@@ -2290,11 +2461,17 @@
 "        }\n");         
 #endif
 
-
 fprintf(outfile,
 "    }\n"
 " the_end:\n"
 );
+#ifdef HOST_IA64
+    fprintf(outfile,
+	    "    ia64_apply_fixes(&gen_code_ptr, ltoff_fixes, "
+	    "(uint64_t) code_gen_buffer + 2*(1<<20), plt_fixes,\n\t\t\t"
+	    "sizeof(plt_target)/sizeof(plt_target[0]),\n\t\t\t"
+	    "plt_target, plt_offset);\n");
+#endif
 
 /* generate some code patching */ 
 #ifdef HOST_ARM
Index: dyngen.h
=================================RCS file: /cvsroot/qemu/qemu/dyngen.h,v
retrieving revision 1.7
diff -u -r1.7 dyngen.h
--- dyngen.h	3 Jan 2005 23:40:55 -0000	1.7
+++ dyngen.h	14 Feb 2005 17:34:43 -0000
@@ -43,6 +43,11 @@
 #ifdef __ia64__
 static inline void flush_icache_range(unsigned long start, unsigned long stop)
 {
+    while (start < stop) {
+	asm volatile ("fc %0" :: "r"(start));
+	start += 32;
+    }
+    asm volatile (";;sync.i;;srlz.i;;");
 }
 #endif
 
@@ -204,3 +209,218 @@
 }
 
 #endif /* __arm__ */
+
+#ifdef __ia64
+
+
+/* Patch instruction with "val" where "mask" has 1 bits. */
+static inline void ia64_patch (uint64_t insn_addr, uint64_t mask, uint64_t val)
+{
+    uint64_t m0, m1, v0, v1, b0, b1, *b = (uint64_t *) (insn_addr & -16);
+#   define insn_mask ((1UL << 41) - 1)
+    unsigned long shift;
+
+    b0 = b[0]; b1 = b[1];
+    shift = 5 + 41 * (insn_addr % 16); /* 5 template, 3 x 41-bit insns */
+    if (shift >= 64) {
+	m1 = mask << (shift - 64);
+	v1 = val << (shift - 64);
+    } else {
+	m0 = mask << shift; m1 = mask >> (64 - shift);
+	v0 = val  << shift; v1 = val >> (64 - shift);
+	b[0] = (b0 & ~m0) | (v0 & m0);
+    }
+    b[1] = (b1 & ~m1) | (v1 & m1);
+}
+
+static inline void ia64_patch_imm60 (uint64_t insn_addr, uint64_t val)
+{
+	ia64_patch(insn_addr,
+		   0x011ffffe000UL,
+		   (  ((val & 0x0800000000000000UL) >> 23) /* bit 59 -> 36 */
+		    | ((val & 0x00000000000fffffUL) << 13) /* bit 0 -> 13 */));
+	ia64_patch(insn_addr - 1, 0x1fffffffffcUL, val >> 18);
+}
+
+static inline void ia64_imm64 (void *insn, uint64_t val)
+{
+    /* Ignore the slot number of the relocation; GCC and Intel
+       toolchains differed for some time on whether IMM64 relocs are
+       against slot 1 (Intel) or slot 2 (GCC).  */
+    uint64_t insn_addr = (uint64_t) insn & ~3UL;
+
+    ia64_patch(insn_addr + 2,
+	       0x01fffefe000UL,
+	       (  ((val & 0x8000000000000000UL) >> 27) /* bit 63 -> 36 */
+		| ((val & 0x0000000000200000UL) <<  0) /* bit 21 -> 21 */
+		| ((val & 0x00000000001f0000UL) <<  6) /* bit 16 -> 22 */
+		| ((val & 0x000000000000ff80UL) << 20) /* bit  7 -> 27 */
+		| ((val & 0x000000000000007fUL) << 13) /* bit  0 -> 13 */)
+	    );
+    ia64_patch(insn_addr + 1, 0x1ffffffffffUL, val >> 22);
+}
+
+static inline void ia64_imm60b (void *insn, uint64_t val)
+{
+    /* Ignore the slot number of the relocation; GCC and Intel
+       toolchains differed for some time on whether IMM64 relocs are
+       against slot 1 (Intel) or slot 2 (GCC).  */
+    uint64_t insn_addr = (uint64_t) insn & ~3UL;
+
+    if (val + ((uint64_t) 1 << 59) >= (1UL << 60))
+	fprintf(stderr, "%s: value %ld out of IMM60 range\n",
+		__FUNCTION__, (int64_t) val);
+    ia64_patch_imm60(insn_addr + 2, val);
+}
+
+static inline void ia64_imm22 (void *insn, uint64_t val)
+{
+    if (val + (1 << 21) >= (1 << 22))
+	fprintf(stderr, "%s: value %li out of IMM22 range\n",
+		__FUNCTION__, (int64_t)val);
+    ia64_patch((uint64_t) insn, 0x01fffcfe000UL,
+	       (  ((val & 0x200000UL) << 15) /* bit 21 -> 36 */
+		| ((val & 0x1f0000UL) <<  6) /* bit 16 -> 22 */
+		| ((val & 0x00ff80UL) << 20) /* bit  7 -> 27 */
+		| ((val & 0x00007fUL) << 13) /* bit  0 -> 13 */));
+}
+
+/* Like ia64_imm22(), but also clear bits 20-21.  For addl, this has
+   the effect of turning "addl rX=imm22,rY" into "addl
+   rX=imm22,r0".  */
+static inline void ia64_imm22_r0 (void *insn, uint64_t val)
+{
+    if (val + (1 << 21) >= (1 << 22))
+	fprintf(stderr, "%s: value %li out of IMM22 range\n",
+		__FUNCTION__, (int64_t)val);
+    ia64_patch((uint64_t) insn, 0x01fffcfe000UL | (0x3UL << 20),
+	       (  ((val & 0x200000UL) << 15) /* bit 21 -> 36 */
+		| ((val & 0x1f0000UL) <<  6) /* bit 16 -> 22 */
+		| ((val & 0x00ff80UL) << 20) /* bit  7 -> 27 */
+		| ((val & 0x00007fUL) << 13) /* bit  0 -> 13 */));
+}
+
+static inline void ia64_imm21b (void *insn, uint64_t val)
+{
+    if (val + (1 << 20) >= (1 << 21))
+	fprintf(stderr, "%s: value %li out of IMM21b range\n",
+		__FUNCTION__, (int64_t)val);
+    ia64_patch((uint64_t) insn, 0x11ffffe000UL,
+	       (  ((val & 0x100000UL) << 16) /* bit 20 -> 36 */
+		| ((val & 0x0fffffUL) << 13) /* bit  0 -> 13 */));
+}
+
+static inline void ia64_nop_b (void *insn)
+{
+    ia64_patch((uint64_t) insn, (1UL << 41) - 1, 2UL << 37);
+}
+
+static inline void ia64_ldxmov(void *insn, uint64_t val)
+{
+    if (val + (1 << 21) < (1 << 22))
+	ia64_patch((uint64_t) insn, 0x1fff80fe000UL, 8UL << 37);
+}
+
+static inline int ia64_patch_ltoff(void *insn, uint64_t val,
+				   int relaxable)
+{
+    if (relaxable && (val + (1 << 21) < (1 << 22))) {
+	ia64_imm22_r0(insn, val);
+	return 0;
+    }
+    return 1;
+}
+
+struct ia64_fixup {
+    struct ia64_fixup *next;
+    void *addr;			/* address that needs to be patched */
+    long value;
+};
+
+#define IA64_PLT(insn, plt_index)			\
+do {							\
+    struct ia64_fixup *fixup = alloca(sizeof(*fixup));	\
+    fixup->next = plt_fixes;				\
+    plt_fixes = fixup;					\
+    fixup->addr = (insn);				\
+    fixup->value = (plt_index);				\
+    plt_offset[(plt_index)] = 1;			\
+} while (0)
+
+#define IA64_LTOFF(insn, val, relaxable)			\
+do {								\
+    if (ia64_patch_ltoff(insn, val, relaxable)) {		\
+	struct ia64_fixup *fixup = alloca(sizeof(*fixup));	\
+	fixup->next = ltoff_fixes;				\
+	ltoff_fixes = fixup;					\
+	fixup->addr = (insn);					\
+	fixup->value = (val);					\
+    }								\
+} while (0)
+
+static inline void ia64_apply_fixes (uint8_t **gen_code_pp,
+				     struct ia64_fixup *ltoff_fixes,
+				     uint64_t gp,
+				     struct ia64_fixup *plt_fixes,
+				     int num_plts,
+				     unsigned long *plt_target,
+				     unsigned int *plt_offset)
+{
+    static const uint8_t plt_bundle[] = {
+	0x04, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,	/* nop 0; movl r1=GP */
+	0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x60,
+
+	0x05, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,	/* nop 0; brl IP */
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0
+    };
+    uint8_t *gen_code_ptr = *gen_code_pp, *plt_start, *got_start, *vp;
+    struct ia64_fixup *fixup;
+    unsigned int offset = 0;
+    struct fdesc {
+	long ip;
+	long gp;
+    } *fdesc;
+    int i;
+
+    if (plt_fixes) {
+	plt_start = gen_code_ptr;
+
+	for (i = 0; i < num_plts; ++i) {
+	    if (plt_offset[i]) {
+		plt_offset[i] = offset;
+		offset += sizeof(plt_bundle);
+
+		fdesc = (struct fdesc *) plt_target[i];
+		memcpy(gen_code_ptr, plt_bundle, sizeof(plt_bundle));
+		ia64_imm64 (gen_code_ptr + 0x02, fdesc->gp);
+		ia64_imm60b(gen_code_ptr + 0x12,
+			    (fdesc->ip - (long) (gen_code_ptr + 0x10)) >> 4);
+		gen_code_ptr += sizeof(plt_bundle);
+	    }
+	}
+
+	for (fixup = plt_fixes; fixup; fixup = fixup->next)
+	    ia64_imm21b(fixup->addr,
+			((long) plt_start + plt_offset[fixup->value]
+			 - ((long) fixup->addr & ~0xf)) >> 4);
+    }
+
+    got_start = gen_code_ptr;
+
+    /* First, create the GOT: */
+    for (fixup = ltoff_fixes; fixup; fixup = fixup->next) {
+	/* first check if we already have this value in the GOT: */
+	for (vp = got_start; vp < gen_code_ptr; ++vp)
+	    if (*(uint64_t *) vp = fixup->value)
+		break;
+	if (vp = gen_code_ptr) {
+	    /* Nope, we need to put the value in the GOT: */
+	    *(uint64_t *) vp = fixup->value;
+	    gen_code_ptr += 8;
+	}
+	ia64_imm22(fixup->addr, (long) vp - gp);
+    }
+    *gen_code_pp = gen_code_ptr;
+}
+
+#endif
Index: exec-all.h
=================================RCS file: /cvsroot/qemu/qemu/exec-all.h,v
retrieving revision 1.26
diff -u -r1.26 exec-all.h
--- exec-all.h	10 Jan 2005 23:23:48 -0000	1.26
+++ exec-all.h	14 Feb 2005 17:34:43 -0000
@@ -54,7 +54,7 @@
 #define OPPARAM_BUF_SIZE (OPC_BUF_SIZE * 3)
 
 extern uint16_t gen_opc_buf[OPC_BUF_SIZE];
-extern uint32_t gen_opparam_buf[OPPARAM_BUF_SIZE];
+extern uint64_t gen_opparam_buf[OPPARAM_BUF_SIZE];
 extern long gen_labels[OPC_BUF_SIZE];
 extern int nb_gen_labels;
 extern target_ulong gen_opc_pc[OPC_BUF_SIZE];
@@ -78,7 +78,7 @@
 
 int gen_intermediate_code(CPUState *env, struct TranslationBlock *tb);
 int gen_intermediate_code_pc(CPUState *env, struct TranslationBlock *tb);
-void dump_ops(const uint16_t *opc_buf, const uint32_t *opparam_buf);
+void dump_ops(const uint16_t *opc_buf, const uint64_t *opparam_buf);
 int cpu_gen_code(CPUState *env, struct TranslationBlock *tb,
                  int max_code_size, int *gen_code_size_ptr);
 int cpu_restore_state(struct TranslationBlock *tb, 
@@ -125,6 +125,8 @@
 
 #if defined(__alpha__)
 #define CODE_GEN_BUFFER_SIZE     (2 * 1024 * 1024)
+#elif defined(__ia64)
+#define CODE_GEN_BUFFER_SIZE     (4 * 1024 * 1024)	/* range of addl */
 #elif defined(__powerpc__)
 #define CODE_GEN_BUFFER_SIZE     (6 * 1024 * 1024)
 #else
@@ -178,7 +180,7 @@
 #ifdef USE_DIRECT_JUMP
     uint16_t tb_jmp_offset[4]; /* offset of jump instruction */
 #else
-    uint32_t tb_next[2]; /* address of jump generated code */
+    uint64_t tb_next[2]; /* address of jump generated code */
 #endif
     /* list of TBs jumping to this one. This is a circular list using
        the two least significant bits of the pointers to tell what is
@@ -488,6 +490,15 @@
 }
 #endif
 
+#ifdef __ia64
+#include <ia64intrin.h>
+
+static inline int testandset (int *p)
+{
+    return __sync_lock_test_and_set (p, 1);
+}
+#endif
+
 typedef int spinlock_t;
 
 #define SPIN_LOCK_UNLOCKED 0
Index: qemu-img.c
=================================RCS file: /cvsroot/qemu/qemu/qemu-img.c,v
retrieving revision 1.5
diff -u -r1.5 qemu-img.c
--- qemu-img.c	9 Oct 2004 16:44:06 -0000	1.5
+++ qemu-img.c	14 Feb 2005 17:34:43 -0000
@@ -165,7 +165,7 @@
     int i;
 
     if (size <= 999) {
-        snprintf(buf, buf_size, "%lld", size);
+        snprintf(buf, buf_size, "%lld", (long long) size);
     } else {
         base = 1024;
         for(i = 0; i < NB_SUFFIXES; i++) {
@@ -176,7 +176,7 @@
                 break;
             } else if (size < (1000 * base) || i = (NB_SUFFIXES - 1)) {
                 snprintf(buf, buf_size, "%lld%c", 
-                         (size + (base >> 1)) / base,
+                         (long long) ((size + (base >> 1)) / base),
                          suffixes[i]);
                 break;
             }
@@ -369,7 +369,7 @@
         printf(", backing_file=%s",
                base_filename);
     }
-    printf(", size=%lld kB\n", size / 1024);
+    printf(", size=%lld kB\n", (long long) (size / 1024));
     ret = bdrv_create(drv, filename, size / 512, base_filename, encrypted);
     if (ret < 0) {
         if (ret = -ENOTSUP) {
@@ -666,7 +666,7 @@
            "virtual size: %s (%lld bytes)\n"
            "disk size: %s\n",
            filename, fmt_name, size_buf, 
-           total_sectors * 512,
+           (long long) (total_sectors * 512),
            dsize_buf);
     if (bdrv_is_encrypted(bs))
         printf("encrypted: yes\n");
Index: translate-all.c
=================================RCS file: /cvsroot/qemu/qemu/translate-all.c,v
retrieving revision 1.10
diff -u -r1.10 translate-all.c
--- translate-all.c	3 Jan 2005 23:40:55 -0000	1.10
+++ translate-all.c	14 Feb 2005 17:34:43 -0000
@@ -30,6 +30,16 @@
 #include "exec-all.h"
 #include "disas.h"
 
+#ifdef __ia64
+/*
+ * Ensure _op_paramN is nowhere near the GP to avoid the linker
+ * optimizing away instructions pointed to by LDMOVX relocs.
+ */
+int __op_param1 __attribute__((__section__ (".rodata")));
+int __op_param2 __attribute__((__section__ (".rodata")));
+int __op_param3 __attribute__((__section__ (".rodata")));
+#endif
+
 enum {
 #define DEF(s, n, copy_size) INDEX_op_ ## s,
 #include "opc.h"
@@ -41,7 +51,7 @@
 #include "op.h"
 
 uint16_t gen_opc_buf[OPC_BUF_SIZE];
-uint32_t gen_opparam_buf[OPPARAM_BUF_SIZE];
+uint64_t gen_opparam_buf[OPPARAM_BUF_SIZE];
 long gen_labels[OPC_BUF_SIZE];
 int nb_gen_labels;
 
@@ -74,10 +84,10 @@
 #undef DEF
 };
 
-void dump_ops(const uint16_t *opc_buf, const uint32_t *opparam_buf)
+void dump_ops(const uint16_t *opc_buf, const uint64_t *opparam_buf)
 {
     const uint16_t *opc_ptr;
-    const uint32_t *opparam_ptr;
+    const uint64_t *opparam_ptr;
     int c, n, i;
 
     opc_ptr = opc_buf;
@@ -88,7 +98,7 @@
         fprintf(logfile, "0x%04x: %s", 
                 (int)(opc_ptr - opc_buf - 1), op_str[c]);
         for(i = 0; i < n; i++) {
-            fprintf(logfile, " 0x%x", opparam_ptr[i]);
+            fprintf(logfile, " 0x%llx", (unsigned long long) opparam_ptr[i]);
         }
         fprintf(logfile, "\n");
         if (c = INDEX_op_end)
Index: vl.c
=================================RCS file: /cvsroot/qemu/qemu/vl.c,v
retrieving revision 1.119
diff -u -r1.119 vl.c
--- vl.c	30 Jan 2005 22:57:54 -0000	1.119
+++ vl.c	14 Feb 2005 17:34:43 -0000
@@ -509,6 +509,15 @@
     return val;
 }
 
+#elif defined(__ia64)
+
+int64_t cpu_get_real_ticks(void)
+{
+	int64_t val;
+	asm volatile ("mov %0 = ar.itc" : "=r"(val) :: "memory");
+	return val;
+}
+
 #else
 #error unsupported CPU
 #endif
Index: linux-user/signal.c
=================================RCS file: /cvsroot/qemu/qemu/linux-user/signal.c,v
retrieving revision 1.27
diff -u -r1.27 signal.c
--- linux-user/signal.c	30 Jan 2005 22:59:18 -0000	1.27
+++ linux-user/signal.c	14 Feb 2005 17:34:44 -0000
@@ -26,13 +26,6 @@
 #include <errno.h>
 #include <sys/ucontext.h>
 
-#ifdef __ia64__
-#undef uc_mcontext
-#undef uc_sigmask
-#undef uc_stack
-#undef uc_link
-#endif 
-
 #include "qemu.h"
 
 //#define DEBUG_SIGNAL
@@ -557,11 +550,11 @@
 } target_stack_t;
 
 struct target_ucontext {
-        target_ulong	  uc_flags;
-	target_ulong      uc_link;
-	target_stack_t	  uc_stack;
-	struct target_sigcontext uc_mcontext;
-	target_sigset_t	  uc_sigmask;	/* mask last for extensibility */
+        target_ulong	  tuc_flags;
+	target_ulong      tuc_link;
+	target_stack_t	  tuc_stack;
+	struct target_sigcontext tuc_mcontext;
+	target_sigset_t	  tuc_sigmask;	/* mask last for extensibility */
 };
 
 struct sigframe
@@ -743,16 +736,18 @@
 		goto give_sigsegv;
 
 	/* Create the ucontext.  */
-	err |= __put_user(0, &frame->uc.uc_flags);
-	err |= __put_user(0, &frame->uc.uc_link);
-	err |= __put_user(/*current->sas_ss_sp*/ 0, &frame->uc.uc_stack.ss_sp);
+	err |= __put_user(0, &frame->uc.tuc_flags);
+	err |= __put_user(0, &frame->uc.tuc_link);
+	err |= __put_user(/*current->sas_ss_sp*/ 0,
+			  &frame->uc.tuc_stack.ss_sp);
 	err |= __put_user(/* sas_ss_flags(regs->esp) */ 0,
-			  &frame->uc.uc_stack.ss_flags);
-	err |= __put_user(/* current->sas_ss_size */ 0, &frame->uc.uc_stack.ss_size);
-	err |= setup_sigcontext(&frame->uc.uc_mcontext, &frame->fpstate,
+			  &frame->uc.tuc_stack.ss_flags);
+	err |= __put_user(/* current->sas_ss_size */ 0,
+			  &frame->uc.tuc_stack.ss_size);
+	err |= setup_sigcontext(&frame->uc.tuc_mcontext, &frame->fpstate,
 			        env, set->sig[0]);
         for(i = 0; i < TARGET_NSIG_WORDS; i++) {
-            if (__put_user(set->sig[i], &frame->uc.uc_sigmask.sig[i]))
+            if (__put_user(set->sig[i], &frame->uc.tuc_sigmask.sig[i]))
                 goto give_sigsegv;
         }
 
@@ -880,14 +875,14 @@
 	if (verify_area(VERIFY_READ, frame, sizeof(*frame)))
 		goto badframe;
 #endif
-        target_to_host_sigset(&set, &frame->uc.uc_sigmask);
+        target_to_host_sigset(&set, &frame->uc.tuc_sigmask);
         sigprocmask(SIG_SETMASK, &set, NULL);
 	
-	if (restore_sigcontext(env, &frame->uc.uc_mcontext, &eax))
+	if (restore_sigcontext(env, &frame->uc.tuc_mcontext, &eax))
 		goto badframe;
 
 #if 0
-	if (__copy_from_user(&st, &frame->uc.uc_stack, sizeof(st)))
+	if (__copy_from_user(&st, &frame->uc.tuc_stack, sizeof(st)))
 		goto badframe;
 	/* It is more difficult to avoid calling this function than to
 	   call it and ignore errors.  */
@@ -933,11 +928,11 @@
 } target_stack_t;
 
 struct target_ucontext {
-    target_ulong uc_flags;
-    target_ulong uc_link;
-    target_stack_t uc_stack;
-    struct target_sigcontext uc_mcontext;
-    target_sigset_t  uc_sigmask;	/* mask last for extensibility */
+    target_ulong tuc_flags;
+    target_ulong tuc_link;
+    target_stack_t tuc_stack;
+    struct target_sigcontext tuc_mcontext;
+    target_sigset_t  tuc_sigmask;	/* mask last for extensibility */
 };
 
 struct sigframe
@@ -1135,10 +1130,10 @@
 	/* Clear all the bits of the ucontext we don't use.  */
 	err |= __clear_user(&frame->uc, offsetof(struct ucontext, uc_mcontext));
 
-	err |= setup_sigcontext(&frame->uc.uc_mcontext, /*&frame->fpstate,*/
+	err |= setup_sigcontext(&frame->uc.tuc_mcontext, /*&frame->fpstate,*/
 				env, set->sig[0]);
         for(i = 0; i < TARGET_NSIG_WORDS; i++) {
-            if (__put_user(set->sig[i], &frame->uc.uc_sigmask.sig[i]))
+            if (__put_user(set->sig[i], &frame->uc.tuc_sigmask.sig[i]))
                 return;
         }
 
@@ -1253,10 +1248,10 @@
 	if (verify_area(VERIFY_READ, frame, sizeof (*frame)))
 		goto badframe;
 #endif
-        target_to_host_sigset(&host_set, &frame->uc.uc_sigmask);
+        target_to_host_sigset(&host_set, &frame->uc.tuc_sigmask);
         sigprocmask(SIG_SETMASK, &host_set, NULL);
 
-	if (restore_sigcontext(env, &frame->uc.uc_mcontext))
+	if (restore_sigcontext(env, &frame->uc.tuc_mcontext))
 		goto badframe;
 
 #if 0
Index: linux-user/syscall.c
=================================RCS file: /cvsroot/qemu/qemu/linux-user/syscall.c,v
retrieving revision 1.57
diff -u -r1.57 syscall.c
--- linux-user/syscall.c	31 Jan 2005 20:45:13 -0000	1.57
+++ linux-user/syscall.c	14 Feb 2005 17:34:44 -0000
@@ -33,6 +33,7 @@
 #include <sys/stat.h>
 #include <sys/mount.h>
 #include <sys/resource.h>
+#include <sys/syscall.h>
 #include <sys/mman.h>
 #include <sys/swap.h>
 #include <signal.h>
@@ -77,159 +78,56 @@
 #define	VFAT_IOCTL_READDIR_BOTH		_IOR('r', 1, struct dirent [2])
 #define	VFAT_IOCTL_READDIR_SHORT	_IOR('r', 2, struct dirent [2])
 
-
-#if defined(__powerpc__)
-#undef __syscall_nr
-#undef __sc_loadargs_0
-#undef __sc_loadargs_1
-#undef __sc_loadargs_2
-#undef __sc_loadargs_3
-#undef __sc_loadargs_4
-#undef __sc_loadargs_5
-#undef __sc_asm_input_0
-#undef __sc_asm_input_1
-#undef __sc_asm_input_2
-#undef __sc_asm_input_3
-#undef __sc_asm_input_4
-#undef __sc_asm_input_5
-#undef _syscall0
-#undef _syscall1
-#undef _syscall2
-#undef _syscall3
-#undef _syscall4
-#undef _syscall5
-
-/* need to redefine syscalls as Linux kernel defines are incorrect for
-   the clobber list */
-/* On powerpc a system call basically clobbers the same registers like a
- * function call, with the exception of LR (which is needed for the
- * "sc; bnslr" sequence) and CR (where only CR0.SO is clobbered to signal
- * an error return status).
- */
-
-#define __syscall_nr(nr, type, name, args...)				\
-	unsigned long __sc_ret, __sc_err;				\
-	{								\
-		register unsigned long __sc_0  __asm__ ("r0");		\
-		register unsigned long __sc_3  __asm__ ("r3");		\
-		register unsigned long __sc_4  __asm__ ("r4");		\
-		register unsigned long __sc_5  __asm__ ("r5");		\
-		register unsigned long __sc_6  __asm__ ("r6");		\
-		register unsigned long __sc_7  __asm__ ("r7");		\
-									\
-		__sc_loadargs_##nr(name, args);				\
-		__asm__ __volatile__					\
-			("sc           \n\t"				\
-			 "mfcr %0      "				\
-			: "=&r" (__sc_0),				\
-			  "=&r" (__sc_3),  "=&r" (__sc_4),		\
-			  "=&r" (__sc_5),  "=&r" (__sc_6),		\
-			  "=&r" (__sc_7)				\
-			: __sc_asm_input_##nr				\
-			: "cr0", "ctr", "memory",			\
-			  "r8", "r9", "r10","r11", "r12");		\
-		__sc_ret = __sc_3;					\
-		__sc_err = __sc_0;					\
-	}								\
-	if (__sc_err & 0x10000000)					\
-	{								\
-		errno = __sc_ret;					\
-		__sc_ret = -1;						\
-	}								\
-	return (type) __sc_ret
-
-#define __sc_loadargs_0(name, dummy...)					\
-	__sc_0 = __NR_##name
-#define __sc_loadargs_1(name, arg1)					\
-	__sc_loadargs_0(name);						\
-	__sc_3 = (unsigned long) (arg1)
-#define __sc_loadargs_2(name, arg1, arg2)				\
-	__sc_loadargs_1(name, arg1);					\
-	__sc_4 = (unsigned long) (arg2)
-#define __sc_loadargs_3(name, arg1, arg2, arg3)				\
-	__sc_loadargs_2(name, arg1, arg2);				\
-	__sc_5 = (unsigned long) (arg3)
-#define __sc_loadargs_4(name, arg1, arg2, arg3, arg4)			\
-	__sc_loadargs_3(name, arg1, arg2, arg3);			\
-	__sc_6 = (unsigned long) (arg4)
-#define __sc_loadargs_5(name, arg1, arg2, arg3, arg4, arg5)		\
-	__sc_loadargs_4(name, arg1, arg2, arg3, arg4);			\
-	__sc_7 = (unsigned long) (arg5)
-
-#define __sc_asm_input_0 "0" (__sc_0)
-#define __sc_asm_input_1 __sc_asm_input_0, "1" (__sc_3)
-#define __sc_asm_input_2 __sc_asm_input_1, "2" (__sc_4)
-#define __sc_asm_input_3 __sc_asm_input_2, "3" (__sc_5)
-#define __sc_asm_input_4 __sc_asm_input_3, "4" (__sc_6)
-#define __sc_asm_input_5 __sc_asm_input_4, "5" (__sc_7)
-
-#define _syscall0(type,name)						\
-type name(void)								\
-{									\
-	__syscall_nr(0, type, name);					\
-}
-
-#define _syscall1(type,name,type1,arg1)					\
-type name(type1 arg1)							\
-{									\
-	__syscall_nr(1, type, name, arg1);				\
-}
-
-#define _syscall2(type,name,type1,arg1,type2,arg2)			\
-type name(type1 arg1, type2 arg2)					\
-{									\
-	__syscall_nr(2, type, name, arg1, arg2);			\
-}
-
-#define _syscall3(type,name,type1,arg1,type2,arg2,type3,arg3)		\
-type name(type1 arg1, type2 arg2, type3 arg3)				\
-{									\
-	__syscall_nr(3, type, name, arg1, arg2, arg3);			\
-}
-
-#define _syscall4(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4) \
-type name(type1 arg1, type2 arg2, type3 arg3, type4 arg4)		\
-{									\
-	__syscall_nr(4, type, name, arg1, arg2, arg3, arg4);		\
-}
-
-#define _syscall5(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4,type5,arg5) \
-type name(type1 arg1, type2 arg2, type3 arg3, type4 arg4, type5 arg5)	\
-{									\
-	__syscall_nr(5, type, name, arg1, arg2, arg3, arg4, arg5);	\
-}
-#endif
-
-#define __NR_sys_uname __NR_uname
-#define __NR_sys_getcwd1 __NR_getcwd
-#define __NR_sys_statfs __NR_statfs
-#define __NR_sys_fstatfs __NR_fstatfs
-#define __NR_sys_getdents __NR_getdents
-#define __NR_sys_getdents64 __NR_getdents64
-#define __NR_sys_rt_sigqueueinfo __NR_rt_sigqueueinfo
-
-#if defined(__alpha__) || defined (__ia64__) || defined(__x86_64__)
-#define __NR__llseek __NR_lseek
-#endif
-
 #ifdef __NR_gettid
-_syscall0(int, gettid)
+static int gettid (void)
+{
+  return syscall(__NR_gettid);
+}
 #else
 static int gettid(void) {
     return -ENOSYS;
 }
 #endif
-_syscall1(int,sys_uname,struct new_utsname *,buf)
-_syscall2(int,sys_getcwd1,char *,buf,size_t,size)
-_syscall3(int, sys_getdents, uint, fd, struct dirent *, dirp, uint, count);
-_syscall3(int, sys_getdents64, uint, fd, struct dirent64 *, dirp, uint, count);
-_syscall5(int, _llseek,  uint,  fd, ulong, hi, ulong, lo,
-          loff_t *, res, uint, wh);
-_syscall2(int,sys_statfs,const char *,path,struct kernel_statfs *,buf)
-_syscall2(int,sys_fstatfs,int,fd,struct kernel_statfs *,buf)
-_syscall3(int,sys_rt_sigqueueinfo,int,pid,int,sig,siginfo_t *,uinfo)
+
+static int sys_uname (struct new_utsname *buf)
+{
+  return syscall(__NR_uname, buf);
+}
+
+static int sys_getcwd1 (char *buf, size_t size)
+{
+  return syscall(__NR_getcwd, buf, size);
+}
+
+static int sys_getdents (uint fd, struct dirent *dirp, uint count)
+{
+  return syscall(__NR_getdents, fd, dirp, count);
+}
+
+static int sys_getdents64 (uint fd, struct dirent64 *dirp, uint count)
+{
+  return syscall(__NR_getdents64, fd, dirp, count);
+}
+
+static int sys_statfs (const char *path, struct kernel_statfs *buf)
+{
+  return syscall(__NR_statfs, path, buf);
+}
+
+static int sys_fstatfs (int fd, struct kernel_statfs *buf)
+{
+  return syscall(__NR_fstatfs, fd, buf);
+}
+
+static int sys_rt_sigqueueinfo (int pid, int sig, siginfo_t *uinfo)
+{
+  return syscall(__NR_rt_sigqueueinfo, pid, sig, uinfo);
+}
 #ifdef __NR_exit_group
-_syscall1(int,exit_group,int,error_code)
+static int exit_group (int error_code)
+{
+  return syscall(__NR_exit_group, error_code);
+}
 #endif
 
 extern int personality(int);
@@ -255,6 +153,21 @@
     return (unsigned long)ret >= (unsigned long)(-4096);
 }
 
+static inline long _llseek (uint fd, ulong hi, ulong lo, int64_t *pos,
+			    uint wh)
+{
+  long ret;
+#if defined(__alpha) || defined(__ia64) || defined (__x86_64__)
+  ret = *pos = lseek(fd, (hi << 32) | lo, wh);
+#else
+  int64_t res;
+
+  ret = syscall(__NR__llseek, fd, hi, lo, &res, wh);
+  *pos = tswap64(res);
+#endif
+  return get_errno(ret);
+}
+
 static char *target_brk;
 static char *target_original_brk;
 
@@ -1445,7 +1358,8 @@
 #endif
         new_env->opaque = ts;
 #ifdef __ia64__
-        ret = clone2(clone_func, new_stack + NEW_STACK_SIZE, flags, new_env);
+        ret = __clone2(clone_func, new_stack, new_stack + NEW_STACK_SIZE,
+		       flags, new_env);
 #else
 	ret = clone(clone_func, new_stack + NEW_STACK_SIZE, flags, new_env);
 #endif
@@ -2462,16 +2376,7 @@
     case TARGET_NR_afs_syscall:
         goto unimplemented;
     case TARGET_NR__llseek:
-        {
-#if defined (__x86_64__)
-            ret = get_errno(lseek(arg1, ((uint64_t )arg2 << 32) | arg3, arg5));
-            *(int64_t *)arg4 = ret;
-#else
-            int64_t res;
-            ret = get_errno(_llseek(arg1, arg2, arg3, &res, arg5));
-            *(int64_t *)arg4 = tswap64(res);
-#endif
-        }
+        ret = _llseek(arg1, arg2, arg3, (int64_t *) arg4, arg5);
         break;
     case TARGET_NR_getdents:
 #if TARGET_LONG_SIZE != 4
Index: target-i386/cpu.h
=================================RCS file: /cvsroot/qemu/qemu/target-i386/cpu.h,v
retrieving revision 1.24
diff -u -r1.24 cpu.h
--- target-i386/cpu.h	23 Jan 2005 20:43:45 -0000	1.24
+++ target-i386/cpu.h	14 Feb 2005 17:34:44 -0000
@@ -389,7 +389,8 @@
 #endif
 
 typedef struct CPUX86State {
-#if TARGET_LONG_BITS > HOST_LONG_BITS
+//#if TARGET_LONG_BITS > HOST_LONG_BITS
+#if TARGET_LONG_BITS != 32
     /* temporaries if we cannot store them in host registers */
     target_ulong t0, t1, t2;
 #endif
Index: target-i386/exec.h
=================================RCS file: /cvsroot/qemu/qemu/target-i386/exec.h,v
retrieving revision 1.21
diff -u -r1.21 exec.h
--- target-i386/exec.h	23 Jan 2005 20:44:55 -0000	1.21
+++ target-i386/exec.h	14 Feb 2005 17:34:44 -0000
@@ -39,7 +39,7 @@
 /* XXX: use 64 bit regs if HOST_LONG_BITS = 64 */
 #if TARGET_LONG_BITS = 32
 
-register uint32_t T0 asm(AREG1);
+register uint64_t T0 asm(AREG1);
 register uint32_t T1 asm(AREG2);
 register uint32_t T2 asm(AREG3);
 
Index: target-i386/helper.c
=================================RCS file: /cvsroot/qemu/qemu/target-i386/helper.c,v
retrieving revision 1.41
diff -u -r1.41 helper.c
--- target-i386/helper.c	23 Jan 2005 20:45:23 -0000	1.41
+++ target-i386/helper.c	14 Feb 2005 17:34:44 -0000
@@ -1074,7 +1074,7 @@
                        target_ulong next_eip)
 {
     SegmentCache *dt;
-    target_ulong ptr;
+    target_phys_addr_t ptr;
     int dpl, cpl;
     uint32_t e2;
 
@@ -1449,7 +1449,7 @@
     int cpl, dpl, rpl;
     SegmentCache *dt;
     int index;
-    target_ulong ptr;
+    target_phys_addr_t ptr;
 
     selector &= 0xffff;
     if ((selector & 0xfffc) = 0) {
Index: target-i386/op.c
=================================RCS file: /cvsroot/qemu/qemu/target-i386/op.c,v
retrieving revision 1.31
diff -u -r1.31 op.c
--- target-i386/op.c	31 Jan 2005 23:31:02 -0000	1.31
+++ target-i386/op.c	14 Feb 2005 17:34:44 -0000
@@ -415,12 +415,12 @@
 /* XXX: consistent names */
 void OPPROTO op_movl_T0_imu(void)
 {
-    T0 = (uint32_t)PARAM1;
+    T0 = (uint64_t)PARAM1;
 }
 
 void OPPROTO op_movl_T0_im(void)
 {
-    T0 = (int32_t)PARAM1;
+    T0 = (uint64_t)PARAM1;
 }
 
 void OPPROTO op_addl_T0_im(void)
Index: target-i386/translate.c
=================================RCS file: /cvsroot/qemu/qemu/target-i386/translate.c,v
retrieving revision 1.45
diff -u -r1.45 translate.c
--- target-i386/translate.c	1 Feb 2005 20:25:03 -0000	1.45
+++ target-i386/translate.c	14 Feb 2005 17:34:45 -0000
@@ -31,7 +31,7 @@
 
 /* XXX: move that elsewhere */
 static uint16_t *gen_opc_ptr;
-static uint32_t *gen_opparam_ptr;
+static uint64_t *gen_opparam_ptr;
 
 #define PREFIX_REPZ   0x01
 #define PREFIX_REPNZ  0x02
Index: target-sparc/translate.c
=================================RCS file: /cvsroot/qemu/qemu/target-sparc/translate.c,v
retrieving revision 1.16
diff -u -r1.16 translate.c
--- target-sparc/translate.c	30 Jan 2005 22:39:04 -0000	1.16
+++ target-sparc/translate.c	14 Feb 2005 17:34:45 -0000
@@ -1670,7 +1670,7 @@
 }
 
 #if defined(CONFIG_USER_ONLY)
-target_phys_addr_t cpu_get_phys_page_debug(CPUState *env, target_ulong addr)
+target_ulong cpu_get_phys_page_debug(CPUState *env, target_ulong addr)
 {
     return addr;
 }

