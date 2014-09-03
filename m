From: Laszlo Ersek <lersek@redhat.com>
Date: Wed, 03 Sep 2014 11:32:22 +0000
Subject: [PATCH v2 4/5] ia64: efi: format EFI memory type & attrs with efi_md_typeattr_format()
Message-Id: <1409743943-16934-5-git-send-email-lersek@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409743943-16934-1-git-send-email-lersek@redhat.com>
In-Reply-To: <1409743943-16934-1-git-send-email-lersek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@kernel.org, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, msalter@redhat.com, lersek@redhat.com

The effects of the patch on the i64 memory map log are similar to those
visible in the previous (x86) patch: the type enum and the attribute
bitmap are decoded.

Signed-off-by: Laszlo Ersek <lersek@redhat.com>
---
 arch/ia64/kernel/efi.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 741b99c..c52d754 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -568,6 +568,7 @@ efi_init (void)
 		{
 			const char *unit;
 			unsigned long size;
+			char buf[64];
 
 			md = p;
 			size = md->num_pages << EFI_PAGE_SHIFT;
@@ -586,9 +587,10 @@ efi_init (void)
 				unit = "KB";
 			}
 
-			printk("mem%02d: type=%2u, attr=0x%016lx, "
+			printk("mem%02d: %s "
 			       "range=[0x%016lx-0x%016lx) (%4lu%s)\n",
-			       i, md->type, md->attribute, md->phys_addr,
+			       i, efi_md_typeattr_format(buf, sizeof(buf), md),
+			       md->phys_addr,
 			       md->phys_addr + efi_md_size(md), size, unit);
 		}
 	}
-- 
1.8.3.1


