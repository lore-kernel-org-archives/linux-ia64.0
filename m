From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 17 Sep 2003 13:31:57 +0000
Subject: [patch] include/asm-ia64/sn/router.h cleanup
Message-Id: <marc-linux-ia64-106380556207323@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

Minor cleanup of $Subject.

Cheers,
Jes

--- /usr/tmp/TmpDir.5666-0/linux/include/asm-ia64/sn/router.h_1.5	Wed Sep 17 06:24:43 2003
+++ linux/include/asm-ia64/sn/router.h	Wed Sep 17 06:16:17 2003
@@ -1,5 +1,4 @@
-
-/* $Id$
+/* $id$
  *
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
@@ -19,7 +18,6 @@
 
 #ifndef __ASSEMBLY__
 
-#include <linux/devfs_fs_kernel.h>
 #include <asm/sn/vector.h>
 #include <asm/sn/slotnum.h>
 #include <asm/sn/arch.h>
@@ -31,23 +29,19 @@
 #define MAX_ROUTER_PATH	80
 
 #define ROUTER_REG_CAST		(volatile router_reg_t *)
-#define PS_UINT_CAST		(__psunsigned_t)
-#define UINT64_CAST		(uint64_t)
 typedef signed char port_no_t;	 /* Type for router port number      */
 
 #else 
 
 #define ROUTERREG_CAST
-#define PS_UINT_CAST
-#define UINT64_CAST
 
 #endif /* __ASSEMBLY__ */
 
-#define MAX_ROUTER_PORTS (8)	 /* Max. number of ports on a router */
+#define MAX_ROUTER_PORTS	8	/* Max. number of ports on a router */
 
 #define ALL_PORTS ((1 << MAX_ROUTER_PORTS) - 1)	/* for 0 based references */
 
-#define PORT_INVALID (-1)	 /* Invalid port number              */
+#define PORT_INVALID		-1	/* Invalid port number              */
 
 #define	IS_META(_rp)	((_rp)->flags & PCFG_ROUTER_META)
 
@@ -126,24 +120,24 @@
  */
 
 #define RSRI_INPORT_SHFT	52
-#define RSRI_INPORT_MASK	(UINT64_CAST 0xf << 52)
+#define RSRI_INPORT_MASK	(0xfUL << 52)
 #define RSRI_LINKWORKING_BIT(_L) (35 + 2 * (_L))
-#define RSRI_LINKWORKING(_L)	(UINT64_CAST 1 << (35 + 2 * (_L)))
-#define RSRI_LINKRESETFAIL(_L)	(UINT64_CAST 1 << (34 + 2 * (_L)))
+#define RSRI_LINKWORKING(_L)	(1UL << (35 + 2 * (_L)))
+#define RSRI_LINKRESETFAIL(_L)	(1UL << (34 + 2 * (_L)))
 #define RSRI_LSTAT_SHFT(_L)	(34 + 2 * (_L))
-#define RSRI_LSTAT_MASK(_L)	(UINT64_CAST 0x3 << 34 + 2 * (_L))
-#define RSRI_LOCALSBERROR	(UINT64_CAST 1 << 35)
-#define RSRI_LOCALSTUCK		(UINT64_CAST 1 << 34)
-#define RSRI_LOCALBADVEC	(UINT64_CAST 1 << 33)
-#define RSRI_LOCALTAILERR	(UINT64_CAST 1 << 32)
+#define RSRI_LSTAT_MASK(_L)	(0x3UL << 34 + 2 * (_L))
+#define RSRI_LOCALSBERROR	(1UL << 35)
+#define RSRI_LOCALSTUCK		(1UL << 34)
+#define RSRI_LOCALBADVEC	(1UL << 33)
+#define RSRI_LOCALTAILERR	(1UL << 32)
 #define RSRI_LOCAL_SHFT 	32
-#define RSRI_LOCAL_MASK		(UINT64_CAST 0xf << 32)
+#define RSRI_LOCAL_MASK		(0xfUL << 32)
 #define RSRI_CHIPREV_SHFT	28
