From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 13 May 2005 00:46:09 +0000
Subject: [PATCH 6/6]: hotplug/ia64: SN Hotplug Driver - PREEMPT/pcibus_info fix
Message-Id: <20050513004606.17135.94818.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42835EC0.5030409@sgi.com>
In-Reply-To: <42835EC0.5030409@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes an issue with the PROM and a kernel running with
CONFIG_PREEMPT enabled.  When CONFIG_PREEMPT is enabled, the size of a
spinlock_t changes -- resulting in the PROM writing to an incorrect location.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit 504a8031fc066492285640128780f152e91a05ff
tree 0b3875eb291c83888838c40fe54869d58d0f9f61
parent b37f84886e06a5892a02a0906e8b3f2d51daf1d2
author Prarit Bhargava <prarit@sgi.com> 1810126687 -0400
committer Prarit Bhargava <prarit@sgi.com> 1810126687 -0400

Index: include/asm-ia64/sn/pcibr_provider.h
=================================--- d42322aa13214a5d099019ff0406dfb328960b98/include/asm-ia64/sn/pcibr_provider.h  (mode:100644 sha1:c1bf22505ff339ea7a5255ec9a8a60031397e9a8)
+++ 0b3875eb291c83888838c40fe54869d58d0f9f61/include/asm-ia64/sn/pcibr_provider.h  (mode:100644 sha1:e6430a26fcfae1ceefd447d1b30e3e453a6b93d4)
@@ -108,10 +108,11 @@
 	char                    pbi_hub_xid;
 
 	uint64_t                pbi_devreg[8];
-	spinlock_t              pbi_lock;
 
 	uint32_t		pbi_valid_devices;
 	uint32_t		pbi_enabled_devices;
+
+	spinlock_t              pbi_lock;
 };
 
 /*
