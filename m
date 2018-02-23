From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Date: Fri, 23 Feb 2018 16:58:48 +0000
Subject: [PATCH 2/3] ARM: PLT: Move struct plt_entries definition to header
Message-Id: <20180223165849.16388-3-alexander.sverdlin@nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180223165849.16388-1-alexander.sverdlin@nokia.com>
In-Reply-To: <20180223165849.16388-1-alexander.sverdlin@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

No functional change, later it will be re-used in several files.

Signed-off-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
---
 arch/arm/include/asm/module.h | 9 +++++++++
 arch/arm/kernel/module-plts.c | 9 ---------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/arm/include/asm/module.h b/arch/arm/include/asm/module.h
index 89ad059..6996405 100644
--- a/arch/arm/include/asm/module.h
+++ b/arch/arm/include/asm/module.h
@@ -19,6 +19,15 @@ enum {
 };
 #endif
 
+#define PLT_ENT_STRIDE		L1_CACHE_BYTES
+#define PLT_ENT_COUNT		(PLT_ENT_STRIDE / sizeof(u32))
+#define PLT_ENT_SIZE		(sizeof(struct plt_entries) / PLT_ENT_COUNT)
+
+struct plt_entries {
+	u32	ldr[PLT_ENT_COUNT];
+	u32	lit[PLT_ENT_COUNT];
+};
+
 struct mod_plt_sec {
 	struct elf32_shdr	*plt;
 	int			plt_count;
diff --git a/arch/arm/kernel/module-plts.c b/arch/arm/kernel/module-plts.c
index 3d0c2e4..f272711 100644
--- a/arch/arm/kernel/module-plts.c
+++ b/arch/arm/kernel/module-plts.c
@@ -14,10 +14,6 @@
 #include <asm/cache.h>
 #include <asm/opcodes.h>
 
-#define PLT_ENT_STRIDE		L1_CACHE_BYTES
-#define PLT_ENT_COUNT		(PLT_ENT_STRIDE / sizeof(u32))
-#define PLT_ENT_SIZE		(sizeof(struct plt_entries) / PLT_ENT_COUNT)
-
 #ifdef CONFIG_THUMB2_KERNEL
 #define PLT_ENT_LDR		__opcode_to_mem_thumb32(0xf8dff000 | \
 							(PLT_ENT_STRIDE - 4))
@@ -26,11 +22,6 @@
 						    (PLT_ENT_STRIDE - 8))
 #endif
 
-struct plt_entries {
-	u32	ldr[PLT_ENT_COUNT];
-	u32	lit[PLT_ENT_COUNT];
-};
-
 static bool in_init(const struct module *mod, unsigned long loc)
 {
 	return loc - (u32)mod->init_layout.base < mod->init_layout.size;
-- 
2.4.6

