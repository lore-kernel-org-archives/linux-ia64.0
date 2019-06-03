From: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
Date: Mon, 03 Jun 2019 10:57:25 +0000
Subject: [PATCH modules 1/2] module: allow arch overrides for .exit section names
Message-Id: <20190603105726.22436-2-matthias.schiffer@ew.tq-group.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190603105726.22436-1-matthias.schiffer@ew.tq-group.com>
In-Reply-To: <20190603105726.22436-1-matthias.schiffer@ew.tq-group.com>
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
 include/linux/moduleloader.h | 8 ++++++++
 kernel/module.c              | 2 +-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/moduleloader.h b/include/linux/moduleloader.h
index 31013c2effd3..cddbd85fb659 100644
--- a/include/linux/moduleloader.h
+++ b/include/linux/moduleloader.h
@@ -5,6 +5,7 @@
 
 #include <linux/module.h>
 #include <linux/elf.h>
+#include <linux/string.h>
 
 /* These may be implemented by architectures that need to hook into the
  * module loader code.  Architectures that don't need to do anything special
@@ -93,4 +94,11 @@ void module_arch_freeing_init(struct module *mod);
 #define MODULE_ALIGN PAGE_SIZE
 #endif
 
+#ifndef HAVE_ARCH_MODULE_EXIT_SECTION
+static inline bool module_exit_section(const char *name)
+{
+	return strstarts(name, ".exit");
+}
+#endif
+
 #endif
diff --git a/kernel/module.c b/kernel/module.c
index 6e6712b3aaf5..e8e4cd0a471f 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2924,7 +2924,7 @@ static int rewrite_section_headers(struct load_info *info, int flags)
 
 #ifndef CONFIG_MODULE_UNLOAD
 		/* Don't load .exit sections */
-		if (strstarts(info->secstrings+shdr->sh_name, ".exit"))
+		if (module_exit_section(info->secstrings+shdr->sh_name))
 			shdr->sh_flags &= ~(unsigned long)SHF_ALLOC;
 #endif
 	}
-- 
2.17.1
