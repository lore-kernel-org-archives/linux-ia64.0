From: Al Stone <al.stone@linaro.org>
Date: Wed, 09 Sep 2015 21:09:51 +0000
Subject: [PATCH v3 5/5] ACPI: remove definition of BAD_MADT_ENTRY macro
Message-Id: <1441832991-28200-6-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1441832991-28200-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1441832991-28200-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Al Stone <al.stone@linaro.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>

Now that we have introduced to bad_madt_entry(), and we have removed
all the usages of the BAD_MADT_ENTRY macro from all of the various
architectures that use it (arm64, ia64, x86), we can remove the macro
definition since it is no longer used.

Signed-off-by: Al Stone <al.stone@linaro.org>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
---
 include/linux/acpi.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 7235c48..a6d6326 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -127,10 +127,6 @@ static inline void acpi_initrd_override(void *data, size_t size)
 }
 #endif
 
-#define BAD_MADT_ENTRY(entry, end) (					    \
-		(!entry) || (unsigned long)entry + sizeof(*entry) > end ||  \
-		((struct acpi_subtable_header *)entry)->length < sizeof(*entry))
-
 char * __acpi_map_table (unsigned long phys_addr, unsigned long size);
 void __acpi_unmap_table(char *map, unsigned long size);
 int early_acpi_boot_init(void);
-- 
2.4.3

