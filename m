From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 29 Jun 2007 22:30:50 +0000
Subject: RE: [RFC][PATCH take2 0/13] Support vector domain on ia64
Message-Id: <617E1C2C70743745A92448908E030B2A01D0A74A@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46779036.5050602@jp.fujitsu.com>
In-Reply-To: <46779036.5050602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> arch/ia64/kernel/irq_ia64.c: In function `parse_vector_domain':
> arch/ia64/kernel/irq_ia64.c:270: error: `no_int_routing' undeclared (first use in this function)

Fix for this is just:

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 8efb6e1..91abd1b 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -248,7 +248,7 @@ void __setup_vector_irq(int cpu)
 	}
 }
 
-#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG)
+#if defined(CONFIG_SMP) && (defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG))
 static enum vector_domain_type {
 	VECTOR_DOMAIN_NONE,
 	VECTOR_DOMAIN_PERCPU


-Tony
