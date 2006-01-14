From: Prarit Bhargava <prarit@sgi.com>
Date: Sat, 14 Jan 2006 23:17:45 +0000
Subject: [PATCH 4/6 ]: include/asm-ia64/sn/shubio.h [u]intX_t cleanup
Message-Id: <20060114231657.12238.31674.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In include/asm-ia64/sn/shubio.h

Replace uintX_t declarations with uX declarations.
Replace intX_t declarations with sX declarations.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
---
commit 07ea14d27e1f8299a24461547df325f5133d4e9d
tree e27490a18c55a8c5ea34be68cbe056c75b67c878
parent 0104a6b84640972e665519f4184b5aa67de20cff
author Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:58:39 -0500
committer Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:58:39 -0500

 include/asm-ia64/sn/shubio.h | 1552 +++++++++++++++++++++---------------------
 1 files changed, 776 insertions(+), 776 deletions(-)

diff --git a/include/asm-ia64/sn/shubio.h b/include/asm-ia64/sn/shubio.h
--- a/include/asm-ia64/sn/shubio.h
+++ b/include/asm-ia64/sn/shubio.h
@@ -227,13 +227,13 @@
  ************************************************************************/
 
 typedef union ii_wid_u {
-	uint64_t ii_wid_regval;
+	u64 ii_wid_regval;
 	struct {
-		uint64_t w_rsvd_1:1;
-		uint64_t w_mfg_num:11;
-		uint64_t w_part_num:16;
-		uint64_t w_rev_num:4;
-		uint64_t w_rsvd:32;
+		u64 w_rsvd_1:1;
+		u64 w_mfg_num:11;
+		u64 w_part_num:16;
+		u64 w_rev_num:4;
+		u64 w_rsvd:32;
 	} ii_wid_fld_s;
 } ii_wid_u_t;
 
