From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 17 Dec 2002 00:27:11 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805584@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Could someone who is Attuned with the way of ia64 linking and asm
> please look at this?  It's a userspace framework which tests the 2.5
> module code (as modified by RTH to use shared objects rather than
> simple object files).  You can see 9 architectures already done, but
> ia64 doesn't work, for reasons beyond my humble abilities.
> 
> The idea is that once all the archs are finished, I put it in the
> kernel and push the change Linus.  ia64 is the last "important" arch
> (and, naturally, the hardest 8).
> 
> Thanks in advance!
> Rusty.
> --
>   Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

Sorry, that was a hacked version.  Apply this patch.

diff -ur module-test-framework/Makefile module-test-framework-fixed/Makefile
--- module-test-framework/Makefile	2002-12-17 09:48:11.000000000 +1100
+++ module-test-framework-fixed/Makefile	2002-12-17 11:22:56.000000000 +1100
@@ -18,7 +18,7 @@
 
 # Buggy binutils on PPC needs -fPIC
 KLDFLAGS_ppc:-KCCFLAGS_ppc:+KCCFLAGS_ppc:=-fPIC
 
 KLDFLAGS_ppc64:= -melf64ppc -Bsymbolic
 KCCFLAGS_ppc64:= -mminimal-toc
diff -ur module-test-framework/mod.c module-test-framework-fixed/mod.c
--- module-test-framework/mod.c	2002-12-17 09:53:05.000000000 +1100
+++ module-test-framework-fixed/mod.c	2002-12-17 11:18:15.000000000 +1100
@@ -12,7 +12,6 @@
 extern int __initfn(void);
 extern void __exitfn(void);
 
-#if 0
 /* We use the linker to do a lot of this work for us. */
 struct module __this_module __attribute__((section("this_module"))) = {
 	.name = MODULE_NAME,
@@ -35,27 +34,3 @@
 	.exit = __exitfn,
 #endif
 };
-#else
-/* We use the linker to do a lot of this work for us. */
-struct module __this_module __attribute__((section("this_module"))) = {
-	.name = MODULE_NAME,
-	.symbols = { .owner = &__this_module,
-		     .start = __start___ksymtab,
-		     .end = __stop___ksymtab,
-	},
-	.extable = { .start = NULL,
-		     .end = NULL,
-	},
-	.param_start = __start___param,
-	.param_end = __stop___param,
-	.init = __initfn,
-	.cut_here = __module_cut,
-#ifdef CONFIG_OBSOLETE_MODPARM
-	.obsparam_start = NULL,
-	.obsparam_end = NULL,
-#endif
-#ifdef CONFIG_MODULE_UNLOAD
-	.exit = __exitfn,
-#endif
-};
-#endif 
diff -ur module-test-framework/module.c module-test-framework-fixed/module.c
--- module-test-framework/module.c	2002-12-17 09:53:56.000000000 +1100
+++ module-test-framework-fixed/module.c	2002-12-17 11:22:28.000000000 +1100
@@ -637,13 +637,12 @@
 	sechdrs = (void *)hdr + hdr->e_shoff;
 	secstrings = (void *)hdr + sechdrs[hdr->e_shstrndx].sh_offset;
 	for (i = 1; i < hdr->e_shnum; i++) {
-		if (strcmp(secstrings+sechdrs[i].sh_name, ".strtab") = 0) {
-			DEBUGP("String table in section %u\n", i);
-			strtab = (void *)hdr + sechdrs[i].sh_offset;
-		} else if (sechdrs[i].sh_type = SHT_SYMTAB) {
+		if (sechdrs[i].sh_type = SHT_SYMTAB) {
 			/* Internal symbols */
 			DEBUGP("Symbol table in section %u\n", i);
 			symindex = i;
+			strtab = (void *)hdr
+				+ sechdrs[sechdrs[i].sh_link].sh_offset;
 		}
 	}
 
@@ -973,9 +972,6 @@
 		} else if (phdrs[i].p_type = PT_LINUX_MODULE)
 			me = loadaddr + phdrs[i].p_vaddr;
 	}
-#if 1
-	me = loadaddr + 0x00000084;
-#endif
 	if (!me) {
 		printk(KERN_ERR "load_module: No module found\n");
 		err = -ENOEXEC;


--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

