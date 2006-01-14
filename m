From: Prarit Bhargava <prarit@sgi.com>
Date: Sat, 14 Jan 2006 23:17:56 +0000
Subject: [PATCH 6/6 ]: arch/ia64/sn/include/xtalk/xbow.h whitespace
Message-Id: <20060114231707.12238.51811.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Various whitespace, tab, etc., cleanup of xbow.h

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
---
commit edcc9d727a730ed0410284a4f1cf0f94c44a43b7
tree 94ddebd61ba6e039d6124fadab950b66208fbc42
parent f3a3bb17505a9dd61d901349204a662fe19548da
author Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:59:32 -0500
committer Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:59:32 -0500

 arch/ia64/sn/include/xtalk/xbow.h |  198 +++++++++++++++++++------------------
 1 files changed, 104 insertions(+), 94 deletions(-)

diff --git a/arch/ia64/sn/include/xtalk/xbow.h b/arch/ia64/sn/include/xtalk/xbow.h
--- a/arch/ia64/sn/include/xtalk/xbow.h
+++ b/arch/ia64/sn/include/xtalk/xbow.h
@@ -3,7 +3,8 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992-1997,2000-2004 Silicon Graphics, Inc. All Rights Reserved.
+ * Copyright (C) 1992-1997,2000-2006 Silicon Graphics, Inc. All Rights
+ * Reserved.
  */
 #ifndef _ASM_IA64_SN_XTALK_XBOW_H
 #define _ASM_IA64_SN_XTALK_XBOW_H
