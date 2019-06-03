From: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
Date: Mon, 03 Jun 2019 10:57:26 +0000
Subject: [PATCH modules 2/2] ARM: module: recognize unwind exit sections
Message-Id: <20190603105726.22436-3-matthias.schiffer@ew.tq-group.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190603105726.22436-1-matthias.schiffer@ew.tq-group.com>
In-Reply-To: <20190603105726.22436-1-matthias.schiffer@ew.tq-group.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <linux@armlinux.org.uk>, Jessica Yu <jeyu@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Matthias Schiffer <matthias.schiffer@ew.tq-group.com>

In addition to the prefix ".exit", ".ARM.extab.exit" and ".ARM.exidx.exit"
must be recognizes as exit sections as well. Otherwise, loading modules can
fail without CONFIG_MODULE_UNLOAD depending on the memory layout, when
relocations for the unwind sections refer to the .exit.text section:

  imx_sdma: section 16 reloc 0 sym '': relocation 42 out of range
  (0x7f015260 -> 0xc0f5a5e8)

where 0x7F000000 is the module load area and 0xC0000000 is the vmalloc
area. Relocation 42 refers to R_ARM_PREL31, which is limited to signed
31bit offsets.

Signed-off-by: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
---
 arch/arm/include/asm/module.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/arm/include/asm/module.h b/arch/arm/include/asm/module.h
index 182163b55546..f3401758d711 100644
--- a/arch/arm/include/asm/module.h
+++ b/arch/arm/include/asm/module.h
@@ -4,6 +4,8 @@
 
 #include <asm-generic/module.h>
 
+#include <linux/string.h>
+
 struct unwind_table;
 
 #ifdef CONFIG_ARM_UNWIND
@@ -72,4 +74,13 @@ static inline unsigned long kallsyms_symbol_value(const Elf_Sym *sym)
 }
 #endif
 
+#define HAVE_ARCH_MODULE_EXIT_SECTION
+static inline bool module_exit_section(const char *name)
+{
+	return strstarts(name, ".exit") ||
+		strstarts(name, ".ARM.extab.exit") ||
+		strstarts(name, ".ARM.exidx.exit");
+
+}
+
 #endif /* _ASM_ARM_MODULE_H */
-- 
2.17.1
