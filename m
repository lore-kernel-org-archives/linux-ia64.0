From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:18:19 +0000
Subject: [PATCH take2 12/13] Enable percpu vector domain for IA64_DIG
Message-Id: <4677914B.7020501@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add per-CPU vector domain support for IA64_DIG. It is enabled by
adding the "vector=percpu" boot option.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:50.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:52.000000000 +0900
@@ -227,7 +227,7 @@ void __setup_vector_irq(int cpu)
 	}
 }

-#if defined(CONFIG_IA64_GENERIC)
+#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG)
 static enum vector_domain_type {
 	VECTOR_DOMAIN_NONE,
 	VECTOR_DOMAIN_PERCPU