@@ -21,94 +22,94 @@
 
 /* Register set for each xbow link */
 typedef volatile struct xb_linkregs_s {
-/* 
+/*
  * we access these through synergy unswizzled space, so the address
  * gets twiddled (i.e. references to 0x4 actually go to 0x0 and vv.)
  * That's why we put the register first and filler second.
  */
-    u32               link_ibf;
-    u32               filler0;	/* filler for proper alignment */
-    u32               link_control;
-    u32               filler1;
-    u32               link_status;
-    u32               filler2;
-    u32               link_arb_upper;
-    u32               filler3;
-    u32               link_arb_lower;
-    u32               filler4;
-    u32               link_status_clr;
-    u32               filler5;
-    u32               link_reset;
-    u32               filler6;
-    u32               link_aux_status;
-    u32               filler7;
+	u32 link_ibf;
+	u32 filler0;	/* filler for proper alignment */
+	u32 link_control;
+	u32 filler1;
+	u32 link_status;
+	u32 filler2;
+	u32 link_arb_upper;
+	u32 filler3;
+	u32 link_arb_lower;
+	u32 filler4;
+	u32 link_status_clr;
+	u32 filler5;
+	u32 link_reset;
+	u32 filler6;
+	u32 link_aux_status;
+	u32 filler7;
 } xb_linkregs_t;
 
 typedef volatile struct xbow_s {
-    /* standard widget configuration                       0x000000-0x000057 */
-    struct widget_cfg            xb_widget;  /* 0x000000 */
+	/* standard widget configuration 0x000000-0x000057 */
+	struct widget_cfg xb_widget;  /* 0x000000 */
 
-    /* helper fieldnames for accessing bridge widget */
+	/* helper fieldnames for accessing bridge widget */
 
-#define xb_wid_id                       xb_widget.w_id
-#define xb_wid_stat                     xb_widget.w_status
-#define xb_wid_err_upper                xb_widget.w_err_upper_addr
-#define xb_wid_err_lower                xb_widget.w_err_lower_addr
-#define xb_wid_control                  xb_widget.w_control
-#define xb_wid_req_timeout              xb_widget.w_req_timeout
-#define xb_wid_int_upper                xb_widget.w_intdest_upper_addr
-#define xb_wid_int_lower                xb_widget.w_intdest_lower_addr
-#define xb_wid_err_cmdword              xb_widget.w_err_cmd_word
-#define xb_wid_llp                      xb_widget.w_llp_cfg
-#define xb_wid_stat_clr                 xb_widget.w_tflush
+#define xb_wid_id 		xb_widget.w_id
+#define xb_wid_stat 		xb_widget.w_status
+#define xb_wid_err_upper 	xb_widget.w_err_upper_addr
+#define xb_wid_err_lower 	xb_widget.w_err_lower_addr
+#define xb_wid_control		xb_widget.w_control
+#define xb_wid_req_timeout 	xb_widget.w_req_timeout
+#define xb_wid_int_upper 	xb_widget.w_intdest_upper_addr
+#define xb_wid_int_lower 	xb_widget.w_intdest_lower_addr
+#define xb_wid_err_cmdword 	xb_widget.w_err_cmd_word
+#define xb_wid_llp 		xb_widget.w_llp_cfg
+#define xb_wid_stat_clr 	xb_widget.w_tflush
 
-/* 
+/*
  * we access these through synergy unswizzled space, so the address
  * gets twiddled (i.e. references to 0x4 actually go to 0x0 and vv.)
  * That's why we put the register first and filler second.
  */
-    /* xbow-specific widget configuration                  0x000058-0x0000FF */
-    u32               xb_wid_arb_reload;  /* 0x00005C */
-    u32               _pad_000058;
-    u32               xb_perf_ctr_a;      /* 0x000064 */
-    u32               _pad_000060;
-    u32               xb_perf_ctr_b;      /* 0x00006c */
-    u32               _pad_000068;
-    u32               xb_nic;     /* 0x000074 */
-    u32               _pad_000070;
-
-    /* Xbridge only */
-    u32               xb_w0_rst_fnc;      /* 0x00007C */
-    u32               _pad_000078;
-    u32               xb_l8_rst_fnc;      /* 0x000084 */
-    u32               _pad_000080;
-    u32               xb_l9_rst_fnc;      /* 0x00008c */
-    u32               _pad_000088;
-    u32               xb_la_rst_fnc;      /* 0x000094 */
-    u32               _pad_000090;
-    u32               xb_lb_rst_fnc;      /* 0x00009c */
-    u32               _pad_000098;
-    u32               xb_lc_rst_fnc;      /* 0x0000a4 */
-    u32               _pad_0000a0;
-    u32               xb_ld_rst_fnc;      /* 0x0000ac */
-    u32               _pad_0000a8;
-    u32               xb_le_rst_fnc;      /* 0x0000b4 */
-    u32               _pad_0000b0;
-    u32               xb_lf_rst_fnc;      /* 0x0000bc */
-    u32               _pad_0000b8;
-    u32               xb_lock;            /* 0x0000c4 */
-    u32               _pad_0000c0;
-    u32               xb_lock_clr;        /* 0x0000cc */
-    u32               _pad_0000c8;
-    /* end of Xbridge only */
-    u32               _pad_0000d0[12];
-
-    /* Link Specific Registers, port 8..15                 0x000100-0x000300 */
-    xb_linkregs_t           xb_link_raw[MAX_XBOW_PORTS];
-#define xb_link(p)      xb_link_raw[(p) & (MAX_XBOW_PORTS - 1)]
+	/* xbow-specific widget configuration    0x000058-0x0000FF */
+	u32 xb_wid_arb_reload; /* 0x00005C */
+	u32 _pad_000058;
+	u32 xb_perf_ctr_a;	/* 0x000064 */
+	u32 _pad_000060;
+	u32 xb_perf_ctr_b;	/* 0x00006c */
+	u32 _pad_000068;
+	u32 xb_nic;		/* 0x000074 */
+	u32 _pad_000070;
+
+	/* Xbridge only */
+	u32 xb_w0_rst_fnc;	/* 0x00007C */
+	u32 _pad_000078;
+	u32 xb_l8_rst_fnc;	/* 0x000084 */
+	u32 _pad_000080;
+	u32 xb_l9_rst_fnc;	/* 0x00008c */
+	u32 _pad_000088;
+	u32 xb_la_rst_fnc;	/* 0x000094 */
+	u32 _pad_000090;
+	u32 xb_lb_rst_fnc;	/* 0x00009c */
+	u32 _pad_000098;
+	u32 xb_lc_rst_fnc;	/* 0x0000a4 */
+	u32 _pad_0000a0;
+	u32 xb_ld_rst_fnc;	/* 0x0000ac */
+	u32 _pad_0000a8;
+	u32 xb_le_rst_fnc;	/* 0x0000b4 */
+	u32 _pad_0000b0;
+	u32 xb_lf_rst_fnc;	/* 0x0000bc */
+	u32 _pad_0000b8;
+	u32 xb_lock;		/* 0x0000c4 */
+	u32 _pad_0000c0;
+	u32 xb_lock_clr;	/* 0x0000cc */
+	u32 _pad_0000c8;
+	/* end of Xbridge only */
+	u32 _pad_0000d0[12];
 
+	/* Link Specific Registers, port 8..15   0x000100-0x000300 */
+	xb_linkregs_t xb_link_raw[MAX_XBOW_PORTS];
 } xbow_t;
 
