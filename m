From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 16 Feb 2005 16:37:35 +0000
Subject: [PATCH] remove unused sn header files
Message-Id: <200502160837.35981.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Pb3ECD4UoF/qRf8"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_Pb3ECD4UoF/qRf8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch makes Jes' patch (which also contains the removal of fetchop.h) a 
bit smaller, and removes two other unused files at the same time, sndrv.h and 
sn_fru.h.

 fetchop.h |   85 ------------------------------------------------------------
 sn_fru.h  |   44 --------------------------------
 sndrv.h   |   47 ----------------------------------
 3 files changed, 176 deletions(-)

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_Pb3ECD4UoF/qRf8
Content-Type: text/plain;
  charset="us-ascii";
  name="remove-unused-headers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="remove-unused-headers.patch"

diff -Nru a/include/asm-ia64/sn/fetchop.h b/include/asm-ia64/sn/fetchop.h
--- a/include/asm-ia64/sn/fetchop.h	2005-02-16 08:35:45 -08:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,85 +0,0 @@
-/*
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
- */
-
-#ifndef _ASM_IA64_SN_FETCHOP_H
-#define _ASM_IA64_SN_FETCHOP_H
-
-#include <linux/config.h>
-
-#define FETCHOP_BASENAME	"sgi_fetchop"
-#define FETCHOP_FULLNAME	"/dev/sgi_fetchop"
-
-
-
-#define FETCHOP_VAR_SIZE 64 /* 64 byte per fetchop variable */
-
-#define FETCHOP_LOAD		0
-#define FETCHOP_INCREMENT	8
-#define FETCHOP_DECREMENT	16
-#define FETCHOP_CLEAR		24
-
-#define FETCHOP_STORE		0
-#define FETCHOP_AND		24
-#define FETCHOP_OR		32
-
-#define FETCHOP_CLEAR_CACHE	56
-
-#define FETCHOP_LOAD_OP(addr, op) ( \
-         *(volatile long *)((char*) (addr) + (op)))
-
-#define FETCHOP_STORE_OP(addr, op, x) ( \
-         *(volatile long *)((char*) (addr) + (op)) = (long) (x))
-
-#ifdef __KERNEL__
-
-/*
- * Convert a region 6 (kaddr) address to the address of the fetchop variable
- */
-#define FETCHOP_KADDR_TO_MSPEC_ADDR(kaddr)	TO_MSPEC(kaddr)
-
-
-/*
- * Each Atomic Memory Operation (AMO formerly known as fetchop)
- * variable is 64 bytes long.  The first 8 bytes are used.  The
- * remaining 56 bytes are unaddressable due to the operation taking
- * that portion of the address.
- * 
- * NOTE: The AMO_t _MUST_ be placed in either the first or second half
- * of the cache line.  The cache line _MUST NOT_ be used for anything
- * other than additional AMO_t entries.  This is because there are two
- * addresses which reference the same physical cache line.  One will
- * be a cached entry with the memory type bits all set.  This address
- * may be loaded into processor cache.  The AMO_t will be referenced
- * uncached via the memory special memory type.  If any portion of the
- * cached cache-line is modified, when that line is flushed, it will
- * overwrite the uncached value in physical memory and lead to
- * inconsistency.
- */
-typedef struct {
-        u64 variable;
-        u64 unused[7];
-} AMO_t;
-
-
-/*
- * The following APIs are externalized to the kernel to allocate/free pages of
- * fetchop variables.
- *	fetchop_kalloc_page	- Allocate/initialize 1 fetchop page on the
- *				  specified cnode. 
- *	fetchop_kfree_page	- Free a previously allocated fetchop page
- */
-
-unsigned long fetchop_kalloc_page(int nid);
-void fetchop_kfree_page(unsigned long maddr);
-
-
-#endif /* __KERNEL__ */
-
-#endif /* _ASM_IA64_SN_FETCHOP_H */
-
diff -Nru a/include/asm-ia64/sn/sn_fru.h b/include/asm-ia64/sn/sn_fru.h
--- a/include/asm-ia64/sn/sn_fru.h	2005-02-16 08:35:45 -08:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,44 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992-1997,1999-2004 Silicon Graphics, Inc. All rights reserved.
- */
-#ifndef _ASM_IA64_SN_SN_FRU_H
-#define _ASM_IA64_SN_SN_FRU_H
-
-#define MAX_DIMMS			8	 /* max # of dimm banks */
-#define MAX_PCIDEV			8	 /* max # of pci devices on a pci bus */
-
-typedef unsigned char confidence_t;
-
-typedef struct kf_mem_s {
-	confidence_t km_confidence; /* confidence level that the memory is bad
-				     * is this necessary ?
-				     */
-	confidence_t km_dimm[MAX_DIMMS];
-				    /* confidence level that dimm[i] is bad
-				     *I think this is the right number
-				     */
-
-} kf_mem_t;
-
-typedef struct kf_cpu_s {
-	confidence_t	kc_confidence; /* confidence level that cpu is bad */
-	confidence_t	kc_icache; /* confidence level that instr. cache is bad */
-	confidence_t	kc_dcache; /* confidence level that data   cache is bad */
-	confidence_t	kc_scache; /* confidence level that sec.   cache is bad */
-	confidence_t	kc_sysbus; /* confidence level that sysad/cmd/state bus is bad */
-} kf_cpu_t;
-
-
-typedef struct kf_pci_bus_s {
-	confidence_t	kpb_belief;	/* confidence level  that the  pci bus is bad */
-	confidence_t	kpb_pcidev_belief[MAX_PCIDEV];
-					/* confidence level that the pci dev is bad */
-} kf_pci_bus_t;
-
-
-#endif /* _ASM_IA64_SN_SN_FRU_H */
-
diff -Nru a/include/asm-ia64/sn/sndrv.h b/include/asm-ia64/sn/sndrv.h
--- a/include/asm-ia64/sn/sndrv.h	2005-02-16 08:35:45 -08:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,47 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2002-2004 Silicon Graphics, Inc.  All Rights Reserved.
- */
-
-#ifndef _ASM_IA64_SN_SNDRV_H
-#define _ASM_IA64_SN_SNDRV_H
-
-/* ioctl commands */
-#define SNDRV_GET_ROUTERINFO		1
-#define SNDRV_GET_INFOSIZE		2
-#define SNDRV_GET_HUBINFO		3
-#define SNDRV_GET_FLASHLOGSIZE		4
-#define SNDRV_SET_FLASHSYNC		5
-#define SNDRV_GET_FLASHLOGDATA		6
-#define SNDRV_GET_FLASHLOGALL		7
-
-#define SNDRV_SET_HISTOGRAM_TYPE	14
-
-#define SNDRV_ELSC_COMMAND		19
-#define	SNDRV_CLEAR_LOG			20
-#define	SNDRV_INIT_LOG			21
-#define	SNDRV_GET_PIMM_PSC		22
-#define SNDRV_SET_PARTITION		23
-#define SNDRV_GET_PARTITION		24
-
-/* see synergy_perf_ioctl() */
-#define SNDRV_GET_SYNERGY_VERSION	30
-#define SNDRV_GET_SYNERGY_STATUS	31
-#define SNDRV_GET_SYNERGYINFO		32
-#define SNDRV_SYNERGY_APPEND		33
-#define SNDRV_SYNERGY_ENABLE		34
-#define SNDRV_SYNERGY_FREQ		35
-
-/* Devices */
-#define SNDRV_UKNOWN_DEVICE		-1
-#define SNDRV_ROUTER_DEVICE		1
-#define SNDRV_HUB_DEVICE		2
-#define SNDRV_ELSC_NVRAM_DEVICE		3
-#define SNDRV_ELSC_CONTROLLER_DEVICE	4
-#define SNDRV_SYSCTL_SUBCH		5
-#define SNDRV_SYNERGY_DEVICE		6
-
-#endif /* _ASM_IA64_SN_SNDRV_H */

--Boundary-00=_Pb3ECD4UoF/qRf8--