-#define RSRI_CHIPREV_MASK	(UINT64_CAST 0xf << 28)
+#define RSRI_CHIPREV_MASK	(0xfUL << 28)
 #define RSRI_CHIPID_SHFT	12
-#define RSRI_CHIPID_MASK	(UINT64_CAST 0xffff << 12)
+#define RSRI_CHIPID_MASK	(0xffffUL << 12)
 #define RSRI_MFGID_SHFT		1
-#define RSRI_MFGID_MASK		(UINT64_CAST 0x7ff << 1)
+#define RSRI_MFGID_MASK		(0x7ffUL << 1)
 
 #define RSRI_LSTAT_WENTDOWN	0
 #define RSRI_LSTAT_RESETFAIL	1
@@ -154,38 +148,38 @@
  * RR_PORT_RESET mask definitions
  */
 
-#define RPRESET_WARM		(UINT64_CAST 1 << 9)
-#define RPRESET_LINK(_L)	(UINT64_CAST 1 << (_L))
-#define RPRESET_LOCAL		(UINT64_CAST 1)
+#define RPRESET_WARM		(1UL << 9)
+#define RPRESET_LINK(_L)	(1UL << (_L))
+#define RPRESET_LOCAL		1UL
 
 /*
  * RR_PROT_CONF mask and shift definitions
  */
 
 #define RPCONF_DIRCMPDIS_SHFT	13
-#define RPCONF_DIRCMPDIS_MASK	(UINT64_CAST 1 << 13)
-#define RPCONF_FORCELOCAL	(UINT64_CAST 1 << 12)
+#define RPCONF_DIRCMPDIS_MASK	(1UL << 13)
+#define RPCONF_FORCELOCAL	(1UL << 12)
 #define RPCONF_FLOCAL_SHFT	12
 #define RPCONF_METAID_SHFT	8
-#define RPCONF_METAID_MASK	(UINT64_CAST 0xf << 8)
-#define RPCONF_RESETOK(_L)	(UINT64_CAST 1 << ((_L) - 1))
+#define RPCONF_METAID_MASK	(0xfUL << 8)
+#define RPCONF_RESETOK(_L)	(1UL << ((_L) - 1))
 
 /*
  * RR_GLOBAL_PORT_DEF mask and shift definitions
  */
 
 #define RGPD_MGLBLNHBR_ID_SHFT	12	/* -global neighbor ID */
-#define RGPD_MGLBLNHBR_ID_MASK	(UINT64_CAST 0xf << 12)
+#define RGPD_MGLBLNHBR_ID_MASK	(0xfUL << 12)
 #define RGPD_MGLBLNHBR_VLD_SHFT	11	/* -global neighbor Valid */
-#define RGPD_MGLBLNHBR_VLD_MASK	(UINT64_CAST 0x1 << 11)
+#define RGPD_MGLBLNHBR_VLD_MASK	(0x1UL << 11)
 #define RGPD_MGLBLPORT_SHFT	8	/* -global neighbor Port */
-#define RGPD_MGLBLPORT_MASK	(UINT64_CAST 0x7 << 8)
+#define RGPD_MGLBLPORT_MASK	(0x7UL << 8)
 #define RGPD_PGLBLNHBR_ID_SHFT	4	/* +global neighbor ID */
-#define RGPD_PGLBLNHBR_ID_MASK	(UINT64_CAST 0xf << 4)
+#define RGPD_PGLBLNHBR_ID_MASK	(0xfUL << 4)
 #define RGPD_PGLBLNHBR_VLD_SHFT	3	/* +global neighbor Valid */
-#define RGPD_PGLBLNHBR_VLD_MASK	(UINT64_CAST 0x1 << 3)
+#define RGPD_PGLBLNHBR_VLD_MASK	(0x1UL << 3)
 #define RGPD_PGLBLPORT_SHFT	0	/* +global neighbor Port */
-#define RGPD_PGLBLPORT_MASK	(UINT64_CAST 0x7 << 0)
+#define RGPD_PGLBLPORT_MASK	(0x7UL << 0)
 
 #define GLBL_PARMS_REGS		2	/* Two Global Parms registers */
 
