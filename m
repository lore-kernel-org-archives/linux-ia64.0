From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 12:23:03 +0000
Subject: [PATCH take3 12/12] Enable percpu vector domain for IA64_DIG
Message-Id: <469CB4A7.8080004@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add per-CPU vector domain support for IA64_DIG. It is enabled by
adding the "vector=percpu" boot option.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

 arch/ia64/kernel/irq_ia64.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.22/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/irq_ia64.c	2007-07-17 12:10:37.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/irq_ia64.c	2007-07-17 12:10:44.000000000 +0900
@@ -267,7 +267,7 @@ void __setup_vector_irq(int cpu)
 	}
 }

-#if defined(CONFIG_IA64_GENERIC)
+#if defined(CONFIG_SMP) && (defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG))
 static enum vector_domain_type {
 	VECTOR_DOMAIN_NONE,
 	VECTOR_DOMAIN_PERCPU
