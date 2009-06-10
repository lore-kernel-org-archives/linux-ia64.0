From: akpm@linux-foundation.org
Date: Wed, 10 Jun 2009 19:45:01 +0000
Subject: [patch 4/4] ia64: msi_ia64.c dmar_msi_type should be static
Message-Id: <200906101945.n5AJj1FH032313@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Jaswinder Singh Rajput <jaswinder@kernel.org>

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/msi_ia64.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/kernel/msi_ia64.c~ia64-msi_ia64c-dmar_msi_type-should-be-static arch/ia64/kernel/msi_ia64.c
--- a/arch/ia64/kernel/msi_ia64.c~ia64-msi_ia64c-dmar_msi_type-should-be-static
+++ a/arch/ia64/kernel/msi_ia64.c
@@ -158,7 +158,7 @@ static int dmar_msi_set_affinity(unsigne
 }
 #endif /* CONFIG_SMP */
 
-struct irq_chip dmar_msi_type = {
+static struct irq_chip dmar_msi_type = {
 	.name = "DMAR_MSI",
 	.unmask = dmar_msi_unmask,
 	.mask = dmar_msi_mask,
_