@@ -194,95 +188,95 @@
  */
 
 #define RGPARM0_ARB_VALUE_SHFT	54	/* Local Block Arbitration State */
-#define RGPARM0_ARB_VALUE_MASK	(UINT64_CAST 0x7 << 54)
+#define RGPARM0_ARB_VALUE_MASK	(0x7UL << 54)
 #define RGPARM0_ROTATEARB_SHFT	53	/* Rotate Local Block Arbitration */
-#define RGPARM0_ROTATEARB_MASK	(UINT64_CAST 0x1 << 53)
+#define RGPARM0_ROTATEARB_MASK	(1UL << 53)
 #define RGPARM0_FAIREN_SHFT	52	/* Fairness logic Enable */
-#define RGPARM0_FAIREN_MASK	(UINT64_CAST 0x1 << 52)
+#define RGPARM0_FAIREN_MASK	(1UL << 52)
 #define RGPARM0_LOCGNTTO_SHFT	40	/* Local grant timeout */
-#define RGPARM0_LOCGNTTO_MASK	(UINT64_CAST 0xfff << 40)
+#define RGPARM0_LOCGNTTO_MASK	(0xfffUL << 40)
 #define RGPARM0_DATELINE_SHFT	38	/* Dateline crossing router */
-#define RGPARM0_DATELINE_MASK	(UINT64_CAST 0x1 << 38)
+#define RGPARM0_DATELINE_MASK	(1UL << 38)
 #define RGPARM0_MAXRETRY_SHFT	28	/* Max retry count */
-#define RGPARM0_MAXRETRY_MASK	(UINT64_CAST 0x3ff << 28)
+#define RGPARM0_MAXRETRY_MASK	(0x3ffUL << 28)
 #define RGPARM0_URGWRAP_SHFT	20	/* Urgent wrap */
-#define RGPARM0_URGWRAP_MASK	(UINT64_CAST 0xff << 20)
+#define RGPARM0_URGWRAP_MASK	(0xffUL << 20)
 #define RGPARM0_DEADLKTO_SHFT	16	/* Deadlock timeout */
-#define RGPARM0_DEADLKTO_MASK	(UINT64_CAST 0xf << 16)
+#define RGPARM0_DEADLKTO_MASK	(0xfUL << 16)
 #define RGPARM0_URGVAL_SHFT	12	/* Urgent value */
-#define RGPARM0_URGVAL_MASK	(UINT64_CAST 0xf << 12)
+#define RGPARM0_URGVAL_MASK	(0xfUL << 12)
 #define RGPARM0_VCHSELEN_SHFT	11	/* VCH_SEL_EN */
-#define RGPARM0_VCHSELEN_MASK	(UINT64_CAST 0x1 << 11)
+#define RGPARM0_VCHSELEN_MASK	(1UL << 11)
 #define RGPARM0_LOCURGTO_SHFT	9	/* Local urgent timeout */
-#define RGPARM0_LOCURGTO_MASK	(UINT64_CAST 0x3 << 9)
+#define RGPARM0_LOCURGTO_MASK	(0x3UL << 9)
 #define RGPARM0_TAILVAL_SHFT	5	/* Tail value */
-#define RGPARM0_TAILVAL_MASK	(UINT64_CAST 0xf << 5)
+#define RGPARM0_TAILVAL_MASK	(0xfUL << 5)
 #define RGPARM0_CLOCK_SHFT	1	/* Global clock select */
-#define RGPARM0_CLOCK_MASK	(UINT64_CAST 0xf << 1)
+#define RGPARM0_CLOCK_MASK	(0xfUL << 1)
 #define RGPARM0_BYPEN_SHFT	0
-#define RGPARM0_BYPEN_MASK	(UINT64_CAST 1)	/* Bypass enable */
+#define RGPARM0_BYPEN_MASK	1UL	/* Bypass enable */
 
 /*
  * RR_GLOBAL_PARMS1 shift and mask definitions
  */
 
 #define RGPARM1_TTOWRAP_SHFT	12	/* Tail timeout wrap */
