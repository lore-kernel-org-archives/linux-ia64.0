From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Wed, 25 Aug 2021 11:48:28 +0000
Subject: [PATCH 2/3] ia64: Make reserve_elfcorehdr() static
Message-Id: <fe236cd73b64abc4abd03dd808cb015c907f4c8c.1629884459.git.geert+renesas@glider.be>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1629884459.git.geert+renesas@glider.be>
In-Reply-To: <cover.1629884459.git.geert+renesas@glider.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Simon Horman <horms@verge.net.au>, Tony Luck <tony.luck@intel.com>, Jay Lan <jlan@sgi.com>, Magnus Damm <magnus.damm@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, devicetree@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>

There never was a reason for reserve_elfcorehdr() to be global.
Make the function static, and move it before its sole caller.

Fixes: cee87af2a5f75713 ("[IA64] kexec: Use EFI_LOADER_DATA for ELF core header")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
This fixes a conflict triggered by
https://lore.kernel.org/r/c7e46e50aaf87ef49bdaa61358d25b122f32b7df.1628670468.git.geert+renesas@glider.be/
and fixed by
https://lore.kernel.org/r/f6eabbbce0fba6da3da0264c1e1cf23c01173999.1629884393.git.geert+renesas@glider.be
 arch/ia64/include/asm/meminit.h |  1 -
 arch/ia64/kernel/setup.c        | 51 ++++++++++++++++-----------------
 2 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/arch/ia64/include/asm/meminit.h b/arch/ia64/include/asm/meminit.h
index 6c47a239fc26df12..2738f62b5f989492 100644
--- a/arch/ia64/include/asm/meminit.h
+++ b/arch/ia64/include/asm/meminit.h
@@ -40,7 +40,6 @@ extern unsigned long efi_memmap_init(u64 *s, u64 *e);
 extern int find_max_min_low_pfn (u64, u64, void *);
 
 extern unsigned long vmcore_find_descriptor_size(unsigned long address);
-extern int reserve_elfcorehdr(u64 *start, u64 *end);
 
 /*
  * For rounding an address to the next IA64_GRANULE_SIZE or order
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index fbd931f1eb270d98..5e6ee8939092a2df 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -325,6 +325,31 @@ static inline void __init setup_crashkernel(unsigned long total, int *n)
 {}
 #endif
 
+#ifdef CONFIG_CRASH_DUMP
+static int __init reserve_elfcorehdr(u64 *start, u64 *end)
+{
+	u64 length;
+
+	/* We get the address using the kernel command line,
+	 * but the size is extracted from the EFI tables.
+	 * Both address and size are required for reservation
+	 * to work properly.
+	 */
+
+	if (!is_vmcore_usable())
+		return -EINVAL;
+
+	if ((length = vmcore_find_descriptor_size(elfcorehdr_addr)) = 0) {
+		vmcore_unusable();
+		return -EINVAL;
+	}
+
+	*start = (unsigned long)__va(elfcorehdr_addr);
+	*end = *start + length;
+	return 0;
+}
+#endif /* CONFIG_CRASH_DUMP */
+
 /**
  * reserve_memory - setup reserved memory areas
  *
@@ -522,32 +547,6 @@ static __init int setup_nomca(char *s)
 }
 early_param("nomca", setup_nomca);
 
-#ifdef CONFIG_CRASH_DUMP
-int __init reserve_elfcorehdr(u64 *start, u64 *end)
-{
-	u64 length;
-
-	/* We get the address using the kernel command line,
-	 * but the size is extracted from the EFI tables.
-	 * Both address and size are required for reservation
-	 * to work properly.
-	 */
-
-	if (!is_vmcore_usable())
-		return -EINVAL;
-
-	if ((length = vmcore_find_descriptor_size(elfcorehdr_addr)) = 0) {
-		vmcore_unusable();
-		return -EINVAL;
-	}
-
-	*start = (unsigned long)__va(elfcorehdr_addr);
-	*end = *start + length;
-	return 0;
-}
-
-#endif /* CONFIG_CRASH_DUMP */
-
 void __init
 setup_arch (char **cmdline_p)
 {
-- 
2.25.1
