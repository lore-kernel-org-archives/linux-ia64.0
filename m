From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 08 Jan 2015 01:10:05 +0000
Subject: [PATCH 1/3] module_arch_freeing_init(): new hook for archs before module->module_init freed.
Message-Id: <1420678687-30548-2-git-send-email-rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1420678687-30548-1-git-send-email-rusty@rustcorp.com.au>
In-Reply-To: <1420678687-30548-1-git-send-email-rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Rusty Russell <rusty@rustcorp.com.au>, Chris Metcalf <cmetcalf@ezchip.com>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org

Archs have been abusing module_free() to clean up their arch-specific
allocations.  Since module_free() is also (ab)used by BPF and trace code,
let's keep it to simple allocations, and provide a hook called before
that.

This means that avr32, ia64, parisc and s390 no longer need to implement
their own module_free() at all.  avr32 doesn't need module_finalize()
either.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: Chris Metcalf <cmetcalf@ezchip.com>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: linux-s390@vger.kernel.org
---
 arch/avr32/kernel/module.c   | 13 +------------
 arch/ia64/kernel/module.c    |  6 ++----
 arch/parisc/kernel/module.c  |  6 +-----
 arch/s390/kernel/module.c    | 10 +++-------
 arch/tile/kernel/module.c    |  2 +-
 include/linux/moduleloader.h |  2 ++
 kernel/module.c              |  7 +++++++
 7 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/arch/avr32/kernel/module.c b/arch/avr32/kernel/module.c
index 2c9412908024..164efa009e5b 100644
--- a/arch/avr32/kernel/module.c
+++ b/arch/avr32/kernel/module.c
@@ -19,12 +19,10 @@
 #include <linux/moduleloader.h>
 #include <linux/vmalloc.h>
 
-void module_free(struct module *mod, void *module_region)
+void module_arch_freeing_init(struct module *mod)
 {
 	vfree(mod->arch.syminfo);
 	mod->arch.syminfo = NULL;
-
-	vfree(module_region);
 }
 
 static inline int check_rela(Elf32_Rela *rela, struct module *module,
@@ -291,12 +289,3 @@ int apply_relocate_add(Elf32_Shdr *sechdrs, const char *strtab,
 
 	return ret;
 }
-
-int module_finalize(const Elf_Ehdr *hdr, const Elf_Shdr *sechdrs,
-		    struct module *module)
-{
-	vfree(module->arch.syminfo);
-	module->arch.syminfo = NULL;
-
-	return 0;
-}
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 24603be24c14..29754aae5177 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -305,14 +305,12 @@ plt_target (struct plt_entry *plt)
 #endif /* !USE_BRL */
 
 void
-module_free (struct module *mod, void *module_region)
+module_arch_freeing_init (struct module *mod)
 {
-	if (mod && mod->arch.init_unw_table &&
-	    module_region = mod->module_init) {
+	if (mod->arch.init_unw_table) {
 		unw_remove_unwind_table(mod->arch.init_unw_table);
 		mod->arch.init_unw_table = NULL;
 	}
-	vfree(module_region);
 }
 
 /* Have we already seen one of these relocations? */
diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index 50dfafc3f2c1..5822e8e200e6 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -298,14 +298,10 @@ static inline unsigned long count_stubs(const Elf_Rela *rela, unsigned long n)
 }
 #endif
 
-
-/* Free memory returned from module_alloc */
-void module_free(struct module *mod, void *module_region)
+void module_arch_freeing_init(struct module *mod)
 {
 	kfree(mod->arch.section);
 	mod->arch.section = NULL;
-
-	vfree(module_region);
 }
 
 /* Additional bytes needed in front of individual sections */
diff --git a/arch/s390/kernel/module.c b/arch/s390/kernel/module.c
index b89b59158b95..409d152585be 100644
--- a/arch/s390/kernel/module.c
+++ b/arch/s390/kernel/module.c
@@ -55,14 +55,10 @@ void *module_alloc(unsigned long size)
 }
 #endif
 
-/* Free memory returned from module_alloc */
-void module_free(struct module *mod, void *module_region)
+void module_arch_freeing_init(struct module *mod)
 {
-	if (mod) {
-		vfree(mod->arch.syminfo);
-		mod->arch.syminfo = NULL;
-	}
-	vfree(module_region);
+	vfree(mod->arch.syminfo);
+	mod->arch.syminfo = NULL;
 }
 
 static void check_rela(Elf_Rela *rela, struct module *me)
diff --git a/arch/tile/kernel/module.c b/arch/tile/kernel/module.c
index 96447c9160a0..62a597e810d6 100644
--- a/arch/tile/kernel/module.c
+++ b/arch/tile/kernel/module.c
@@ -83,7 +83,7 @@ void module_free(struct module *mod, void *module_region)
 		     0, 0, 0, NULL, NULL, 0);
 
 	/*
-	 * FIXME: If module_region = mod->module_init, trim exception
+	 * FIXME: Add module_arch_freeing_init to trim exception
 	 * table entries.
 	 */
 }
diff --git a/include/linux/moduleloader.h b/include/linux/moduleloader.h
index 7eeb9bbfb816..054eac853090 100644
--- a/include/linux/moduleloader.h
+++ b/include/linux/moduleloader.h
@@ -82,4 +82,6 @@ int module_finalize(const Elf_Ehdr *hdr,
 /* Any cleanup needed when module leaves. */
 void module_arch_cleanup(struct module *mod);
 
+/* Any cleanup before freeing mod->module_init */
+void module_arch_freeing_init(struct module *mod);
 #endif
diff --git a/kernel/module.c b/kernel/module.c
index 3965511ae133..68be0b1f9e7f 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -1804,6 +1804,10 @@ void __weak module_arch_cleanup(struct module *mod)
 {
 }
 
+void __weak module_arch_freeing_init(struct module *mod)
+{
+}
+
 /* Free a module, remove from lists, etc. */
 static void free_module(struct module *mod)
 {
@@ -1841,6 +1845,7 @@ static void free_module(struct module *mod)
 
 	/* This may be NULL, but that's OK */
 	unset_module_init_ro_nx(mod);
+	module_arch_freeing_init(mod);
 	module_free(mod, mod->module_init);
 	kfree(mod->args);
 	percpu_modfree(mod);
@@ -2930,6 +2935,7 @@ static struct module *layout_and_allocate(struct load_info *info, int flags)
 static void module_deallocate(struct module *mod, struct load_info *info)
 {
 	percpu_modfree(mod);
+	module_arch_freeing_init(mod);
 	module_free(mod, mod->module_init);
 	module_free(mod, mod->module_core);
 }
@@ -3055,6 +3061,7 @@ static int do_init_module(struct module *mod)
 	mod->strtab = mod->core_strtab;
 #endif
 	unset_module_init_ro_nx(mod);
+	module_arch_freeing_init(mod);
 	module_free(mod, mod->module_init);
 	mod->module_init = NULL;
 	mod->init_size = 0;
-- 
2.1.0