-#define RGPARM1_TTOWRAP_MASK	(UINT64_CAST 0xfffff << 12)
+#define RGPARM1_TTOWRAP_MASK	(0xfffffUL << 12)
 #define RGPARM1_AGERATE_SHFT	8	/* Age rate */
-#define RGPARM1_AGERATE_MASK	(UINT64_CAST 0xf << 8)
+#define RGPARM1_AGERATE_MASK	(0xfUL << 8)
 #define RGPARM1_JSWSTAT_SHFT	0	/* JTAG Sw Register bits */
-#define RGPARM1_JSWSTAT_MASK	(UINT64_CAST 0xff << 0)
+#define RGPARM1_JSWSTAT_MASK	(0xffUL << 0)
 
 /*
  * RR_DIAG_PARMS mask and shift definitions
  */
 
-#define RDPARM_ABSHISTOGRAM	(UINT64_CAST 1 << 17)	/* Absolute histgrm */
-#define RDPARM_DEADLOCKRESET	(UINT64_CAST 1 << 16)	/* Reset on deadlck */
-#define RDPARM_DISABLE(_L)	(UINT64_CAST 1 << ((_L) +  7))
-#define RDPARM_SENDERROR(_L)	(UINT64_CAST 1 << ((_L) -  1))
+#define RDPARM_ABSHISTOGRAM	(1UL << 17)	/* Absolute histgrm */
+#define RDPARM_DEADLOCKRESET	(1UL << 16)	/* Reset on deadlck */
+#define RDPARM_DISABLE(_L)	(1UL << ((_L) +  7))
+#define RDPARM_SENDERROR(_L)	(1UL << ((_L) -  1))
 
 /*
  * RR_DEBUG_ADDR mask and shift definitions
  */
 
 #define RDA_DATA_SHFT		10	/* Observed debug data */
-#define RDA_DATA_MASK		(UINT64_CAST 0xffff << 10)
+#define RDA_DATA_MASK		(0xffffUL << 10)
 #define RDA_ADDR_SHFT		0	/* debug address for data */
-#define RDA_ADDR_MASK		(UINT64_CAST 0x3ff << 0)
+#define RDA_ADDR_MASK		(0x3ffUL << 0)
 
 /*
  * RR_LB_TO_L2 mask and shift definitions
  */
 
 #define RLBTOL2_DATA_VLD_SHFT	32	/* data is valid for JTAG controller */
-#define RLBTOL2_DATA_VLD_MASK	(UINT64_CAST 0x1 << 32)
+#define RLBTOL2_DATA_VLD_MASK	(1UL << 32)
 #define RLBTOL2_DATA_SHFT	0	/* data bits for JTAG controller */
-#define RLBTOL2_DATA_MASK	(UINT64_CAST 0xffffffff)
+#define RLBTOL2_DATA_MASK	0xffffffffUL
 
 /*
  * RR_L2_TO_LB mask and shift definitions
  */
 
 #define RL2TOLB_DATA_VLD_SHFT	33	/* data is valid from JTAG controller */
-#define RL2TOLB_DATA_VLD_MASK	(UINT64_CAST 0x1 << 33)
+#define RL2TOLB_DATA_VLD_MASK	(1UL << 33)
 #define RL2TOLB_PARITY_SHFT	32	/* sw implemented parity for data */
-#define RL2TOLB_PARITY_MASK	(UINT64_CAST 0x1 << 32)
+#define RL2TOLB_PARITY_MASK	(1UL << 32)
 #define RL2TOLB_DATA_SHFT	0	/* data bits from JTAG controller */
-#define RL2TOLB_DATA_MASK	(UINT64_CAST 0xffffffff)
+#define RL2TOLB_DATA_MASK	0xffffffffUL
 
 /*
  * RR_JBUS_CONTROL mask and shift definitions
  */
 
 #define RJC_POS_BITS_SHFT	20	/* Router position bits */
-#define RJC_POS_BITS_MASK	(UINT64_CAST 0xf << 20)
+#define RJC_POS_BITS_MASK	(0xfUL << 20)
 #define RJC_RD_DATA_STROBE_SHFT	16	/* count when read data is strobed in */
