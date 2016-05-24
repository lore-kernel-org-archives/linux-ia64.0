From: David Daney <ddaney.cavm@gmail.com>
Date: Tue, 24 May 2016 22:35:33 +0000
Subject: [PATCH v7 03/15] acpi, numa: remove duplicate NULL check
Message-Id: <1464129345-18985-4-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

From: Hanjun Guo <hanjun.guo@linaro.org>

The argument "header" for acpi_table_print_srat_entry()
is always checked before the function is called, it's
duplicate to check it again, remove it.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/acpi/numa.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index a089c39..6f1cad8 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -125,9 +125,6 @@ EXPORT_SYMBOL(acpi_map_pxm_to_online_node);
 static void __init
 acpi_table_print_srat_entry(struct acpi_subtable_header *header)
 {
-	if (!header)
-		return;
-
 	switch (header->type) {
 	case ACPI_SRAT_TYPE_CPU_AFFINITY:
 		{
-- 
1.7.11.7