+#define xb_link(p) xb_link_raw[(p) & (MAX_XBOW_PORTS - 1)]
+
 #define XB_FLAGS_EXISTS		0x1	/* device exists */
 #define XB_FLAGS_MASTER		0x2
 #define XB_FLAGS_SLAVE		0x0
@@ -160,7 +161,7 @@ typedef volatile struct xbow_s {
 /* End of Xbridge only */
 
 /* used only in ide, but defined here within the reserved portion */
-/*              of the widget0 address space (before 0xf4) */
+/* of the widget0 address space (before 0xf4) */
 #define	XBOW_WID_UNDEF		0xe4
 
 /* xbow link register set base, legal value for x is 0x8..0xf */
@@ -179,29 +180,37 @@ typedef volatile struct xbow_s {
 
 /* link_control(x) */
 #define	XB_CTRL_LINKALIVE_IE		0x80000000	/* link comes alive */
-     /* reserved:			0x40000000 */
+/* reserved:			0x40000000 */
 #define	XB_CTRL_PERF_CTR_MODE_MSK	0x30000000	/* perf counter mode */
-#define	XB_CTRL_IBUF_LEVEL_MSK		0x0e000000	/* input packet buffer level */
-#define	XB_CTRL_8BIT_MODE		0x01000000	/* force link into 8 bit mode */
-#define XB_CTRL_BAD_LLP_PKT		0x00800000	/* force bad LLP packet */
-#define XB_CTRL_WIDGET_CR_MSK		0x007c0000	/* LLP widget credit mask */
-#define XB_CTRL_WIDGET_CR_SHFT	18			/* LLP widget credit shift */
-#define XB_CTRL_ILLEGAL_DST_IE		0x00020000	/* illegal destination */
-#define XB_CTRL_OALLOC_IBUF_IE		0x00010000	/* overallocated input buffer */
-     /* reserved:			0x0000fe00 */
+#define	XB_CTRL_IBUF_LEVEL_MSK		0x0e000000	/* input packet buffer
+							   level */
+#define	XB_CTRL_8BIT_MODE		0x01000000	/* force link into 8
+							   bit mode */
+#define XB_CTRL_BAD_LLP_PKT		0x00800000	/* force bad LLP
+							   packet */
+#define XB_CTRL_WIDGET_CR_MSK		0x007c0000	/* LLP widget credit
+							   mask */
+#define XB_CTRL_WIDGET_CR_SHFT	18			/* LLP widget credit
+							   shift */
+#define XB_CTRL_ILLEGAL_DST_IE		0x00020000	/* illegal destination
+							 */
+#define XB_CTRL_OALLOC_IBUF_IE		0x00010000	/* overallocated input
+							   buffer */
+/* reserved:			0x0000fe00 */
 #define XB_CTRL_BNDWDTH_ALLOC_IE	0x00000100	/* bandwidth alloc */
 #define XB_CTRL_RCV_CNT_OFLOW_IE	0x00000080	/* rcv retry overflow */
 #define XB_CTRL_XMT_CNT_OFLOW_IE	0x00000040	/* xmt retry overflow */
 #define XB_CTRL_XMT_MAX_RTRY_IE		0x00000020	/* max transmit retry */
 #define XB_CTRL_RCV_IE			0x00000010	/* receive */
 #define XB_CTRL_XMT_RTRY_IE		0x00000008	/* transmit retry */
-     /* reserved:			0x00000004 */
-#define	XB_CTRL_MAXREQ_TOUT_IE		0x00000002	/* maximum request timeout */
+/* reserved:			0x00000004 */
+#define	XB_CTRL_MAXREQ_TOUT_IE		0x00000002	/* maximum request
+							   timeout */
 #define	XB_CTRL_SRC_TOUT_IE		0x00000001	/* source timeout */
 
 /* link_status(x) */
 #define	XB_STAT_LINKALIVE		XB_CTRL_LINKALIVE_IE
-     /* reserved:			0x7ff80000 */
+/* reserved:			0x7ff80000 */
 #define	XB_STAT_MULTI_ERR		0x00040000	/* multi error */
 #define	XB_STAT_ILLEGAL_DST_ERR		XB_CTRL_ILLEGAL_DST_IE
 #define	XB_STAT_OALLOC_IBUF_ERR		XB_CTRL_OALLOC_IBUF_IE
@@ -211,7 +220,7 @@ typedef volatile struct xbow_s {
 #define	XB_STAT_XMT_MAX_RTRY_ERR	XB_CTRL_XMT_MAX_RTRY_IE
 #define	XB_STAT_RCV_ERR			XB_CTRL_RCV_IE
 #define	XB_STAT_XMT_RTRY_ERR		XB_CTRL_XMT_RTRY_IE
-     /* reserved:			0x00000004 */
+/* reserved:			0x00000004 */
 #define	XB_STAT_MAXREQ_TOUT_ERR		XB_CTRL_MAXREQ_TOUT_IE
 #define	XB_STAT_SRC_TOUT_ERR		XB_CTRL_SRC_TOUT_IE
 
@@ -222,7 +231,7 @@ typedef volatile struct xbow_s {
 #define	XB_AUX_LINKFAIL_RST_BAD	0x00000040
 #define	XB_AUX_STAT_PRESENT	0x00000020
 #define	XB_AUX_STAT_PORT_WIDTH	0x00000010
-     /*	reserved:		0x0000000f */
+/*	reserved:		0x0000000f */
 
 /*
  * link_arb_upper/link_arb_lower(x), (reg) should be the link_arb_upper
@@ -238,7 +247,8 @@ typedef volatile struct xbow_s {
 /* XBOW_WID_STAT */
 #define	XB_WID_STAT_LINK_INTR_SHFT	(24)
 #define	XB_WID_STAT_LINK_INTR_MASK	(0xFF << XB_WID_STAT_LINK_INTR_SHFT)
-#define	XB_WID_STAT_LINK_INTR(x)	(0x1 << (((x)&7) + XB_WID_STAT_LINK_INTR_SHFT))
+#define	XB_WID_STAT_LINK_INTR(x) \
+	(0x1 << (((x)&7) + XB_WID_STAT_LINK_INTR_SHFT))
 #define	XB_WID_STAT_WIDGET0_INTR	0x00800000
 #define XB_WID_STAT_SRCID_MASK		0x000003c0	/* Xbridge only */
 #define	XB_WID_STAT_REG_ACC_ERR		0x00000020
@@ -264,7 +274,7 @@ typedef volatile struct xbow_s {
 #define XXBOW_WIDGET_PART_NUM	0xd000		/* Xbridge */
 #define	XBOW_WIDGET_MFGR_NUM	0x0
 #define	XXBOW_WIDGET_MFGR_NUM	0x0
-#define PXBOW_WIDGET_PART_NUM   0xd100          /* PIC */
+#define PXBOW_WIDGET_PART_NUM   0xd100		/* PIC */
 
 #define	XBOW_REV_1_0		0x1	/* xbow rev 1.0 is "1" */
 #define	XBOW_REV_1_1		0x2	/* xbow rev 1.1 is "2" */
@@ -279,13 +289,13 @@ typedef volatile struct xbow_s {
 #define	XBOW_WID_ARB_RELOAD_INT	0x3f	/* GBR reload interval */
 
 #define IS_XBRIDGE_XBOW(wid) \
-        (XWIDGET_PART_NUM(wid) = XXBOW_WIDGET_PART_NUM && \
-                        XWIDGET_MFG_NUM(wid) = XXBOW_WIDGET_MFGR_NUM)
+	(XWIDGET_PART_NUM(wid) = XXBOW_WIDGET_PART_NUM && \
+	XWIDGET_MFG_NUM(wid) = XXBOW_WIDGET_MFGR_NUM)
 
 #define IS_PIC_XBOW(wid) \
-        (XWIDGET_PART_NUM(wid) = PXBOW_WIDGET_PART_NUM && \
-                        XWIDGET_MFG_NUM(wid) = XXBOW_WIDGET_MFGR_NUM)
+	(XWIDGET_PART_NUM(wid) = PXBOW_WIDGET_PART_NUM && \
+	XWIDGET_MFG_NUM(wid) = XXBOW_WIDGET_MFGR_NUM)
 
 #define XBOW_WAR_ENABLED(pv, widid) ((1 << XWIDGET_REV_NUM(widid)) & pv)
 
-#endif                          /* _ASM_IA64_SN_XTALK_XBOW_H */
+#endif /* _ASM_IA64_SN_XTALK_XBOW_H */