-#define RJC_RD_DATA_STROBE_MASK	(UINT64_CAST 0xf << 16)
+#define RJC_RD_DATA_STROBE_MASK	(0xfUL << 16)
 #define RJC_WE_OE_HOLD_SHFT	8	/* time OE or WE is held */
-#define RJC_WE_OE_HOLD_MASK	(UINT64_CAST 0xff << 8)
+#define RJC_WE_OE_HOLD_MASK	(0xffUL << 8)
 #define RJC_ADDR_SET_HLD_SHFT	0	/* time address driven around OE/WE */
-#define RJC_ADDR_SET_HLD_MASK	(UINT64_CAST 0xff)
+#define RJC_ADDR_SET_HLD_MASK	0xffUL
 
 /*
  * RR_SCRATCH_REGx mask and shift definitions
@@ -291,58 +285,58 @@
  */
 
 #define	RSCR0_BOOTED_SHFT	63
-#define	RSCR0_BOOTED_MASK	(UINT64_CAST 0x1 << RSCR0_BOOTED_SHFT)
+#define	RSCR0_BOOTED_MASK	(0x1UL << RSCR0_BOOTED_SHFT)
 #define RSCR0_LOCALID_SHFT	56
-#define RSCR0_LOCALID_MASK	(UINT64_CAST 0x7f << RSCR0_LOCALID_SHFT)
+#define RSCR0_LOCALID_MASK	(0x7fUL << RSCR0_LOCALID_SHFT)
 #define	RSCR0_UNUSED_SHFT	48
-#define	RSCR0_UNUSED_MASK	(UINT64_CAST 0xff << RSCR0_UNUSED_SHFT)
+#define	RSCR0_UNUSED_MASK	(0xffUL << RSCR0_UNUSED_SHFT)
 #define RSCR0_NIC_SHFT		0
-#define RSCR0_NIC_MASK		(UINT64_CAST 0xffffffffffff)
+#define RSCR0_NIC_MASK		0xffffffffffffUL
 
 #define RSCR1_MODID_SHFT	0
-#define RSCR1_MODID_MASK	(UINT64_CAST 0xffff)
+#define RSCR1_MODID_MASK	0xffffUL
 
 /*
  * RR_VECTOR_HW_BAR mask and shift definitions
  */
 
 #define BAR_TX_SHFT		27	/* Barrier in trans(m)it when read */
-#define BAR_TX_MASK		(UINT64_CAST 1 << BAR_TX_SHFT)
+#define BAR_TX_MASK		(1UL << BAR_TX_SHFT)
 #define BAR_VLD_SHFT		26	/* Valid Configuration */
-#define BAR_VLD_MASK		(UINT64_CAST 1 << BAR_VLD_SHFT)
+#define BAR_VLD_MASK		(1UL << BAR_VLD_SHFT)
 #define BAR_SEQ_SHFT		24	/* Sequence number */
-#define BAR_SEQ_MASK		(UINT64_CAST 3 << BAR_SEQ_SHFT)
+#define BAR_SEQ_MASK		(3UL << BAR_SEQ_SHFT)
 #define BAR_LEAFSTATE_SHFT	18	/* Leaf State */
-#define BAR_LEAFSTATE_MASK	(UINT64_CAST 0x3f << BAR_LEAFSTATE_SHFT)
+#define BAR_LEAFSTATE_MASK	(0x3fUL << BAR_LEAFSTATE_SHFT)
 #define BAR_PARENT_SHFT		14	/* Parent Port */
-#define BAR_PARENT_MASK		(UINT64_CAST 0xf << BAR_PARENT_SHFT)
+#define BAR_PARENT_MASK		(0xfUL << BAR_PARENT_SHFT)
 #define BAR_CHILDREN_SHFT	6	/* Child Select port bits */
-#define BAR_CHILDREN_MASK	(UINT64_CAST 0xff << BAR_CHILDREN_SHFT)
+#define BAR_CHILDREN_MASK	(0xffUL << BAR_CHILDREN_SHFT)
 #define BAR_LEAFCOUNT_SHFT	0	/* Leaf Count to trigger parent */
