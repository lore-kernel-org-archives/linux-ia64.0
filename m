From: Ishimatsu Yasuaki <isimatu.yasuaki@jp.fujitsu.com>
Date: Wed, 09 May 2007 07:57:54 +0000
Subject: [PATCH 12/12] Enable percpu vector domain for IA64_DIG
Message-Id: <46417F02.8090609@jp.fujitsu.com>
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

Index: linux-2.6.21/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/irq_ia64.c	2007-05-08 12:14:11.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/irq_ia64.c	2007-05-08 12:14:39.000000000 +0900
@@ -227,7 +227,7 @@
 	}
 }

-#if defined(CONFIG_IA64_GENERIC)
+#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG)
 static enum vector_domain_type {
 	VECTOR_DOMAIN_NONE,
 	VECTOR_DOMAIN_PERCPU




