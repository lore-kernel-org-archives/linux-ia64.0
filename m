From: Christoph Hellwig <hch@lst.de>
Date: Tue, 13 Aug 2019 07:25:07 +0000
Subject: [PATCH 21/28] ia64: remove the SGI UV simulator support
Message-Id: <20190813072514.23299-22-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190813072514.23299-1-hch@lst.de>
In-Reply-To: <20190813072514.23299-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Mike Travis <mike.travis@hpe.com>, Dimitri Sivanich <sivanich@hpe.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org

The simulator support was marked as temporary since the initial commit,
so drop it more than 10 years later.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/include/asm/sn/simulator.h | 25 ----------------------
 arch/ia64/include/asm/sn/sn_sal.h    | 10 ---------
 arch/ia64/include/asm/uv/uv.h        |  4 +---
 arch/ia64/uv/kernel/setup.c          | 31 +++++-----------------------
 4 files changed, 6 insertions(+), 64 deletions(-)
 delete mode 100644 arch/ia64/include/asm/sn/simulator.h

diff --git a/arch/ia64/include/asm/sn/simulator.h b/arch/ia64/include/asm/sn/simulator.h
deleted file mode 100644
index 3e4557df3b7c..000000000000
--- a/arch/ia64/include/asm/sn/simulator.h
+++ /dev/null
@@ -1,25 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
- */
-
-#ifndef _ASM_IA64_SN_SIMULATOR_H
-#define _ASM_IA64_SN_SIMULATOR_H
-
-#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_UV)
-#define SNMAGIC 0xaeeeeeee8badbeefL
-#define IS_MEDUSA()			({long sn; asm("mov %0=cpuid[%1]" : "=r"(sn) : "r"(2)); sn = SNMAGIC;})
-
-#define SIMULATOR_SLEEP()		asm("nop.i 0x8beef")
-#define IS_RUNNING_ON_SIMULATOR()	(sn_prom_type)
-#define IS_RUNNING_ON_FAKE_PROM()	(sn_prom_type = 2)
-extern int sn_prom_type;		/* 0=hardware, 1=medusa/realprom, 2=medusa/fakeprom */
-#else
-#define IS_MEDUSA()			0
-#define SIMULATOR_SLEEP()
-#define IS_RUNNING_ON_SIMULATOR()	0
-#endif
-
-#endif /* _ASM_IA64_SN_SIMULATOR_H */
diff --git a/arch/ia64/include/asm/sn/sn_sal.h b/arch/ia64/include/asm/sn/sn_sal.h
index 48b88d0807db..d437aa43343b 100644
--- a/arch/ia64/include/asm/sn/sn_sal.h
+++ b/arch/ia64/include/asm/sn/sn_sal.h
@@ -30,8 +30,6 @@
 #define SALRET_INVALID_ARG	(-2)
 #define SALRET_ERROR		(-3)
 
-#define SN_SAL_FAKE_PROM			   0x02009999
-
 /*
  * Returns the physical address of the partition's reserved page through
  * an iterative number of calls.
@@ -81,14 +79,6 @@ sn_change_memprotect(u64 paddr, u64 len, u64 perms, u64 *nasid_array)
 #define SN_MEMPROT_ACCESS_CLASS_6		0x084080
 #define SN_MEMPROT_ACCESS_CLASS_7		0x021080
 
-static inline int
-ia64_sn_is_fake_prom(void)
-{
-	struct ia64_sal_retval rv;
-	SAL_CALL_NOLOCK(rv, SN_SAL_FAKE_PROM, 0, 0, 0, 0, 0, 0, 0);
-	return (rv.status = 0);
-}
-
 union sn_watchlist_u {
 	u64     val;
 	struct {
diff --git a/arch/ia64/include/asm/uv/uv.h b/arch/ia64/include/asm/uv/uv.h
index 71df93ee3bc0..502cf1c56369 100644
--- a/arch/ia64/include/asm/uv/uv.h
+++ b/arch/ia64/include/asm/uv/uv.h
@@ -2,12 +2,10 @@
 #ifndef _ASM_IA64_UV_UV_H
 #define _ASM_IA64_UV_UV_H
 
-#include <asm/sn/simulator.h>
-
 static inline int is_uv_system(void)
 {
 	/* temporary support for running on hardware simulator */
-	return IS_MEDUSA() || ia64_platform_is("uv");
+	return ia64_platform_is("uv");
 }
 
 #endif	/* _ASM_IA64_UV_UV_H */
diff --git a/arch/ia64/uv/kernel/setup.c b/arch/ia64/uv/kernel/setup.c
index 11478d2d863d..6ac4bd314d92 100644
--- a/arch/ia64/uv/kernel/setup.c
+++ b/arch/ia64/uv/kernel/setup.c
@@ -10,14 +10,12 @@
 
 #include <linux/module.h>
 #include <linux/percpu.h>
-#include <asm/sn/simulator.h>
 #include <asm/uv/uv_mmrs.h>
 #include <asm/uv/uv_hub.h>
 
 DEFINE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
 EXPORT_PER_CPU_SYMBOL_GPL(__uv_hub_info);
 
-int sn_prom_type;
 long sn_coherency_id;
 EXPORT_SYMBOL_GPL(sn_coherency_id);
 
@@ -60,30 +58,11 @@ void __init uv_setup(char **cmdline_p)
 	int nid, cpu, m_val, n_val;
 	unsigned long mmr_base, lowmem_redir_base, lowmem_redir_size;
 
-	if (IS_MEDUSA()) {
-		lowmem_redir_base = 0;
-		lowmem_redir_size = 0;
-		node_id.v = 0;
-		m_n_config.s.m_skt = 37;
-		m_n_config.s.n_skt = 0;
-		mmr_base = 0;
-#if 0
-		/* Need BIOS calls - TDB */
-		if (!ia64_sn_is_fake_prom())
-			sn_prom_type = 1;
-		else
-#endif
-			sn_prom_type = 2;
-		printk(KERN_INFO "Running on medusa with %s PROM\n",
-					(sn_prom_type = 1) ? "real" : "fake");
-	} else {
-		get_lowmem_redirect(&lowmem_redir_base, &lowmem_redir_size);
-		node_id.v = uv_read_local_mmr(UVH_NODE_ID);
-		m_n_config.v = uv_read_local_mmr(UVH_SI_ADDR_MAP_CONFIG);
-		mmr_base -			uv_read_local_mmr(UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR) &
-				~UV_MMR_ENABLE;
-	}
+	get_lowmem_redirect(&lowmem_redir_base, &lowmem_redir_size);
+	node_id.v = uv_read_local_mmr(UVH_NODE_ID);
+	m_n_config.v = uv_read_local_mmr(UVH_SI_ADDR_MAP_CONFIG);
+	mmr_base = uv_read_local_mmr(UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR) &
+			~UV_MMR_ENABLE;
 
 	m_val = m_n_config.s.m_skt;
 	n_val = m_n_config.s.n_skt;
-- 
2.20.1