@@ -246,18 +246,18 @@ typedef union ii_wid_u {
  ************************************************************************/
 
 typedef union ii_wstat_u {
-	uint64_t ii_wstat_regval;
+	u64 ii_wstat_regval;
 	struct {
-		uint64_t w_pending:4;
-		uint64_t w_xt_crd_to:1;
-		uint64_t w_xt_tail_to:1;
-		uint64_t w_rsvd_3:3;
-		uint64_t w_tx_mx_rty:1;
-		uint64_t w_rsvd_2:6;
-		uint64_t w_llp_tx_cnt:8;
-		uint64_t w_rsvd_1:8;
-		uint64_t w_crazy:1;
-		uint64_t w_rsvd:31;
+		u64 w_pending:4;
+		u64 w_xt_crd_to:1;
+		u64 w_xt_tail_to:1;
+		u64 w_rsvd_3:3;
+		u64 w_tx_mx_rty:1;
+		u64 w_rsvd_2:6;
+		u64 w_llp_tx_cnt:8;
+		u64 w_rsvd_1:8;
+		u64 w_crazy:1;
+		u64 w_rsvd:31;
 	} ii_wstat_fld_s;
 } ii_wstat_u_t;
 
@@ -269,16 +269,16 @@ typedef union ii_wstat_u {
  ************************************************************************/
 
 typedef union ii_wcr_u {
-	uint64_t ii_wcr_regval;
+	u64 ii_wcr_regval;
 	struct {
-		uint64_t w_wid:4;
-		uint64_t w_tag:1;
-		uint64_t w_rsvd_1:8;
-		uint64_t w_dst_crd:3;
-		uint64_t w_f_bad_pkt:1;
-		uint64_t w_dir_con:1;
-		uint64_t w_e_thresh:5;
-		uint64_t w_rsvd:41;
+		u64 w_wid:4;
+		u64 w_tag:1;
+		u64 w_rsvd_1:8;
+		u64 w_dst_crd:3;
+		u64 w_f_bad_pkt:1;
+		u64 w_dir_con:1;
+		u64 w_e_thresh:5;
+		u64 w_rsvd:41;
 	} ii_wcr_fld_s;
 } ii_wcr_u_t;
 
@@ -310,9 +310,9 @@ typedef union ii_wcr_u {
  ************************************************************************/
 
 typedef union ii_ilapr_u {
-	uint64_t ii_ilapr_regval;
+	u64 ii_ilapr_regval;
 	struct {
-		uint64_t i_region:64;
+		u64 i_region:64;
 	} ii_ilapr_fld_s;
 } ii_ilapr_u_t;
 
@@ -330,9 +330,9 @@ typedef union ii_ilapr_u {
  ************************************************************************/
 
 typedef union ii_ilapo_u {
-	uint64_t ii_ilapo_regval;
+	u64 ii_ilapo_regval;
 	struct {
-		uint64_t i_io_ovrride:64;
+		u64 i_io_ovrride:64;
 	} ii_ilapo_fld_s;
 } ii_ilapo_u_t;
 
@@ -344,12 +344,12 @@ typedef union ii_ilapo_u {
  ************************************************************************/
 
 typedef union ii_iowa_u {
-	uint64_t ii_iowa_regval;
+	u64 ii_iowa_regval;
 	struct {
-		uint64_t i_w0_oac:1;
-		uint64_t i_rsvd_1:7;
-		uint64_t i_wx_oac:8;
-		uint64_t i_rsvd:48;
+		u64 i_w0_oac:1;
+		u64 i_rsvd_1:7;
+		u64 i_wx_oac:8;
+		u64 i_rsvd:48;
 	} ii_iowa_fld_s;
 } ii_iowa_u_t;
 
@@ -363,12 +363,12 @@ typedef union ii_iowa_u {
  ************************************************************************/
 
 typedef union ii_iiwa_u {
-	uint64_t ii_iiwa_regval;
+	u64 ii_iiwa_regval;
 	struct {
-		uint64_t i_w0_iac:1;
-		uint64_t i_rsvd_1:7;
-		uint64_t i_wx_iac:8;
-		uint64_t i_rsvd:48;
+		u64 i_w0_iac:1;
+		u64 i_rsvd_1:7;
+		u64 i_wx_iac:8;
+		u64 i_rsvd:48;
 	} ii_iiwa_fld_s;
 } ii_iiwa_u_t;
 
@@ -392,16 +392,16 @@ typedef union ii_iiwa_u {
  ************************************************************************/
 
 typedef union ii_iidem_u {
-	uint64_t ii_iidem_regval;
+	u64 ii_iidem_regval;
 	struct {
-		uint64_t i_w8_dxs:8;
-		uint64_t i_w9_dxs:8;
-		uint64_t i_wa_dxs:8;
-		uint64_t i_wb_dxs:8;
-		uint64_t i_wc_dxs:8;
-		uint64_t i_wd_dxs:8;
-		uint64_t i_we_dxs:8;
-		uint64_t i_wf_dxs:8;
+		u64 i_w8_dxs:8;
+		u64 i_w9_dxs:8;
+		u64 i_wa_dxs:8;
+		u64 i_wb_dxs:8;
+		u64 i_wc_dxs:8;
+		u64 i_wd_dxs:8;
+		u64 i_we_dxs:8;
+		u64 i_wf_dxs:8;
 	} ii_iidem_fld_s;
 } ii_iidem_u_t;
 
@@ -413,22 +413,22 @@ typedef union ii_iidem_u {
  ************************************************************************/
 
 typedef union ii_ilcsr_u {
-	uint64_t ii_ilcsr_regval;
+	u64 ii_ilcsr_regval;
 	struct {
-		uint64_t i_nullto:6;
-		uint64_t i_rsvd_4:2;
-		uint64_t i_wrmrst:1;
-		uint64_t i_rsvd_3:1;
-		uint64_t i_llp_en:1;
-		uint64_t i_bm8:1;
-		uint64_t i_llp_stat:2;
-		uint64_t i_remote_power:1;
-		uint64_t i_rsvd_2:1;
-		uint64_t i_maxrtry:10;
-		uint64_t i_d_avail_sel:2;
-		uint64_t i_rsvd_1:4;
-		uint64_t i_maxbrst:10;
-		uint64_t i_rsvd:22;
+		u64 i_nullto:6;
+		u64 i_rsvd_4:2;
+		u64 i_wrmrst:1;
+		u64 i_rsvd_3:1;
+		u64 i_llp_en:1;
+		u64 i_bm8:1;
+		u64 i_llp_stat:2;
+		u64 i_remote_power:1;
+		u64 i_rsvd_2:1;
+		u64 i_maxrtry:10;
+		u64 i_d_avail_sel:2;
+		u64 i_rsvd_1:4;
+		u64 i_maxbrst:10;
+		u64 i_rsvd:22;
 
 	} ii_ilcsr_fld_s;
 } ii_ilcsr_u_t;
@@ -441,11 +441,11 @@ typedef union ii_ilcsr_u {
  ************************************************************************/
 
 typedef union ii_illr_u {
-	uint64_t ii_illr_regval;
+	u64 ii_illr_regval;
 	struct {
-		uint64_t i_sn_cnt:16;
-		uint64_t i_cb_cnt:16;
-		uint64_t i_rsvd:32;
+		u64 i_sn_cnt:16;
+		u64 i_cb_cnt:16;
+		u64 i_rsvd:32;
 	} ii_illr_fld_s;
 } ii_illr_u_t;
 
@@ -464,19 +464,19 @@ typedef union ii_illr_u {
  ************************************************************************/
 
 typedef union ii_iidsr_u {
-	uint64_t ii_iidsr_regval;
+	u64 ii_iidsr_regval;
 	struct {
-		uint64_t i_level:8;
-		uint64_t i_pi_id:1;
-		uint64_t i_node:11;
-		uint64_t i_rsvd_3:4;
-		uint64_t i_enable:1;
-		uint64_t i_rsvd_2:3;
-		uint64_t i_int_sent:2;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_pi0_forward_int:1;
-		uint64_t i_pi1_forward_int:1;
-		uint64_t i_rsvd:30;
+		u64 i_level:8;
+		u64 i_pi_id:1;
+		u64 i_node:11;
+		u64 i_rsvd_3:4;
+		u64 i_enable:1;
+		u64 i_rsvd_2:3;
+		u64 i_int_sent:2;
+		u64 i_rsvd_1:2;
+		u64 i_pi0_forward_int:1;
+		u64 i_pi1_forward_int:1;
+		u64 i_rsvd:30;
 	} ii_iidsr_fld_s;
 } ii_iidsr_u_t;
 
@@ -492,13 +492,13 @@ typedef union ii_iidsr_u {
  ************************************************************************/
 
 typedef union ii_igfx0_u {
-	uint64_t ii_igfx0_regval;
+	u64 ii_igfx0_regval;
 	struct {
-		uint64_t i_w_num:4;
-		uint64_t i_pi_id:1;
-		uint64_t i_n_num:12;
-		uint64_t i_p_num:1;
-		uint64_t i_rsvd:46;
+		u64 i_w_num:4;
+		u64 i_pi_id:1;
+		u64 i_n_num:12;
+		u64 i_p_num:1;
+		u64 i_rsvd:46;
 	} ii_igfx0_fld_s;
 } ii_igfx0_u_t;
 
@@ -514,13 +514,13 @@ typedef union ii_igfx0_u {
  ************************************************************************/
 
 typedef union ii_igfx1_u {
-	uint64_t ii_igfx1_regval;
+	u64 ii_igfx1_regval;
 	struct {
-		uint64_t i_w_num:4;
-		uint64_t i_pi_id:1;
-		uint64_t i_n_num:12;
-		uint64_t i_p_num:1;
-		uint64_t i_rsvd:46;
+		u64 i_w_num:4;
+		u64 i_pi_id:1;
+		u64 i_n_num:12;
+		u64 i_p_num:1;
+		u64 i_rsvd:46;
 	} ii_igfx1_fld_s;
 } ii_igfx1_u_t;
 
@@ -532,9 +532,9 @@ typedef union ii_igfx1_u {
  ************************************************************************/
 
 typedef union ii_iscr0_u {
-	uint64_t ii_iscr0_regval;
+	u64 ii_iscr0_regval;
 	struct {
-		uint64_t i_scratch:64;
+		u64 i_scratch:64;
 	} ii_iscr0_fld_s;
 } ii_iscr0_u_t;
 
@@ -546,9 +546,9 @@ typedef union ii_iscr0_u {
  ************************************************************************/
 
 typedef union ii_iscr1_u {
-	uint64_t ii_iscr1_regval;
+	u64 ii_iscr1_regval;
 	struct {
-		uint64_t i_scratch:64;
+		u64 i_scratch:64;
 	} ii_iscr1_fld_s;
 } ii_iscr1_u_t;
 
@@ -580,13 +580,13 @@ typedef union ii_iscr1_u {
  ************************************************************************/
 
 typedef union ii_itte1_u {
-	uint64_t ii_itte1_regval;
+	u64 ii_itte1_regval;
 	struct {
-		uint64_t i_offset:5;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_w_num:4;
-		uint64_t i_iosp:1;
-		uint64_t i_rsvd:51;
+		u64 i_offset:5;
+		u64 i_rsvd_1:3;
+		u64 i_w_num:4;
+		u64 i_iosp:1;
+		u64 i_rsvd:51;
 	} ii_itte1_fld_s;
 } ii_itte1_u_t;
 
@@ -618,13 +618,13 @@ typedef union ii_itte1_u {
  ************************************************************************/
 
 typedef union ii_itte2_u {
-	uint64_t ii_itte2_regval;
+	u64 ii_itte2_regval;
 	struct {
-		uint64_t i_offset:5;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_w_num:4;
-		uint64_t i_iosp:1;
-		uint64_t i_rsvd:51;
+		u64 i_offset:5;
+		u64 i_rsvd_1:3;
+		u64 i_w_num:4;
+		u64 i_iosp:1;
+		u64 i_rsvd:51;
 	} ii_itte2_fld_s;
 } ii_itte2_u_t;
 
@@ -656,13 +656,13 @@ typedef union ii_itte2_u {
  ************************************************************************/
 
 typedef union ii_itte3_u {
-	uint64_t ii_itte3_regval;
+	u64 ii_itte3_regval;
 	struct {
-		uint64_t i_offset:5;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_w_num:4;
-		uint64_t i_iosp:1;
-		uint64_t i_rsvd:51;
+		u64 i_offset:5;
+		u64 i_rsvd_1:3;
+		u64 i_w_num:4;
+		u64 i_iosp:1;
+		u64 i_rsvd:51;
 	} ii_itte3_fld_s;
 } ii_itte3_u_t;
 
@@ -694,13 +694,13 @@ typedef union ii_itte3_u {
  ************************************************************************/
 
 typedef union ii_itte4_u {
-	uint64_t ii_itte4_regval;
+	u64 ii_itte4_regval;
 	struct {
-		uint64_t i_offset:5;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_w_num:4;
-		uint64_t i_iosp:1;
-		uint64_t i_rsvd:51;
+		u64 i_offset:5;
+		u64 i_rsvd_1:3;
+		u64 i_w_num:4;
+		u64 i_iosp:1;
+		u64 i_rsvd:51;
 	} ii_itte4_fld_s;
 } ii_itte4_u_t;
 
@@ -732,13 +732,13 @@ typedef union ii_itte4_u {
  ************************************************************************/
 
 typedef union ii_itte5_u {
-	uint64_t ii_itte5_regval;
+	u64 ii_itte5_regval;
 	struct {
-		uint64_t i_offset:5;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_w_num:4;
-		uint64_t i_iosp:1;
-		uint64_t i_rsvd:51;
+		u64 i_offset:5;
+		u64 i_rsvd_1:3;
+		u64 i_w_num:4;
+		u64 i_iosp:1;
+		u64 i_rsvd:51;
 	} ii_itte5_fld_s;
 } ii_itte5_u_t;
 
@@ -770,13 +770,13 @@ typedef union ii_itte5_u {
  ************************************************************************/
 
 typedef union ii_itte6_u {
-	uint64_t ii_itte6_regval;
+	u64 ii_itte6_regval;
 	struct {
-		uint64_t i_offset:5;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_w_num:4;
-		uint64_t i_iosp:1;
-		uint64_t i_rsvd:51;
+		u64 i_offset:5;
+		u64 i_rsvd_1:3;
+		u64 i_w_num:4;
+		u64 i_iosp:1;
+		u64 i_rsvd:51;
 	} ii_itte6_fld_s;
 } ii_itte6_u_t;
 
@@ -808,13 +808,13 @@ typedef union ii_itte6_u {
  ************************************************************************/
 
 typedef union ii_itte7_u {
-	uint64_t ii_itte7_regval;
+	u64 ii_itte7_regval;
 	struct {
-		uint64_t i_offset:5;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_w_num:4;
-		uint64_t i_iosp:1;
-		uint64_t i_rsvd:51;
+		u64 i_offset:5;
+		u64 i_rsvd_1:3;
+		u64 i_w_num:4;
+		u64 i_iosp:1;
+		u64 i_rsvd:51;
 	} ii_itte7_fld_s;
 } ii_itte7_u_t;
 
@@ -843,22 +843,22 @@ typedef union ii_itte7_u {
  ************************************************************************/
 
 typedef union ii_iprb0_u {
-	uint64_t ii_iprb0_regval;
+	u64 ii_iprb0_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprb0_fld_s;
 } ii_iprb0_u_t;
 
@@ -887,22 +887,22 @@ typedef union ii_iprb0_u {
  ************************************************************************/
 
 typedef union ii_iprb8_u {
-	uint64_t ii_iprb8_regval;
+	u64 ii_iprb8_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprb8_fld_s;
 } ii_iprb8_u_t;
 
@@ -931,22 +931,22 @@ typedef union ii_iprb8_u {
  ************************************************************************/
 
 typedef union ii_iprb9_u {
-	uint64_t ii_iprb9_regval;
+	u64 ii_iprb9_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprb9_fld_s;
 } ii_iprb9_u_t;
 
@@ -975,22 +975,22 @@ typedef union ii_iprb9_u {
  ************************************************************************/
 
 typedef union ii_iprba_u {
-	uint64_t ii_iprba_regval;
+	u64 ii_iprba_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprba_fld_s;
 } ii_iprba_u_t;
 
@@ -1019,22 +1019,22 @@ typedef union ii_iprba_u {
  ************************************************************************/
 
 typedef union ii_iprbb_u {
-	uint64_t ii_iprbb_regval;
+	u64 ii_iprbb_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprbb_fld_s;
 } ii_iprbb_u_t;
 
@@ -1063,22 +1063,22 @@ typedef union ii_iprbb_u {
  ************************************************************************/
 
 typedef union ii_iprbc_u {
-	uint64_t ii_iprbc_regval;
+	u64 ii_iprbc_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprbc_fld_s;
 } ii_iprbc_u_t;
 
@@ -1107,22 +1107,22 @@ typedef union ii_iprbc_u {
  ************************************************************************/
 
 typedef union ii_iprbd_u {
-	uint64_t ii_iprbd_regval;
+	u64 ii_iprbd_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprbd_fld_s;
 } ii_iprbd_u_t;
 
@@ -1151,22 +1151,22 @@ typedef union ii_iprbd_u {
  ************************************************************************/
 
 typedef union ii_iprbe_u {
-	uint64_t ii_iprbe_regval;
+	u64 ii_iprbe_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprbe_fld_s;
 } ii_iprbe_u_t;
 
@@ -1195,22 +1195,22 @@ typedef union ii_iprbe_u {
  ************************************************************************/
 
 typedef union ii_iprbf_u {
-	uint64_t ii_iprbf_regval;
+	u64 ii_iprbf_regval;
 	struct {
-		uint64_t i_c:8;
-		uint64_t i_na:14;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_nb:14;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_m:2;
-		uint64_t i_f:1;
-		uint64_t i_of_cnt:5;
-		uint64_t i_error:1;
-		uint64_t i_rd_to:1;
-		uint64_t i_spur_wr:1;
-		uint64_t i_spur_rd:1;
-		uint64_t i_rsvd:11;
-		uint64_t i_mult_err:1;
+		u64 i_c:8;
+		u64 i_na:14;
+		u64 i_rsvd_2:2;
+		u64 i_nb:14;
+		u64 i_rsvd_1:2;
+		u64 i_m:2;
+		u64 i_f:1;
+		u64 i_of_cnt:5;
+		u64 i_error:1;
+		u64 i_rd_to:1;
+		u64 i_spur_wr:1;
+		u64 i_spur_rd:1;
+		u64 i_rsvd:11;
+		u64 i_mult_err:1;
 	} ii_iprbe_fld_s;
 } ii_iprbf_u_t;
 
@@ -1232,10 +1232,10 @@ typedef union ii_iprbf_u {
  ************************************************************************/
 
 typedef union ii_ixcc_u {
-	uint64_t ii_ixcc_regval;
+	u64 ii_ixcc_regval;
 	struct {
-		uint64_t i_time_out:26;
-		uint64_t i_rsvd:38;
+		u64 i_time_out:26;
+		u64 i_rsvd:38;
 	} ii_ixcc_fld_s;
 } ii_ixcc_u_t;
 
@@ -1256,16 +1256,16 @@ typedef union ii_ixcc_u {
  ************************************************************************/
 
 typedef union ii_imem_u {
-	uint64_t ii_imem_regval;
+	u64 ii_imem_regval;
 	struct {
-		uint64_t i_w0_esd:1;
-		uint64_t i_rsvd_3:3;
-		uint64_t i_b0_esd:1;
-		uint64_t i_rsvd_2:3;
-		uint64_t i_b1_esd:1;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_clr_precise:1;
-		uint64_t i_rsvd:51;
+		u64 i_w0_esd:1;
+		u64 i_rsvd_3:3;
+		u64 i_b0_esd:1;
+		u64 i_rsvd_2:3;
+		u64 i_b1_esd:1;
+		u64 i_rsvd_1:3;
+		u64 i_clr_precise:1;
+		u64 i_rsvd:51;
 	} ii_imem_fld_s;
 } ii_imem_u_t;
 
@@ -1294,13 +1294,13 @@ typedef union ii_imem_u {
  ************************************************************************/
 
 typedef union ii_ixtt_u {
-	uint64_t ii_ixtt_regval;
+	u64 ii_ixtt_regval;
 	struct {
-		uint64_t i_tail_to:26;
-		uint64_t i_rsvd_1:6;
-		uint64_t i_rrsp_ps:23;
-		uint64_t i_rrsp_to:5;
-		uint64_t i_rsvd:4;
+		u64 i_tail_to:26;
+		u64 i_rsvd_1:6;
+		u64 i_rrsp_ps:23;
+		u64 i_rrsp_to:5;
+		u64 i_rsvd:4;
 	} ii_ixtt_fld_s;
 } ii_ixtt_u_t;
 
@@ -1316,37 +1316,37 @@ typedef union ii_ixtt_u {
  ************************************************************************/
 
 typedef union ii_ieclr_u {
-	uint64_t ii_ieclr_regval;
+	u64 ii_ieclr_regval;
 	struct {
-		uint64_t i_e_prb_0:1;
-		uint64_t i_rsvd:7;
-		uint64_t i_e_prb_8:1;
-		uint64_t i_e_prb_9:1;
-		uint64_t i_e_prb_a:1;
-		uint64_t i_e_prb_b:1;
-		uint64_t i_e_prb_c:1;
-		uint64_t i_e_prb_d:1;
-		uint64_t i_e_prb_e:1;
-		uint64_t i_e_prb_f:1;
-		uint64_t i_e_crazy:1;
-		uint64_t i_e_bte_0:1;
-		uint64_t i_e_bte_1:1;
-		uint64_t i_reserved_1:10;
-		uint64_t i_spur_rd_hdr:1;
-		uint64_t i_cam_intr_to:1;
-		uint64_t i_cam_overflow:1;
-		uint64_t i_cam_read_miss:1;
-		uint64_t i_ioq_rep_underflow:1;
-		uint64_t i_ioq_req_underflow:1;
-		uint64_t i_ioq_rep_overflow:1;
-		uint64_t i_ioq_req_overflow:1;
-		uint64_t i_iiq_rep_overflow:1;
-		uint64_t i_iiq_req_overflow:1;
-		uint64_t i_ii_xn_rep_cred_overflow:1;
-		uint64_t i_ii_xn_req_cred_overflow:1;
-		uint64_t i_ii_xn_invalid_cmd:1;
-		uint64_t i_xn_ii_invalid_cmd:1;
-		uint64_t i_reserved_2:21;
+		u64 i_e_prb_0:1;
+		u64 i_rsvd:7;
+		u64 i_e_prb_8:1;
+		u64 i_e_prb_9:1;
+		u64 i_e_prb_a:1;
+		u64 i_e_prb_b:1;
+		u64 i_e_prb_c:1;
+		u64 i_e_prb_d:1;
+		u64 i_e_prb_e:1;
+		u64 i_e_prb_f:1;
+		u64 i_e_crazy:1;
+		u64 i_e_bte_0:1;
+		u64 i_e_bte_1:1;
+		u64 i_reserved_1:10;
+		u64 i_spur_rd_hdr:1;
+		u64 i_cam_intr_to:1;
+		u64 i_cam_overflow:1;
+		u64 i_cam_read_miss:1;
+		u64 i_ioq_rep_underflow:1;
+		u64 i_ioq_req_underflow:1;
+		u64 i_ioq_rep_overflow:1;
+		u64 i_ioq_req_overflow:1;
+		u64 i_iiq_rep_overflow:1;
+		u64 i_iiq_req_overflow:1;
+		u64 i_ii_xn_rep_cred_overflow:1;
+		u64 i_ii_xn_req_cred_overflow:1;
+		u64 i_ii_xn_invalid_cmd:1;
+		u64 i_xn_ii_invalid_cmd:1;
+		u64 i_reserved_2:21;
 	} ii_ieclr_fld_s;
 } ii_ieclr_u_t;
 
@@ -1360,12 +1360,12 @@ typedef union ii_ieclr_u {
  ************************************************************************/
 
 typedef union ii_ibcr_u {
-	uint64_t ii_ibcr_regval;
+	u64 ii_ibcr_regval;
 	struct {
-		uint64_t i_count:4;
-		uint64_t i_rsvd_1:4;
-		uint64_t i_soft_reset:1;
-		uint64_t i_rsvd:55;
+		u64 i_count:4;
+		u64 i_rsvd_1:4;
+		u64 i_soft_reset:1;
+		u64 i_rsvd:55;
 	} ii_ibcr_fld_s;
 } ii_ibcr_u_t;
 
@@ -1399,22 +1399,22 @@ typedef union ii_ibcr_u {
  ************************************************************************/
 
 typedef union ii_ixsm_u {
-	uint64_t ii_ixsm_regval;
+	u64 ii_ixsm_regval;
 	struct {
-		uint64_t i_byte_en:32;
-		uint64_t i_reserved:1;
-		uint64_t i_tag:3;
-		uint64_t i_alt_pactyp:4;
-		uint64_t i_bo:1;
-		uint64_t i_error:1;
-		uint64_t i_vbpm:1;
-		uint64_t i_gbr:1;
-		uint64_t i_ds:2;
-		uint64_t i_ct:1;
-		uint64_t i_tnum:5;
-		uint64_t i_pactyp:4;
-		uint64_t i_sidn:4;
-		uint64_t i_didn:4;
+		u64 i_byte_en:32;
+		u64 i_reserved:1;
+		u64 i_tag:3;
+		u64 i_alt_pactyp:4;
+		u64 i_bo:1;
+		u64 i_error:1;
+		u64 i_vbpm:1;
+		u64 i_gbr:1;
+		u64 i_ds:2;
+		u64 i_ct:1;
+		u64 i_tnum:5;
+		u64 i_pactyp:4;
+		u64 i_sidn:4;
+		u64 i_didn:4;
 	} ii_ixsm_fld_s;
 } ii_ixsm_u_t;
 
@@ -1426,11 +1426,11 @@ typedef union ii_ixsm_u {
  ************************************************************************/
 
 typedef union ii_ixss_u {
-	uint64_t ii_ixss_regval;
+	u64 ii_ixss_regval;
 	struct {
-		uint64_t i_sideband:8;
-		uint64_t i_rsvd:55;
-		uint64_t i_valid:1;
+		u64 i_sideband:8;
+		u64 i_rsvd:55;
+		u64 i_valid:1;
 	} ii_ixss_fld_s;
 } ii_ixss_u_t;
 
@@ -1447,17 +1447,17 @@ typedef union ii_ixss_u {
  ************************************************************************/
 
 typedef union ii_ilct_u {
-	uint64_t ii_ilct_regval;
+	u64 ii_ilct_regval;
 	struct {
-		uint64_t i_test_seed:20;
-		uint64_t i_test_mask:8;
-		uint64_t i_test_data:20;
-		uint64_t i_test_valid:1;
-		uint64_t i_test_cberr:1;
-		uint64_t i_test_flit:3;
-		uint64_t i_test_clear:1;
-		uint64_t i_test_err_capture:1;
-		uint64_t i_rsvd:9;
+		u64 i_test_seed:20;
+		u64 i_test_mask:8;
+		u64 i_test_data:20;
+		u64 i_test_valid:1;
+		u64 i_test_cberr:1;
+		u64 i_test_flit:3;
+		u64 i_test_clear:1;
+		u64 i_test_err_capture:1;
+		u64 i_rsvd:9;
 	} ii_ilct_fld_s;
 } ii_ilct_u_t;
 
@@ -1482,20 +1482,20 @@ typedef union ii_ilct_u {
  ************************************************************************/
 
 typedef union ii_iieph1_u {
-	uint64_t ii_iieph1_regval;
+	u64 ii_iieph1_regval;
 	struct {
-		uint64_t i_command:7;
-		uint64_t i_rsvd_5:1;
-		uint64_t i_suppl:14;
-		uint64_t i_rsvd_4:1;
-		uint64_t i_source:14;
-		uint64_t i_rsvd_3:1;
-		uint64_t i_err_type:4;
-		uint64_t i_rsvd_2:4;
-		uint64_t i_overrun:1;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_valid:1;
-		uint64_t i_rsvd:13;
+		u64 i_command:7;
+		u64 i_rsvd_5:1;
+		u64 i_suppl:14;
+		u64 i_rsvd_4:1;
+		u64 i_source:14;
+		u64 i_rsvd_3:1;
+		u64 i_err_type:4;
+		u64 i_rsvd_2:4;
+		u64 i_overrun:1;
+		u64 i_rsvd_1:3;
+		u64 i_valid:1;
+		u64 i_rsvd:13;
 	} ii_iieph1_fld_s;
 } ii_iieph1_u_t;
 
@@ -1511,13 +1511,13 @@ typedef union ii_iieph1_u {
  ************************************************************************/
 
 typedef union ii_iieph2_u {
-	uint64_t ii_iieph2_regval;
+	u64 ii_iieph2_regval;
 	struct {
-		uint64_t i_rsvd_0:3;
-		uint64_t i_address:47;
-		uint64_t i_rsvd_1:10;
-		uint64_t i_tail:1;
-		uint64_t i_rsvd:3;
+		u64 i_rsvd_0:3;
+		u64 i_address:47;
+		u64 i_rsvd_1:10;
+		u64 i_tail:1;
+		u64 i_rsvd:3;
 	} ii_iieph2_fld_s;
 } ii_iieph2_u_t;
 
@@ -1532,9 +1532,9 @@ typedef union ii_iieph2_u {
  ************************************************************************/
 
 typedef union ii_islapr_u {
-	uint64_t ii_islapr_regval;
+	u64 ii_islapr_regval;
 	struct {
-		uint64_t i_region:64;
+		u64 i_region:64;
 	} ii_islapr_fld_s;
 } ii_islapr_u_t;
 
@@ -1547,10 +1547,10 @@ typedef union ii_islapr_u {
  ************************************************************************/
 
 typedef union ii_islapo_u {
-	uint64_t ii_islapo_regval;
+	u64 ii_islapo_regval;
 	struct {
-		uint64_t i_io_sbx_ovrride:56;
-		uint64_t i_rsvd:8;
+		u64 i_io_sbx_ovrride:56;
+		u64 i_rsvd:8;
 	} ii_islapo_fld_s;
 } ii_islapo_u_t;
 
@@ -1563,14 +1563,14 @@ typedef union ii_islapo_u {
  ************************************************************************/
 
 typedef union ii_iwi_u {
-	uint64_t ii_iwi_regval;
+	u64 ii_iwi_regval;
 	struct {
-		uint64_t i_prescale:24;
-		uint64_t i_rsvd:8;
-		uint64_t i_timeout:8;
-		uint64_t i_rsvd1:8;
-		uint64_t i_intrpt_retry_period:8;
-		uint64_t i_rsvd2:8;
+		u64 i_prescale:24;
+		u64 i_rsvd:8;
+		u64 i_timeout:8;
+		u64 i_rsvd1:8;
+		u64 i_intrpt_retry_period:8;
+		u64 i_rsvd2:8;
 	} ii_iwi_fld_s;
 } ii_iwi_u_t;
 
@@ -1582,26 +1582,26 @@ typedef union ii_iwi_u {
  ************************************************************************/
 
 typedef union ii_iwel_u {
-	uint64_t ii_iwel_regval;
+	u64 ii_iwel_regval;
 	struct {
-		uint64_t i_intr_timed_out:1;
-		uint64_t i_rsvd:7;
-		uint64_t i_cam_overflow:1;
-		uint64_t i_cam_read_miss:1;
-		uint64_t i_rsvd1:2;
-		uint64_t i_ioq_rep_underflow:1;
-		uint64_t i_ioq_req_underflow:1;
-		uint64_t i_ioq_rep_overflow:1;
-		uint64_t i_ioq_req_overflow:1;
-		uint64_t i_iiq_rep_overflow:1;
-		uint64_t i_iiq_req_overflow:1;
-		uint64_t i_rsvd2:6;
-		uint64_t i_ii_xn_rep_cred_over_under:1;
-		uint64_t i_ii_xn_req_cred_over_under:1;
-		uint64_t i_rsvd3:6;
-		uint64_t i_ii_xn_invalid_cmd:1;
-		uint64_t i_xn_ii_invalid_cmd:1;
-		uint64_t i_rsvd4:30;
+		u64 i_intr_timed_out:1;
+		u64 i_rsvd:7;
+		u64 i_cam_overflow:1;
+		u64 i_cam_read_miss:1;
+		u64 i_rsvd1:2;
+		u64 i_ioq_rep_underflow:1;
+		u64 i_ioq_req_underflow:1;
+		u64 i_ioq_rep_overflow:1;
+		u64 i_ioq_req_overflow:1;
+		u64 i_iiq_rep_overflow:1;
+		u64 i_iiq_req_overflow:1;
+		u64 i_rsvd2:6;
+		u64 i_ii_xn_rep_cred_over_under:1;
+		u64 i_ii_xn_req_cred_over_under:1;
+		u64 i_rsvd3:6;
+		u64 i_ii_xn_invalid_cmd:1;
+		u64 i_xn_ii_invalid_cmd:1;
+		u64 i_rsvd4:30;
 	} ii_iwel_fld_s;
 } ii_iwel_u_t;
 
@@ -1612,22 +1612,22 @@ typedef union ii_iwel_u {
  ************************************************************************/
 
 typedef union ii_iwc_u {
-	uint64_t ii_iwc_regval;
+	u64 ii_iwc_regval;
 	struct {
-		uint64_t i_dma_byte_swap:1;
-		uint64_t i_rsvd:3;
-		uint64_t i_cam_read_lines_reset:1;
-		uint64_t i_rsvd1:3;
-		uint64_t i_ii_xn_cred_over_under_log:1;
-		uint64_t i_rsvd2:19;
-		uint64_t i_xn_rep_iq_depth:5;
-		uint64_t i_rsvd3:3;
-		uint64_t i_xn_req_iq_depth:5;
-		uint64_t i_rsvd4:3;
-		uint64_t i_iiq_depth:6;
-		uint64_t i_rsvd5:12;
-		uint64_t i_force_rep_cred:1;
-		uint64_t i_force_req_cred:1;
+		u64 i_dma_byte_swap:1;
+		u64 i_rsvd:3;
+		u64 i_cam_read_lines_reset:1;
+		u64 i_rsvd1:3;
+		u64 i_ii_xn_cred_over_under_log:1;
+		u64 i_rsvd2:19;
+		u64 i_xn_rep_iq_depth:5;
+		u64 i_rsvd3:3;
+		u64 i_xn_req_iq_depth:5;
+		u64 i_rsvd4:3;
+		u64 i_iiq_depth:6;
+		u64 i_rsvd5:12;
+		u64 i_force_rep_cred:1;
+		u64 i_force_req_cred:1;
 	} ii_iwc_fld_s;
 } ii_iwc_u_t;
 
@@ -1638,12 +1638,12 @@ typedef union ii_iwc_u {
  ************************************************************************/
 
 typedef union ii_iws_u {
-	uint64_t ii_iws_regval;
+	u64 ii_iws_regval;
 	struct {
-		uint64_t i_xn_rep_iq_credits:5;
-		uint64_t i_rsvd:3;
-		uint64_t i_xn_req_iq_credits:5;
-		uint64_t i_rsvd1:51;
+		u64 i_xn_rep_iq_credits:5;
+		u64 i_rsvd:3;
+		u64 i_xn_req_iq_credits:5;
+		u64 i_rsvd1:51;
 	} ii_iws_fld_s;
 } ii_iws_u_t;
 
@@ -1654,26 +1654,26 @@ typedef union ii_iws_u {
  ************************************************************************/
 
 typedef union ii_iweim_u {
-	uint64_t ii_iweim_regval;
+	u64 ii_iweim_regval;
 	struct {
-		uint64_t i_intr_timed_out:1;
-		uint64_t i_rsvd:7;
-		uint64_t i_cam_overflow:1;
-		uint64_t i_cam_read_miss:1;
-		uint64_t i_rsvd1:2;
-		uint64_t i_ioq_rep_underflow:1;
-		uint64_t i_ioq_req_underflow:1;
-		uint64_t i_ioq_rep_overflow:1;
-		uint64_t i_ioq_req_overflow:1;
-		uint64_t i_iiq_rep_overflow:1;
-		uint64_t i_iiq_req_overflow:1;
-		uint64_t i_rsvd2:6;
-		uint64_t i_ii_xn_rep_cred_overflow:1;
-		uint64_t i_ii_xn_req_cred_overflow:1;
-		uint64_t i_rsvd3:6;
-		uint64_t i_ii_xn_invalid_cmd:1;
-		uint64_t i_xn_ii_invalid_cmd:1;
-		uint64_t i_rsvd4:30;
+		u64 i_intr_timed_out:1;
+		u64 i_rsvd:7;
+		u64 i_cam_overflow:1;
+		u64 i_cam_read_miss:1;
+		u64 i_rsvd1:2;
+		u64 i_ioq_rep_underflow:1;
+		u64 i_ioq_req_underflow:1;
+		u64 i_ioq_rep_overflow:1;
+		u64 i_ioq_req_overflow:1;
+		u64 i_iiq_rep_overflow:1;
+		u64 i_iiq_req_overflow:1;
+		u64 i_rsvd2:6;
+		u64 i_ii_xn_rep_cred_overflow:1;
+		u64 i_ii_xn_req_cred_overflow:1;
+		u64 i_rsvd3:6;
+		u64 i_ii_xn_invalid_cmd:1;
+		u64 i_xn_ii_invalid_cmd:1;
+		u64 i_rsvd4:30;
 	} ii_iweim_fld_s;
 } ii_iweim_u_t;
 
@@ -1688,13 +1688,13 @@ typedef union ii_iweim_u {
  ************************************************************************/
 
 typedef union ii_ipca_u {
-	uint64_t ii_ipca_regval;
+	u64 ii_ipca_regval;
 	struct {
-		uint64_t i_wid:4;
-		uint64_t i_adjust:1;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_field:2;
-		uint64_t i_rsvd:54;
+		u64 i_wid:4;
+		u64 i_adjust:1;
+		u64 i_rsvd_1:3;
+		u64 i_field:2;
+		u64 i_rsvd:54;
 	} ii_ipca_fld_s;
 } ii_ipca_u_t;
 
@@ -1709,12 +1709,12 @@ typedef union ii_ipca_u {
  ************************************************************************/
 
 typedef union ii_iprte0a_u {
-	uint64_t ii_iprte0a_regval;
+	u64 ii_iprte0a_regval;
 	struct {
-		uint64_t i_rsvd_1:54;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:54;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} ii_iprte0a_fld_s;
 } ii_iprte0a_u_t;
 
@@ -1729,12 +1729,12 @@ typedef union ii_iprte0a_u {
  ************************************************************************/
 
 typedef union ii_iprte1a_u {
-	uint64_t ii_iprte1a_regval;
+	u64 ii_iprte1a_regval;
 	struct {
-		uint64_t i_rsvd_1:54;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:54;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} ii_iprte1a_fld_s;
 } ii_iprte1a_u_t;
 
@@ -1749,12 +1749,12 @@ typedef union ii_iprte1a_u {
  ************************************************************************/
 
 typedef union ii_iprte2a_u {
-	uint64_t ii_iprte2a_regval;
+	u64 ii_iprte2a_regval;
 	struct {
-		uint64_t i_rsvd_1:54;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:54;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} ii_iprte2a_fld_s;
 } ii_iprte2a_u_t;
 
@@ -1769,12 +1769,12 @@ typedef union ii_iprte2a_u {
  ************************************************************************/
 
 typedef union ii_iprte3a_u {
-	uint64_t ii_iprte3a_regval;
+	u64 ii_iprte3a_regval;
 	struct {
-		uint64_t i_rsvd_1:54;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:54;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} ii_iprte3a_fld_s;
 } ii_iprte3a_u_t;
 
@@ -1789,12 +1789,12 @@ typedef union ii_iprte3a_u {
  ************************************************************************/
 
 typedef union ii_iprte4a_u {
-	uint64_t ii_iprte4a_regval;
+	u64 ii_iprte4a_regval;
 	struct {
-		uint64_t i_rsvd_1:54;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:54;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} ii_iprte4a_fld_s;
 } ii_iprte4a_u_t;
 
@@ -1809,12 +1809,12 @@ typedef union ii_iprte4a_u {
  ************************************************************************/
 
 typedef union ii_iprte5a_u {
-	uint64_t ii_iprte5a_regval;
+	u64 ii_iprte5a_regval;
 	struct {
-		uint64_t i_rsvd_1:54;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:54;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} ii_iprte5a_fld_s;
 } ii_iprte5a_u_t;
 
@@ -1829,12 +1829,12 @@ typedef union ii_iprte5a_u {
  ************************************************************************/
 
 typedef union ii_iprte6a_u {
-	uint64_t ii_iprte6a_regval;
+	u64 ii_iprte6a_regval;
 	struct {
-		uint64_t i_rsvd_1:54;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:54;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} ii_iprte6a_fld_s;
 } ii_iprte6a_u_t;
 
@@ -1849,12 +1849,12 @@ typedef union ii_iprte6a_u {
  ************************************************************************/
 
 typedef union ii_iprte7a_u {
-	uint64_t ii_iprte7a_regval;
+	u64 ii_iprte7a_regval;
 	struct {
-		uint64_t i_rsvd_1:54;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:54;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} ii_iprtea7_fld_s;
 } ii_iprte7a_u_t;
 
@@ -1869,12 +1869,12 @@ typedef union ii_iprte7a_u {
  ************************************************************************/
 
 typedef union ii_iprte0b_u {
-	uint64_t ii_iprte0b_regval;
+	u64 ii_iprte0b_regval;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_address:47;
-		uint64_t i_init:3;
-		uint64_t i_source:11;
+		u64 i_rsvd_1:3;
+		u64 i_address:47;
+		u64 i_init:3;
+		u64 i_source:11;
 	} ii_iprte0b_fld_s;
 } ii_iprte0b_u_t;
 
@@ -1889,12 +1889,12 @@ typedef union ii_iprte0b_u {
  ************************************************************************/
 
 typedef union ii_iprte1b_u {
-	uint64_t ii_iprte1b_regval;
+	u64 ii_iprte1b_regval;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_address:47;
-		uint64_t i_init:3;
-		uint64_t i_source:11;
+		u64 i_rsvd_1:3;
+		u64 i_address:47;
+		u64 i_init:3;
+		u64 i_source:11;
 	} ii_iprte1b_fld_s;
 } ii_iprte1b_u_t;
 
@@ -1909,12 +1909,12 @@ typedef union ii_iprte1b_u {
  ************************************************************************/
 
 typedef union ii_iprte2b_u {
-	uint64_t ii_iprte2b_regval;
+	u64 ii_iprte2b_regval;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_address:47;
-		uint64_t i_init:3;
-		uint64_t i_source:11;
+		u64 i_rsvd_1:3;
+		u64 i_address:47;
+		u64 i_init:3;
+		u64 i_source:11;
 	} ii_iprte2b_fld_s;
 } ii_iprte2b_u_t;
 
@@ -1929,12 +1929,12 @@ typedef union ii_iprte2b_u {
  ************************************************************************/
 
 typedef union ii_iprte3b_u {
-	uint64_t ii_iprte3b_regval;
+	u64 ii_iprte3b_regval;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_address:47;
-		uint64_t i_init:3;
-		uint64_t i_source:11;
+		u64 i_rsvd_1:3;
+		u64 i_address:47;
+		u64 i_init:3;
+		u64 i_source:11;
 	} ii_iprte3b_fld_s;
 } ii_iprte3b_u_t;
 
@@ -1949,12 +1949,12 @@ typedef union ii_iprte3b_u {
  ************************************************************************/
 
 typedef union ii_iprte4b_u {
-	uint64_t ii_iprte4b_regval;
+	u64 ii_iprte4b_regval;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_address:47;
-		uint64_t i_init:3;
-		uint64_t i_source:11;
+		u64 i_rsvd_1:3;
+		u64 i_address:47;
+		u64 i_init:3;
+		u64 i_source:11;
 	} ii_iprte4b_fld_s;
 } ii_iprte4b_u_t;
 
@@ -1969,12 +1969,12 @@ typedef union ii_iprte4b_u {
  ************************************************************************/
 
 typedef union ii_iprte5b_u {
-	uint64_t ii_iprte5b_regval;
+	u64 ii_iprte5b_regval;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_address:47;
-		uint64_t i_init:3;
-		uint64_t i_source:11;
+		u64 i_rsvd_1:3;
+		u64 i_address:47;
+		u64 i_init:3;
+		u64 i_source:11;
 	} ii_iprte5b_fld_s;
 } ii_iprte5b_u_t;
 
@@ -1989,12 +1989,12 @@ typedef union ii_iprte5b_u {
  ************************************************************************/
 
 typedef union ii_iprte6b_u {
-	uint64_t ii_iprte6b_regval;
+	u64 ii_iprte6b_regval;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_address:47;
-		uint64_t i_init:3;
-		uint64_t i_source:11;
+		u64 i_rsvd_1:3;
+		u64 i_address:47;
+		u64 i_init:3;
+		u64 i_source:11;
 
 	} ii_iprte6b_fld_s;
 } ii_iprte6b_u_t;
@@ -2010,12 +2010,12 @@ typedef union ii_iprte6b_u {
  ************************************************************************/
 
 typedef union ii_iprte7b_u {
-	uint64_t ii_iprte7b_regval;
+	u64 ii_iprte7b_regval;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_address:47;
-		uint64_t i_init:3;
-		uint64_t i_source:11;
+		u64 i_rsvd_1:3;
+		u64 i_address:47;
+		u64 i_init:3;
+		u64 i_source:11;
 	} ii_iprte7b_fld_s;
 } ii_iprte7b_u_t;
 
@@ -2038,13 +2038,13 @@ typedef union ii_iprte7b_u {
  ************************************************************************/
 
 typedef union ii_ipdr_u {
-	uint64_t ii_ipdr_regval;
+	u64 ii_ipdr_regval;
 	struct {
-		uint64_t i_te:3;
-		uint64_t i_rsvd_1:1;
-		uint64_t i_pnd:1;
-		uint64_t i_init_rpcnt:1;
-		uint64_t i_rsvd:58;
+		u64 i_te:3;
+		u64 i_rsvd_1:1;
+		u64 i_pnd:1;
+		u64 i_init_rpcnt:1;
+		u64 i_rsvd:58;
 	} ii_ipdr_fld_s;
 } ii_ipdr_u_t;
 
@@ -2066,11 +2066,11 @@ typedef union ii_ipdr_u {
  ************************************************************************/
 
 typedef union ii_icdr_u {
-	uint64_t ii_icdr_regval;
+	u64 ii_icdr_regval;
 	struct {
-		uint64_t i_crb_num:4;
-		uint64_t i_pnd:1;
-		uint64_t i_rsvd:59;
+		u64 i_crb_num:4;
+		u64 i_pnd:1;
+		u64 i_rsvd:59;
 	} ii_icdr_fld_s;
 } ii_icdr_u_t;
 
@@ -2092,13 +2092,13 @@ typedef union ii_icdr_u {
  ************************************************************************/
 
 typedef union ii_ifdr_u {
-	uint64_t ii_ifdr_regval;
+	u64 ii_ifdr_regval;
 	struct {
-		uint64_t i_ioq_max_rq:7;
-		uint64_t i_set_ioq_rq:1;
-		uint64_t i_ioq_max_rp:7;
-		uint64_t i_set_ioq_rp:1;
-		uint64_t i_rsvd:48;
+		u64 i_ioq_max_rq:7;
+		u64 i_set_ioq_rq:1;
+		u64 i_ioq_max_rp:7;
+		u64 i_set_ioq_rp:1;
+		u64 i_rsvd:48;
 	} ii_ifdr_fld_s;
 } ii_ifdr_u_t;
 
@@ -2114,12 +2114,12 @@ typedef union ii_ifdr_u {
  ************************************************************************/
 
 typedef union ii_iiap_u {
-	uint64_t ii_iiap_regval;
+	u64 ii_iiap_regval;
 	struct {
-		uint64_t i_rq_mls:6;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_rp_mls:6;
-		uint64_t i_rsvd:50;
+		u64 i_rq_mls:6;
+		u64 i_rsvd_1:2;
+		u64 i_rp_mls:6;
+		u64 i_rsvd:50;
 	} ii_iiap_fld_s;
 } ii_iiap_u_t;
 
@@ -2133,22 +2133,22 @@ typedef union ii_iiap_u {
  ************************************************************************/
 
 typedef union ii_icmr_u {
-	uint64_t ii_icmr_regval;
+	u64 ii_icmr_regval;
 	struct {
-		uint64_t i_sp_msg:1;
-		uint64_t i_rd_hdr:1;
-		uint64_t i_rsvd_4:2;
-		uint64_t i_c_cnt:4;
-		uint64_t i_rsvd_3:4;
-		uint64_t i_clr_rqpd:1;
-		uint64_t i_clr_rppd:1;
-		uint64_t i_rsvd_2:2;
-		uint64_t i_fc_cnt:4;
-		uint64_t i_crb_vld:15;
-		uint64_t i_crb_mark:15;
-		uint64_t i_rsvd_1:2;
-		uint64_t i_precise:1;
-		uint64_t i_rsvd:11;
+		u64 i_sp_msg:1;
+		u64 i_rd_hdr:1;
+		u64 i_rsvd_4:2;
+		u64 i_c_cnt:4;
+		u64 i_rsvd_3:4;
+		u64 i_clr_rqpd:1;
+		u64 i_clr_rppd:1;
+		u64 i_rsvd_2:2;
+		u64 i_fc_cnt:4;
+		u64 i_crb_vld:15;
+		u64 i_crb_mark:15;
+		u64 i_rsvd_1:2;
+		u64 i_precise:1;
+		u64 i_rsvd:11;
 	} ii_icmr_fld_s;
 } ii_icmr_u_t;
 
@@ -2161,13 +2161,13 @@ typedef union ii_icmr_u {
  ************************************************************************/
 
 typedef union ii_iccr_u {
-	uint64_t ii_iccr_regval;
+	u64 ii_iccr_regval;
 	struct {
-		uint64_t i_crb_num:4;
-		uint64_t i_rsvd_1:4;
-		uint64_t i_cmd:8;
-		uint64_t i_pending:1;
-		uint64_t i_rsvd:47;
+		u64 i_crb_num:4;
+		u64 i_rsvd_1:4;
+		u64 i_cmd:8;
+		u64 i_pending:1;
+		u64 i_rsvd:47;
 	} ii_iccr_fld_s;
 } ii_iccr_u_t;
 
@@ -2178,10 +2178,10 @@ typedef union ii_iccr_u {
  ************************************************************************/
 
 typedef union ii_icto_u {
-	uint64_t ii_icto_regval;
+	u64 ii_icto_regval;
 	struct {
-		uint64_t i_timeout:8;
-		uint64_t i_rsvd:56;
+		u64 i_timeout:8;
+		u64 i_rsvd:56;
 	} ii_icto_fld_s;
 } ii_icto_u_t;
 
@@ -2197,10 +2197,10 @@ typedef union ii_icto_u {
  ************************************************************************/
 
 typedef union ii_ictp_u {
-	uint64_t ii_ictp_regval;
+	u64 ii_ictp_regval;
 	struct {
-		uint64_t i_prescale:24;
-		uint64_t i_rsvd:40;
+		u64 i_prescale:24;
+		u64 i_rsvd:40;
 	} ii_ictp_fld_s;
 } ii_ictp_u_t;
 
@@ -2228,14 +2228,14 @@ typedef union ii_ictp_u {
  ************************************************************************/
 
 typedef union ii_icrb0_a_u {
-	uint64_t ii_icrb0_a_regval;
+	u64 ii_icrb0_a_regval;
 	struct {
-		uint64_t ia_iow:1;
-		uint64_t ia_vld:1;
-		uint64_t ia_addr:47;
-		uint64_t ia_tnum:5;
-		uint64_t ia_sidn:4;
-		uint64_t ia_rsvd:6;
+		u64 ia_iow:1;
+		u64 ia_vld:1;
+		u64 ia_addr:47;
+		u64 ia_tnum:5;
+		u64 ia_sidn:4;
+		u64 ia_rsvd:6;
 	} ii_icrb0_a_fld_s;
 } ii_icrb0_a_u_t;
 
@@ -2249,30 +2249,30 @@ typedef union ii_icrb0_a_u {
  ************************************************************************/
 
 typedef union ii_icrb0_b_u {
-	uint64_t ii_icrb0_b_regval;
+	u64 ii_icrb0_b_regval;
 	struct {
-		uint64_t ib_xt_err:1;
-		uint64_t ib_mark:1;
-		uint64_t ib_ln_uce:1;
-		uint64_t ib_errcode:3;
-		uint64_t ib_error:1;
-		uint64_t ib_stall__bte_1:1;
-		uint64_t ib_stall__bte_0:1;
-		uint64_t ib_stall__intr:1;
-		uint64_t ib_stall_ib:1;
-		uint64_t ib_intvn:1;
-		uint64_t ib_wb:1;
-		uint64_t ib_hold:1;
-		uint64_t ib_ack:1;
-		uint64_t ib_resp:1;
-		uint64_t ib_ack_cnt:11;
-		uint64_t ib_rsvd:7;
-		uint64_t ib_exc:5;
-		uint64_t ib_init:3;
-		uint64_t ib_imsg:8;
-		uint64_t ib_imsgtype:2;
-		uint64_t ib_use_old:1;
-		uint64_t ib_rsvd_1:11;
+		u64 ib_xt_err:1;
+		u64 ib_mark:1;
+		u64 ib_ln_uce:1;
+		u64 ib_errcode:3;
+		u64 ib_error:1;
+		u64 ib_stall__bte_1:1;
+		u64 ib_stall__bte_0:1;
+		u64 ib_stall__intr:1;
+		u64 ib_stall_ib:1;
+		u64 ib_intvn:1;
+		u64 ib_wb:1;
+		u64 ib_hold:1;
+		u64 ib_ack:1;
+		u64 ib_resp:1;
+		u64 ib_ack_cnt:11;
+		u64 ib_rsvd:7;
+		u64 ib_exc:5;
+		u64 ib_init:3;
+		u64 ib_imsg:8;
+		u64 ib_imsgtype:2;
+		u64 ib_use_old:1;
+		u64 ib_rsvd_1:11;
 	} ii_icrb0_b_fld_s;
 } ii_icrb0_b_u_t;
 
@@ -2286,17 +2286,17 @@ typedef union ii_icrb0_b_u {
  ************************************************************************/
 
 typedef union ii_icrb0_c_u {
-	uint64_t ii_icrb0_c_regval;
+	u64 ii_icrb0_c_regval;
 	struct {
-		uint64_t ic_source:15;
-		uint64_t ic_size:2;
-		uint64_t ic_ct:1;
-		uint64_t ic_bte_num:1;
-		uint64_t ic_gbr:1;
-		uint64_t ic_resprqd:1;
-		uint64_t ic_bo:1;
-		uint64_t ic_suppl:15;
-		uint64_t ic_rsvd:27;
+		u64 ic_source:15;
+		u64 ic_size:2;
+		u64 ic_ct:1;
+		u64 ic_bte_num:1;
+		u64 ic_gbr:1;
+		u64 ic_resprqd:1;
+		u64 ic_bo:1;
+		u64 ic_suppl:15;
+		u64 ic_rsvd:27;
 	} ii_icrb0_c_fld_s;
 } ii_icrb0_c_u_t;
 
@@ -2310,14 +2310,14 @@ typedef union ii_icrb0_c_u {
  ************************************************************************/
 
 typedef union ii_icrb0_d_u {
-	uint64_t ii_icrb0_d_regval;
+	u64 ii_icrb0_d_regval;
 	struct {
-		uint64_t id_pa_be:43;
-		uint64_t id_bte_op:1;
-		uint64_t id_pr_psc:4;
-		uint64_t id_pr_cnt:4;
-		uint64_t id_sleep:1;
-		uint64_t id_rsvd:11;
+		u64 id_pa_be:43;
+		u64 id_bte_op:1;
+		u64 id_pr_psc:4;
+		u64 id_pr_cnt:4;
+		u64 id_sleep:1;
+		u64 id_rsvd:11;
 	} ii_icrb0_d_fld_s;
 } ii_icrb0_d_u_t;
 
@@ -2331,14 +2331,14 @@ typedef union ii_icrb0_d_u {
  ************************************************************************/
 
 typedef union ii_icrb0_e_u {
-	uint64_t ii_icrb0_e_regval;
+	u64 ii_icrb0_e_regval;
 	struct {
-		uint64_t ie_timeout:8;
-		uint64_t ie_context:15;
-		uint64_t ie_rsvd:1;
-		uint64_t ie_tvld:1;
-		uint64_t ie_cvld:1;
-		uint64_t ie_rsvd_0:38;
+		u64 ie_timeout:8;
+		u64 ie_context:15;
+		u64 ie_rsvd:1;
+		u64 ie_tvld:1;
+		u64 ie_cvld:1;
+		u64 ie_rsvd_0:38;
 	} ii_icrb0_e_fld_s;
 } ii_icrb0_e_u_t;
 
@@ -2351,12 +2351,12 @@ typedef union ii_icrb0_e_u {
  ************************************************************************/
 
 typedef union ii_icsml_u {
-	uint64_t ii_icsml_regval;
+	u64 ii_icsml_regval;
 	struct {
-		uint64_t i_tt_addr:47;
-		uint64_t i_newsuppl_ex:14;
-		uint64_t i_reserved:2;
-		uint64_t i_overflow:1;
+		u64 i_tt_addr:47;
+		u64 i_newsuppl_ex:14;
+		u64 i_reserved:2;
+		u64 i_overflow:1;
 	} ii_icsml_fld_s;
 } ii_icsml_u_t;
 
@@ -2369,10 +2369,10 @@ typedef union ii_icsml_u {
  ************************************************************************/
 
 typedef union ii_icsmm_u {
-	uint64_t ii_icsmm_regval;
+	u64 ii_icsmm_regval;
 	struct {
-		uint64_t i_tt_ack_cnt:11;
-		uint64_t i_reserved:53;
+		u64 i_tt_ack_cnt:11;
+		u64 i_reserved:53;
 	} ii_icsmm_fld_s;
 } ii_icsmm_u_t;
 
@@ -2385,48 +2385,48 @@ typedef union ii_icsmm_u {
  ************************************************************************/
 
 typedef union ii_icsmh_u {
-	uint64_t ii_icsmh_regval;
+	u64 ii_icsmh_regval;
 	struct {
-		uint64_t i_tt_vld:1;
-		uint64_t i_xerr:1;
-		uint64_t i_ft_cwact_o:1;
-		uint64_t i_ft_wact_o:1;
-		uint64_t i_ft_active_o:1;
-		uint64_t i_sync:1;
-		uint64_t i_mnusg:1;
-		uint64_t i_mnusz:1;
-		uint64_t i_plusz:1;
-		uint64_t i_plusg:1;
-		uint64_t i_tt_exc:5;
-		uint64_t i_tt_wb:1;
-		uint64_t i_tt_hold:1;
-		uint64_t i_tt_ack:1;
-		uint64_t i_tt_resp:1;
-		uint64_t i_tt_intvn:1;
-		uint64_t i_g_stall_bte1:1;
-		uint64_t i_g_stall_bte0:1;
-		uint64_t i_g_stall_il:1;
-		uint64_t i_g_stall_ib:1;
-		uint64_t i_tt_imsg:8;
-		uint64_t i_tt_imsgtype:2;
-		uint64_t i_tt_use_old:1;
-		uint64_t i_tt_respreqd:1;
-		uint64_t i_tt_bte_num:1;
-		uint64_t i_cbn:1;
-		uint64_t i_match:1;
-		uint64_t i_rpcnt_lt_34:1;
-		uint64_t i_rpcnt_ge_34:1;
-		uint64_t i_rpcnt_lt_18:1;
-		uint64_t i_rpcnt_ge_18:1;
-		uint64_t i_rpcnt_lt_2:1;
-		uint64_t i_rpcnt_ge_2:1;
-		uint64_t i_rqcnt_lt_18:1;
-		uint64_t i_rqcnt_ge_18:1;
-		uint64_t i_rqcnt_lt_2:1;
-		uint64_t i_rqcnt_ge_2:1;
-		uint64_t i_tt_device:7;
-		uint64_t i_tt_init:3;
-		uint64_t i_reserved:5;
+		u64 i_tt_vld:1;
+		u64 i_xerr:1;
+		u64 i_ft_cwact_o:1;
+		u64 i_ft_wact_o:1;
+		u64 i_ft_active_o:1;
+		u64 i_sync:1;
+		u64 i_mnusg:1;
+		u64 i_mnusz:1;
+		u64 i_plusz:1;
+		u64 i_plusg:1;
+		u64 i_tt_exc:5;
+		u64 i_tt_wb:1;
+		u64 i_tt_hold:1;
+		u64 i_tt_ack:1;
+		u64 i_tt_resp:1;
+		u64 i_tt_intvn:1;
+		u64 i_g_stall_bte1:1;
+		u64 i_g_stall_bte0:1;
+		u64 i_g_stall_il:1;
+		u64 i_g_stall_ib:1;
+		u64 i_tt_imsg:8;
+		u64 i_tt_imsgtype:2;
+		u64 i_tt_use_old:1;
+		u64 i_tt_respreqd:1;
+		u64 i_tt_bte_num:1;
+		u64 i_cbn:1;
+		u64 i_match:1;
+		u64 i_rpcnt_lt_34:1;
+		u64 i_rpcnt_ge_34:1;
+		u64 i_rpcnt_lt_18:1;
+		u64 i_rpcnt_ge_18:1;
+		u64 i_rpcnt_lt_2:1;
+		u64 i_rpcnt_ge_2:1;
+		u64 i_rqcnt_lt_18:1;
+		u64 i_rqcnt_ge_18:1;
+		u64 i_rqcnt_lt_2:1;
+		u64 i_rqcnt_ge_2:1;
+		u64 i_tt_device:7;
+		u64 i_tt_init:3;
+		u64 i_reserved:5;
 	} ii_icsmh_fld_s;
 } ii_icsmh_u_t;
 
@@ -2439,14 +2439,14 @@ typedef union ii_icsmh_u {
  ************************************************************************/
 
 typedef union ii_idbss_u {
-	uint64_t ii_idbss_regval;
+	u64 ii_idbss_regval;
 	struct {
-		uint64_t i_iioclk_core_submenu:3;
-		uint64_t i_rsvd:5;
-		uint64_t i_fsbclk_wrapper_submenu:3;
-		uint64_t i_rsvd_1:5;
-		uint64_t i_iioclk_menu:5;
-		uint64_t i_rsvd_2:43;
+		u64 i_iioclk_core_submenu:3;
+		u64 i_rsvd:5;
+		u64 i_fsbclk_wrapper_submenu:3;
+		u64 i_rsvd_1:5;
+		u64 i_iioclk_menu:5;
+		u64 i_rsvd_2:43;
 	} ii_idbss_fld_s;
 } ii_idbss_u_t;
 
@@ -2466,13 +2466,13 @@ typedef union ii_idbss_u {
  ************************************************************************/
 
 typedef union ii_ibls0_u {
-	uint64_t ii_ibls0_regval;
+	u64 ii_ibls0_regval;
 	struct {
-		uint64_t i_length:16;
-		uint64_t i_error:1;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_busy:1;
-		uint64_t i_rsvd:43;
+		u64 i_length:16;
+		u64 i_error:1;
+		u64 i_rsvd_1:3;
+		u64 i_busy:1;
+		u64 i_rsvd:43;
 	} ii_ibls0_fld_s;
 } ii_ibls0_u_t;
 
@@ -2487,11 +2487,11 @@ typedef union ii_ibls0_u {
  ************************************************************************/
 
 typedef union ii_ibsa0_u {
-	uint64_t ii_ibsa0_regval;
+	u64 ii_ibsa0_regval;
 	struct {
-		uint64_t i_rsvd_1:7;
-		uint64_t i_addr:42;
-		uint64_t i_rsvd:15;
+		u64 i_rsvd_1:7;
+		u64 i_addr:42;
+		u64 i_rsvd:15;
 	} ii_ibsa0_fld_s;
 } ii_ibsa0_u_t;
 
@@ -2506,11 +2506,11 @@ typedef union ii_ibsa0_u {
  ************************************************************************/
 
 typedef union ii_ibda0_u {
-	uint64_t ii_ibda0_regval;
+	u64 ii_ibda0_regval;
 	struct {
-		uint64_t i_rsvd_1:7;
-		uint64_t i_addr:42;
-		uint64_t i_rsvd:15;
+		u64 i_rsvd_1:7;
+		u64 i_addr:42;
+		u64 i_rsvd:15;
 	} ii_ibda0_fld_s;
 } ii_ibda0_u_t;
 
@@ -2527,14 +2527,14 @@ typedef union ii_ibda0_u {
  ************************************************************************/
 
 typedef union ii_ibct0_u {
-	uint64_t ii_ibct0_regval;
+	u64 ii_ibct0_regval;
 	struct {
-		uint64_t i_zerofill:1;
-		uint64_t i_rsvd_2:3;
-		uint64_t i_notify:1;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_poison:1;
-		uint64_t i_rsvd:55;
+		u64 i_zerofill:1;
+		u64 i_rsvd_2:3;
+		u64 i_notify:1;
+		u64 i_rsvd_1:3;
+		u64 i_poison:1;
+		u64 i_rsvd:55;
 	} ii_ibct0_fld_s;
 } ii_ibct0_u_t;
 
@@ -2546,11 +2546,11 @@ typedef union ii_ibct0_u {
  ************************************************************************/
 
 typedef union ii_ibna0_u {
-	uint64_t ii_ibna0_regval;
+	u64 ii_ibna0_regval;
 	struct {
-		uint64_t i_rsvd_1:7;
-		uint64_t i_addr:42;
-		uint64_t i_rsvd:15;
+		u64 i_rsvd_1:7;
+		u64 i_addr:42;
+		u64 i_rsvd:15;
 	} ii_ibna0_fld_s;
 } ii_ibna0_u_t;
 
@@ -2563,13 +2563,13 @@ typedef union ii_ibna0_u {
  ************************************************************************/
 
 typedef union ii_ibia0_u {
-	uint64_t ii_ibia0_regval;
+	u64 ii_ibia0_regval;
 	struct {
-		uint64_t i_rsvd_2:1;
-		uint64_t i_node_id:11;
-		uint64_t i_rsvd_1:4;
-		uint64_t i_level:7;
-		uint64_t i_rsvd:41;
+		u64 i_rsvd_2:1;
+		u64 i_node_id:11;
+		u64 i_rsvd_1:4;
+		u64 i_level:7;
+		u64 i_rsvd:41;
 	} ii_ibia0_fld_s;
 } ii_ibia0_u_t;
 
@@ -2589,13 +2589,13 @@ typedef union ii_ibia0_u {
  ************************************************************************/
 
 typedef union ii_ibls1_u {
-	uint64_t ii_ibls1_regval;
+	u64 ii_ibls1_regval;
 	struct {
-		uint64_t i_length:16;
-		uint64_t i_error:1;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_busy:1;
-		uint64_t i_rsvd:43;
+		u64 i_length:16;
+		u64 i_error:1;
+		u64 i_rsvd_1:3;
+		u64 i_busy:1;
+		u64 i_rsvd:43;
 	} ii_ibls1_fld_s;
 } ii_ibls1_u_t;
 
@@ -2610,11 +2610,11 @@ typedef union ii_ibls1_u {
  ************************************************************************/
 
 typedef union ii_ibsa1_u {
-	uint64_t ii_ibsa1_regval;
+	u64 ii_ibsa1_regval;
 	struct {
-		uint64_t i_rsvd_1:7;
-		uint64_t i_addr:33;
-		uint64_t i_rsvd:24;
+		u64 i_rsvd_1:7;
+		u64 i_addr:33;
+		u64 i_rsvd:24;
 	} ii_ibsa1_fld_s;
 } ii_ibsa1_u_t;
 
@@ -2629,11 +2629,11 @@ typedef union ii_ibsa1_u {
  ************************************************************************/
 
 typedef union ii_ibda1_u {
-	uint64_t ii_ibda1_regval;
+	u64 ii_ibda1_regval;
 	struct {
-		uint64_t i_rsvd_1:7;
-		uint64_t i_addr:33;
-		uint64_t i_rsvd:24;
+		u64 i_rsvd_1:7;
+		u64 i_addr:33;
+		u64 i_rsvd:24;
 	} ii_ibda1_fld_s;
 } ii_ibda1_u_t;
 
@@ -2650,14 +2650,14 @@ typedef union ii_ibda1_u {
  ************************************************************************/
 
 typedef union ii_ibct1_u {
-	uint64_t ii_ibct1_regval;
+	u64 ii_ibct1_regval;
 	struct {
-		uint64_t i_zerofill:1;
-		uint64_t i_rsvd_2:3;
-		uint64_t i_notify:1;
-		uint64_t i_rsvd_1:3;
-		uint64_t i_poison:1;
-		uint64_t i_rsvd:55;
+		u64 i_zerofill:1;
+		u64 i_rsvd_2:3;
+		u64 i_notify:1;
+		u64 i_rsvd_1:3;
+		u64 i_poison:1;
+		u64 i_rsvd:55;
 	} ii_ibct1_fld_s;
 } ii_ibct1_u_t;
 
@@ -2669,11 +2669,11 @@ typedef union ii_ibct1_u {
  ************************************************************************/
 
 typedef union ii_ibna1_u {
-	uint64_t ii_ibna1_regval;
+	u64 ii_ibna1_regval;
 	struct {
-		uint64_t i_rsvd_1:7;
-		uint64_t i_addr:33;
-		uint64_t i_rsvd:24;
+		u64 i_rsvd_1:7;
+		u64 i_addr:33;
+		u64 i_rsvd:24;
 	} ii_ibna1_fld_s;
 } ii_ibna1_u_t;
 
@@ -2686,13 +2686,13 @@ typedef union ii_ibna1_u {
  ************************************************************************/
 
 typedef union ii_ibia1_u {
-	uint64_t ii_ibia1_regval;
+	u64 ii_ibia1_regval;
 	struct {
-		uint64_t i_pi_id:1;
-		uint64_t i_node_id:8;
-		uint64_t i_rsvd_1:7;
-		uint64_t i_level:7;
-		uint64_t i_rsvd:41;
+		u64 i_pi_id:1;
+		u64 i_node_id:8;
+		u64 i_rsvd_1:7;
+		u64 i_level:7;
+		u64 i_rsvd:41;
 	} ii_ibia1_fld_s;
 } ii_ibia1_u_t;
 
@@ -2712,12 +2712,12 @@ typedef union ii_ibia1_u {
  ************************************************************************/
 
 typedef union ii_ipcr_u {
-	uint64_t ii_ipcr_regval;
+	u64 ii_ipcr_regval;
 	struct {
-		uint64_t i_ippr0_c:4;
-		uint64_t i_ippr1_c:4;
-		uint64_t i_icct:8;
-		uint64_t i_rsvd:48;
+		u64 i_ippr0_c:4;
+		u64 i_ippr1_c:4;
+		u64 i_icct:8;
+		u64 i_rsvd:48;
 	} ii_ipcr_fld_s;
 } ii_ipcr_u_t;
 
@@ -2728,10 +2728,10 @@ typedef union ii_ipcr_u {
  ************************************************************************/
 
 typedef union ii_ippr_u {
-	uint64_t ii_ippr_regval;
+	u64 ii_ippr_regval;
 	struct {
-		uint64_t i_ippr0:32;
-		uint64_t i_ippr1:32;
+		u64 i_ippr0:32;
+		u64 i_ippr1:32;
 	} ii_ippr_fld_s;
 } ii_ippr_u_t;
 
@@ -3267,15 +3267,15 @@ typedef ii_icrb0_e_u_t icrbe_t;
 #define IO_PERF_SETS	32
 
 /* Bit for the widget in inbound access register */
-#define IIO_IIWA_WIDGET(_w)	((uint64_t)(1ULL << _w))
+#define IIO_IIWA_WIDGET(_w)	((u64)(1ULL << _w))
 /* Bit for the widget in outbound access register */
-#define IIO_IOWA_WIDGET(_w)	((uint64_t)(1ULL << _w))
+#define IIO_IOWA_WIDGET(_w)	((u64)(1ULL << _w))
 
 /* NOTE: The following define assumes that we are going to get
  * widget numbers from 8 thru F and the device numbers within
  * widget from 0 thru 7.
  */
-#define IIO_IIDEM_WIDGETDEV_MASK(w, d)	((uint64_t)(1ULL << (8 * ((w) - 8) + (d))))
+#define IIO_IIDEM_WIDGETDEV_MASK(w, d)	((u64)(1ULL << (8 * ((w) - 8) + (d))))
 
 /* IO Interrupt Destination Register */
 #define IIO_IIDSR_SENT_SHIFT    28
@@ -3302,9 +3302,9 @@ typedef ii_icrb0_e_u_t icrbe_t;
  */
 
 typedef union hubii_wcr_u {
-	uint64_t wcr_reg_value;
+	u64 wcr_reg_value;
 	struct {
-		uint64_t wcr_widget_id:4,	/* LLP crossbar credit */
+		u64 wcr_widget_id:4,	/* LLP crossbar credit */
 		 wcr_tag_mode:1,	/* Tag mode */
 		 wcr_rsvd1:8,	/* Reserved */
 		 wcr_xbar_crd:3,	/* LLP crossbar credit */
@@ -3324,9 +3324,9 @@ performance registers */
    performed */
 
 typedef union io_perf_sel {
-	uint64_t perf_sel_reg;
+	u64 perf_sel_reg;
 	struct {
-		uint64_t perf_ippr0:4, perf_ippr1:4, perf_icct:8, perf_rsvd:48;
+		u64 perf_ippr0:4, perf_ippr1:4, perf_icct:8, perf_rsvd:48;
 	} perf_sel_bits;
 } io_perf_sel_t;
 
@@ -3334,24 +3334,24 @@ typedef union io_perf_sel {
    hardware problems there is only one counter, not two. */
 
 typedef union io_perf_cnt {
-	uint64_t perf_cnt;
+	u64 perf_cnt;
 	struct {
-		uint64_t perf_cnt:20, perf_rsvd2:12, perf_rsvd1:32;
+		u64 perf_cnt:20, perf_rsvd2:12, perf_rsvd1:32;
 	} perf_cnt_bits;
 
 } io_perf_cnt_t;
 
 typedef union iprte_a {
-	uint64_t entry;
+	u64 entry;
 	struct {
-		uint64_t i_rsvd_1:3;
-		uint64_t i_addr:38;
-		uint64_t i_init:3;
-		uint64_t i_source:8;
-		uint64_t i_rsvd:2;
-		uint64_t i_widget:4;
-		uint64_t i_to_cnt:5;
-		uint64_t i_vld:1;
+		u64 i_rsvd_1:3;
+		u64 i_addr:38;
+		u64 i_init:3;
+		u64 i_source:8;
+		u64 i_rsvd:2;
+		u64 i_widget:4;
+		u64 i_to_cnt:5;
+		u64 i_vld:1;
 	} iprte_fields;
 } iprte_a_t;
 
