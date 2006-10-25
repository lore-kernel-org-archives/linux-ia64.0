From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 25 Oct 2006 04:40:25 +0000
Subject: [Patch] IA64 Kdump don't clear vector in kexec_disable_iosapic
Message-Id: <1161751225.2592.20.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony,
	This patch is from Naoaki-san.
	Mask IOSAPIC will make the following EOI write to IOSAPIC fail because
IOSAPIC will not be able to find RTE entry.
        However move EOI write before IOSAPIC mask will leave a small
racy windows between them for interrupts. So mask IOSAPIC but leave the
vector field.

	The patch is against your test tree.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
       
--- linux-2.6/arch/ia64/kernel/iosapic.c	2006-10-25 14:37:30.000000000 +0800
+++ b/arch/ia64/kernel/iosapic.c	2006-10-25 14:41:34.000000000 +0800
@@ -303,7 +303,7 @@ kexec_disable_iosapic(void)
 				rte_list) {
 			iosapic_write(rte->addr,
 					IOSAPIC_RTE_LOW(rte->rte_index),
-					IOSAPIC_MASK);
+					IOSAPIC_MASK|vec);
 			iosapic_eoi(rte->addr, vec);
 		}
 	}

