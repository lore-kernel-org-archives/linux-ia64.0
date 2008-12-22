From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 22 Dec 2008 05:51:13 +0000
Subject: [PATCH 3/5] ia64/pv_ops/bp/module: support binary patching for kernel module.
Message-Id: <1229925075-31465-4-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1227618235-3890-4-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1227618235-3890-4-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

support binary patching for kernel module.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/module.h |    6 ++++++
 arch/ia64/kernel/module.c      |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/module.h b/arch/ia64/include/asm/module.h
index d2da61e..908eaef 100644
--- a/arch/ia64/include/asm/module.h
+++ b/arch/ia64/include/asm/module.h
@@ -16,6 +16,12 @@ struct mod_arch_specific {
 	struct elf64_shdr *got;		/* global offset table */
 	struct elf64_shdr *opd;		/* official procedure descriptors */
 	struct elf64_shdr *unwind;	/* unwind-table section */
+#ifdef CONFIG_PARAVIRT
+	struct elf64_shdr *paravirt_bundles;
+					/* paravirt_alt_bundle_patch table */
+	struct elf64_shdr *paravirt_insts;
+					/* paravirt_alt_inst_patch table */
+#endif
 	unsigned long gp;		/* global-pointer for module */
 
 	void *core_unw_table;		/* core unwind-table cookie returned by unwinder */
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index aaa7d90..34fe425 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -446,6 +446,14 @@ module_frob_arch_sections (Elf_Ehdr *ehdr, Elf_Shdr *sechdrs, char *secstrings,
 			mod->arch.opd = s;
 		else if (strcmp(".IA_64.unwind", secstrings + s->sh_name) = 0)
 			mod->arch.unwind = s;
+#ifdef CONFIG_PARAVIRT
+		else if (strcmp(".paravirt_bundles",
+				secstrings + s->sh_name) = 0)
+			mod->arch.paravirt_bundles = s;
+		else if (strcmp(".paravirt_insts",
+				secstrings + s->sh_name) = 0)
+			mod->arch.paravirt_insts = s;
+#endif
 
 	if (!mod->arch.core_plt || !mod->arch.init_plt || !mod->arch.got || !mod->arch.opd) {
 		printk(KERN_ERR "%s: sections missing\n", mod->name);
@@ -921,6 +929,30 @@ module_finalize (const Elf_Ehdr *hdr, const Elf_Shdr *sechdrs, struct module *mo
 	DEBUGP("%s: init: entry=%p\n", __func__, mod->init);
 	if (mod->arch.unwind)
 		register_unwind_table(mod);
+#ifdef CONFIG_PARAVIRT
+        if (mod->arch.paravirt_bundles) {
+                struct paravirt_patch_site_bundle *start +                        (struct paravirt_patch_site_bundle *)
+                        mod->arch.paravirt_bundles->sh_addr;
+                struct paravirt_patch_site_bundle *end +                        (struct paravirt_patch_site_bundle *)
+                        (mod->arch.paravirt_bundles->sh_addr +
+                         mod->arch.paravirt_bundles->sh_size);
+
+                paravirt_patch_apply_bundle(start, end);
+        }
+        if (mod->arch.paravirt_insts) {
+                struct paravirt_patch_site_inst *start +                        (struct paravirt_patch_site_inst *)
+                        mod->arch.paravirt_insts->sh_addr;
+                struct paravirt_patch_site_inst *end +                        (struct paravirt_patch_site_inst *)
+                        (mod->arch.paravirt_insts->sh_addr +
+                         mod->arch.paravirt_insts->sh_size);
+
+                paravirt_patch_apply_inst(start, end);
+        }
+#endif
 	return 0;
 }
 
-- 
1.6.0.2

