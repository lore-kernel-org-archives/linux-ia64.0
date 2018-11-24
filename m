From: Lianbo Jiang <lijiang@redhat.com>
Date: Sat, 24 Nov 2018 05:12:22 +0000
Subject: [PATCH 1/2 RESEND v7] resource: add the new I/O resource descriptor 'IORES_DESC_RESERVED'
Message-Id: <20181124051223.19994-2-lijiang@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181124051223.19994-1-lijiang@redhat.com>
In-Reply-To: <20181124051223.19994-1-lijiang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, dyoung@redhat.com, bhe@redhat.com

The upstream kernel can not accurately add the e820 reserved type to
kdump krenel e820 table.

Kdump uses walk_iomem_res_desc() to iterate io resources, then adds
the matched resource ranges to the e820 table for kdump kernel. But,
when convert the e820 type to the iores descriptor, several e820
types are converted to 'IORES_DESC_NONE' in this function e820_type
_to_iores_desc(). So the walk_iomem_res_desc() will get the redundant
types(such as E820_TYPE_RAM/E820_TYPE_UNUSABLE/E820_TYPE_KERN) when
walk through io resources with the descriptor 'IORES_DESC_NONE'.

This patch adds the new I/O resource descriptor 'IORES_DESC_RESERVED'
for the iomem resources search interfaces. It is helpful to exactly
match the reserved resource ranges when walking through iomem resources.

Furthermore, in order to make it still work after the new descriptor
is added, these codes originally related to 'IORES_DESC_NONE' have
been updated.

Suggested-by: Dave Young <dyoung@redhat.com>
Signed-off-by: Lianbo Jiang <lijiang@redhat.com>
---
 arch/ia64/kernel/efi.c | 4 ++++
 arch/x86/kernel/e820.c | 2 +-
 arch/x86/mm/ioremap.c  | 9 ++++++++-
 include/linux/ioport.h | 1 +
 kernel/resource.c      | 6 +++---
 5 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 8f106638913c..1841e9b4db30 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -1231,6 +1231,10 @@ efi_initialize_iomem_resources(struct resource *code_resource,
 				break;
 
 			case EFI_RESERVED_TYPE:
+				name = "reserved";
+				desc = IORES_DESC_RESERVED;
+				break;
+
 			case EFI_RUNTIME_SERVICES_CODE:
 			case EFI_RUNTIME_SERVICES_DATA:
 			case EFI_ACPI_RECLAIM_MEMORY:
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 50895c2f937d..57fafdafb860 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1048,10 +1048,10 @@ static unsigned long __init e820_type_to_iores_desc(struct e820_entry *entry)
 	case E820_TYPE_NVS:		return IORES_DESC_ACPI_NV_STORAGE;
 	case E820_TYPE_PMEM:		return IORES_DESC_PERSISTENT_MEMORY;
 	case E820_TYPE_PRAM:		return IORES_DESC_PERSISTENT_MEMORY_LEGACY;
+	case E820_TYPE_RESERVED:	return IORES_DESC_RESERVED;
 	case E820_TYPE_RESERVED_KERN:	/* Fall-through: */
 	case E820_TYPE_RAM:		/* Fall-through: */
 	case E820_TYPE_UNUSABLE:	/* Fall-through: */
-	case E820_TYPE_RESERVED:	/* Fall-through: */
 	default:			return IORES_DESC_NONE;
 	}
 }
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 5378d10f1d31..91b6112e7489 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -83,7 +83,14 @@ static bool __ioremap_check_ram(struct resource *res)
 
 static int __ioremap_check_desc_other(struct resource *res)
 {
-	return (res->desc != IORES_DESC_NONE);
+	/*
+	 * The E820_TYPE_RESERVED was converted to the IORES_DESC_NONE
+	 * before the new IORES_DESC_RESERVED is added, so it contained
+	 * the e820 reserved type. In order to make it still work for
+	 * SEV, here keep it the same as before.
+	 */
+	return ((res->desc != IORES_DESC_NONE) ||
+		(res->desc != IORES_DESC_RESERVED));
 }
 
 static int __ioremap_res_check(struct resource *res, void *arg)
diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index da0ebaec25f0..6ed59de48bd5 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -133,6 +133,7 @@ enum {
 	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
 	IORES_DESC_DEVICE_PRIVATE_MEMORY	= 6,
 	IORES_DESC_DEVICE_PUBLIC_MEMORY		= 7,
+	IORES_DESC_RESERVED			= 8,
 };
 
 /* helpers to define resources */
diff --git a/kernel/resource.c b/kernel/resource.c
index b0fbf685c77a..f34a632c4169 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -994,7 +994,7 @@ __reserve_region_with_split(struct resource *root, resource_size_t start,
 	res->start = start;
 	res->end = end;
 	res->flags = type | IORESOURCE_BUSY;
-	res->desc = IORES_DESC_NONE;
+	res->desc = IORES_DESC_RESERVED;
 
 	while (1) {
 
@@ -1029,7 +1029,7 @@ __reserve_region_with_split(struct resource *root, resource_size_t start,
 				next_res->start = conflict->end + 1;
 				next_res->end = end;
 				next_res->flags = type | IORESOURCE_BUSY;
-				next_res->desc = IORES_DESC_NONE;
+				next_res->desc = IORES_DESC_RESERVED;
 			}
 		} else {
 			res->start = conflict->end + 1;
@@ -1477,7 +1477,7 @@ static int __init reserve_setup(char *str)
 			res->start = io_start;
 			res->end = io_start + io_num - 1;
 			res->flags |= IORESOURCE_BUSY;
-			res->desc = IORES_DESC_NONE;
+			res->desc = IORES_DESC_RESERVED;
 			res->child = NULL;
 			if (request_resource(parent, res) = 0)
 				reserved = x+1;
-- 
2.17.1
