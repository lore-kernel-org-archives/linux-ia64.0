From: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
Date: Fri, 07 Jun 2019 10:49:12 +0000
Subject: [PATCH modules v2 2/2] ARM: module: recognize unwind exit sections
Message-Id: <20190607104912.6252-3-matthias.schiffer@ew.tq-group.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190607104912.6252-1-matthias.schiffer@ew.tq-group.com>
In-Reply-To: <20190607104912.6252-1-matthias.schiffer@ew.tq-group.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <linux@armlinux.org.uk>, Jessica Yu <jeyu@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Matthias Schiffer <matthias.schiffer@ew.tq-group.com>

In addition to the prefix ".exit", ".ARM.extab.exit" and ".ARM.exidx.exit"
must be recognized as exit sections as well. Otherwise, loading modules can
fail without CONFIG_MODULE_UNLOAD depending on the memory layout, when
relocations for the unwind sections refer to the .exit.text section:

  imx_sdma: section 16 reloc 0 sym '': relocation 42 out of range
  (0x7f015260 -> 0xc0f5a5e8)

where 0x7F000000 is the module load area and 0xC0000000 is the vmalloc
area. Relocation 42 refers to R_ARM_PREL31, which is limited to signed
31bit offsets.

Signed-off-by: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
---
v2: Use __weak function as suggested by Jessica

 arch/arm/kernel/module.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm/kernel/module.c b/arch/arm/kernel/module.c
index 3ff571c2c71c..692001aabb0f 100644
--- a/arch/arm/kernel/module.c
+++ b/arch/arm/kernel/module.c
@@ -58,6 +58,13 @@ void *module_alloc(unsigned long size)
 }
 #endif
 
+bool module_exit_section(const char *name)
+{
+	return strstarts(name, ".exit") ||
+		strstarts(name, ".ARM.extab.exit") ||
+		strstarts(name, ".ARM.exidx.exit");
+}
+
 int
 apply_relocate(Elf32_Shdr *sechdrs, const char *strtab, unsigned int symindex,
 	       unsigned int relindex, struct module *module)
-- 
2.17.1