-#define BAR_LEAFCOUNT_MASK	(UINT64_CAST 0x3f)
+#define BAR_LEAFCOUNT_MASK	0x3fUL
 
 /*
  * RR_PORT_PARMS(_L) mask and shift definitions
  */
 
 #define RPPARM_MIPRESETEN_SHFT	29	/* Message In Progress reset enable */
-#define RPPARM_MIPRESETEN_MASK	(UINT64_CAST 0x1 << 29)
+#define RPPARM_MIPRESETEN_MASK	(0x1UL << 29)
 #define RPPARM_UBAREN_SHFT	28	/* Enable user barrier requests */
-#define RPPARM_UBAREN_MASK	(UINT64_CAST 0x1 << 28)
+#define RPPARM_UBAREN_MASK	(0x1UL << 28)
 #define RPPARM_OUTPDTO_SHFT	24	/* Output Port Deadlock TO value */
-#define RPPARM_OUTPDTO_MASK	(UINT64_CAST 0xf << 24)
+#define RPPARM_OUTPDTO_MASK	(0xfUL << 24)
 #define RPPARM_PORTMATE_SHFT	21	/* Port Mate for the port */
-#define RPPARM_PORTMATE_MASK	(UINT64_CAST 0x7 << 21)
+#define RPPARM_PORTMATE_MASK	(0x7UL << 21)
 #define RPPARM_HISTEN_SHFT	20	/* Histogram counter enable */
-#define RPPARM_HISTEN_MASK	(UINT64_CAST 0x1 << 20)
+#define RPPARM_HISTEN_MASK	(0x1UL << 20)
 #define RPPARM_HISTSEL_SHFT	18
-#define RPPARM_HISTSEL_MASK	(UINT64_CAST 0x3 << 18)
+#define RPPARM_HISTSEL_MASK	(0x3UL << 18)
 #define RPPARM_DAMQHS_SHFT	16
-#define RPPARM_DAMQHS_MASK	(UINT64_CAST 0x3 << 16)
+#define RPPARM_DAMQHS_MASK	(0x3UL << 16)
 #define RPPARM_NULLTO_SHFT	10
-#define RPPARM_NULLTO_MASK	(UINT64_CAST 0x3f << 10)
+#define RPPARM_NULLTO_MASK	(0x3fUL << 10)
 #define RPPARM_MAXBURST_SHFT	0
-#define RPPARM_MAXBURST_MASK	(UINT64_CAST 0x3ff)
+#define RPPARM_MAXBURST_MASK	0x3ffUL
 
 /*
  * NOTE: Normally the kernel tracks only UTILIZATION statistics.
@@ -356,23 +350,23 @@
 /*
  * RR_STATUS_ERROR(_L) and RR_ERROR_CLEAR(_L) mask and shift definitions
  */
-#define RSERR_POWERNOK		(UINT64_CAST 1 << 38)
-#define RSERR_PORT_DEADLOCK     (UINT64_CAST 1 << 37)
-#define RSERR_WARMRESET         (UINT64_CAST 1 << 36)
-#define RSERR_LINKRESET         (UINT64_CAST 1 << 35)
-#define RSERR_RETRYTIMEOUT      (UINT64_CAST 1 << 34)
-#define RSERR_FIFOOVERFLOW	(UINT64_CAST 1 << 33)
-#define RSERR_ILLEGALPORT	(UINT64_CAST 1 << 32)
+#define RSERR_POWERNOK		(1UL << 38)
+#define RSERR_PORT_DEADLOCK     (1UL << 37)
+#define RSERR_WARMRESET         (1UL << 36)
+#define RSERR_LINKRESET         (1UL << 35)
+#define RSERR_RETRYTIMEOUT      (1UL << 34)
+#define RSERR_FIFOOVERFLOW	(1UL << 33)
+#define RSERR_ILLEGALPORT	(1UL << 32)
 #define RSERR_DEADLOCKTO_SHFT	28
-#define RSERR_DEADLOCKTO_MASK	(UINT64_CAST 0xf << 28)
+#define RSERR_DEADLOCKTO_MASK	(0xfUL << 28)
 #define RSERR_RECVTAILTO_SHFT	24
