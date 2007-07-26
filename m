From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 26 Jul 2007 06:32:38 +0000
Subject: [PATCH 3/3] Fix wrong return value in parse_vector_domain
Message-Id: <1185431558.3917.71.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix wrong return value in parse_vector_domain().

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
@@ -289,7 +289,7 @@ static int __init parse_vector_domain(ch
 		vector_domain_type = VECTOR_DOMAIN_PERCPU;
 		no_int_routing = 1;
 	}
-	return 1;
+	return 0;
 }
 early_param("vector", parse_vector_domain);
 #else


