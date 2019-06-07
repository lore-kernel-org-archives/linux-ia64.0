From: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
Date: Fri, 07 Jun 2019 10:49:11 +0000
Subject: [PATCH modules v2 1/2] module: allow arch overrides for .exit section names
Message-Id: <20190607104912.6252-2-matthias.schiffer@ew.tq-group.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190607104912.6252-1-matthias.schiffer@ew.tq-group.com>
In-Reply-To: <20190607104912.6252-1-matthias.schiffer@ew.tq-group.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <linux@armlinux.org.uk>, Jessica Yu <jeyu@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Matthias Schiffer <matthias.schiffer@ew.tq-group.com>

Some archs like ARM store unwind information for .exit.text in sections
with unusual names. As this unwind information refers to .exit.text, it
must not be loaded when .exit.text is not loaded (when CONFIG_MODULE_UNLOAD
is unset); otherwise, loading a module can fail due to relocation failures.

Signed-off-by: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
---
v2: Use __weak function as suggested by Jessica

 include/linux/moduleloader.h | 5 +++++
 kernel/module.c              | 7 ++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/moduleloader.h b/include/linux/moduleloader.h
index 31013c2effd3..5229c18025e9 100644
--- a/include/linux/moduleloader.h
+++ b/include/linux/moduleloader.h
@@ -29,6 +29,11 @@ void *module_alloc(unsigned long size);
 /* Free memory returned from module_alloc. */
 void module_memfree(void *module_region);
 
+/* Determines if the section name is an exit section (that is only used during
+ * module unloading)
+ */
+bool module_exit_section(const char *name);
+
 /*
  * Apply the given relocation to the (simplified) ELF.  Return -error
  * or 0.
diff --git a/kernel/module.c b/kernel/module.c
index 6e6712b3aaf5..043c0f965be2 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2735,6 +2735,11 @@ void * __weak module_alloc(unsigned long size)
 	return vmalloc_exec(size);
 }
 
+bool __weak module_exit_section(const char *name)
+{
+	return strstarts(name, ".exit");
+}
+
 #ifdef CONFIG_DEBUG_KMEMLEAK
 static void kmemleak_load_module(const struct module *mod,
 				 const struct load_info *info)
@@ -2924,7 +2929,7 @@ static int rewrite_section_headers(struct load_info *info, int flags)
 
 #ifndef CONFIG_MODULE_UNLOAD
 		/* Don't load .exit sections */
-		if (strstarts(info->secstrings+shdr->sh_name, ".exit"))
+		if (module_exit_section(info->secstrings+shdr->sh_name))
 			shdr->sh_flags &= ~(unsigned long)SHF_ALLOC;
 #endif
 	}
-- 
2.17.1