-#define RSERR_RECVTAILTO_MASK	(UINT64_CAST 0xf << 24)
+#define RSERR_RECVTAILTO_MASK	(0xfUL << 24)
 #define RSERR_RETRYCNT_SHFT	16
-#define RSERR_RETRYCNT_MASK	(UINT64_CAST 0xff << 16)
+#define RSERR_RETRYCNT_MASK	(0xffUL << 16)
 #define RSERR_CBERRCNT_SHFT	8
-#define RSERR_CBERRCNT_MASK	(UINT64_CAST 0xff << 8)
+#define RSERR_CBERRCNT_MASK	(0xffUL << 8)
 #define RSERR_SNERRCNT_SHFT	0
-#define RSERR_SNERRCNT_MASK	(UINT64_CAST 0xff << 0)
+#define RSERR_SNERRCNT_MASK	(0xffUL << 0)
 
 
 #define PORT_STATUS_UP		(1 << 0)	/* Router link up */
@@ -393,10 +387,10 @@
 						 * why the router link
 						 * went down
 						 */	
-#define PROBE_RESULT_BAD	(-1)		/* Set if any of the router
+#define PROBE_RESULT_BAD	-1		/* Set if any of the router
 						 * links failed after reset
 						 */
-#define PROBE_RESULT_GOOD	(0)		/* Set if all the router links
+#define PROBE_RESULT_GOOD	0		/* Set if all the router links
 						 * which came out of reset 
 						 * are up
 						 */
@@ -528,23 +522,6 @@
 #define RIP_PROMLOG			2	/* Router info in promlog */
 #define RIP_CONSOLE			4	/* Router info on console */
 
-#define ROUTER_INFO_PRINT(_rip,_where)	(_rip->ri_print |= _where)	
-					/* Set the field used to check if a 
-					 * router info can be printed
-					 */
-#define IS_ROUTER_INFO_PRINTED(_rip,_where)	\
-					(_rip->ri_print & _where)	
-					/* Was the router info printed to
-					 * the given location (_where) ?
-					 * Mainly used to prevent duplicate
-					 * router error states.
-					 */
-#define ROUTER_INFO_LOCK(_rip,_s)	_s = mutex_spinlock(&(_rip->ri_lock))
-					/* Take the lock on router info
-					 * to gain exclusive access
-					 */
-#define ROUTER_INFO_UNLOCK(_rip,_s)	mutex_spinunlock(&(_rip->ri_lock),_s)
-					/* Release the lock on router info */
 /* 
  * Router info hanging in the nodepda 
  */
@@ -623,7 +600,7 @@
  */
 
 #define RHIST_BUCKET_SHFT(_x)	(32 * ((_x) & 0x1))
-#define RHIST_BUCKET_MASK(_x)	(UINT64_CAST 0xffffffff << RHIST_BUCKET_SHFT((_x) & 0x1))
+#define RHIST_BUCKET_MASK(_x)	(0xffffffffUL << RHIST_BUCKET_SHFT((_x) & 0x1))
 #define RHIST_GET_BUCKET(_x, _reg)	\
 	((RHIST_BUCKET_MASK(_x) & ((_reg)[(_x) >> 1])) >> RHIST_BUCKET_SHFT(_x))
 
@@ -631,7 +608,7 @@
  * RR_RESET_MASK(_L) mask and shift definitions
  */
 
-#define RRM_RESETOK(_L)		(UINT64_CAST 1 << ((_L) - 1))
+#define RRM_RESETOK(_L)		(1UL << ((_L) - 1))
 #define RRM_RESETOK_ALL		ALL_PORTS
 
 /*
@@ -639,7 +616,7 @@
  */
 
 #define RTABLE_SHFT(_L)		(4 * ((_L) - 1))
-#define RTABLE_MASK(_L)		(UINT64_CAST 0x7 << RTABLE_SHFT(_L))
+#define RTABLE_MASK(_L)		(0x7UL << RTABLE_SHFT(_L))
 
 
 #define	ROUTERINFO_STKSZ	4096
