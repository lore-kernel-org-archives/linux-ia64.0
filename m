From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 29 Mar 2004 18:55:48 +0000
Subject: [PATCH] clean up pcibr_slot.c warnings
Message-Id: <200403291055.48664.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_0EHaA1RLHM3Qn74"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_0EHaA1RLHM3Qn74
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

A few warnings crept into pcibr_slot.c that this patch takes care of.
  - forward declare pcibr_slot_pwr so it can be used w/o warning
  - fix argument passed to pcibr_slot_attach in pcibr_slot_enable

Jesse

--Boundary-00=_0EHaA1RLHM3Qn74
Content-Type: text/plain;
  charset="us-ascii";
  name="pcibr_slot-warning-fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="pcibr_slot-warning-fixes.patch"

===== arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c 1.19 vs edited =====
--- 1.19/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c	Thu Feb 19 09:12:31 2004
+++ edited/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c	Mon Mar 29 10:47:03 2004
@@ -47,6 +47,7 @@
 cfg_p pcibr_find_capability(cfg_p, unsigned);
 extern uint64_t  do_pcibr_config_get(cfg_p, unsigned, unsigned);
 void do_pcibr_config_set(cfg_p, unsigned, unsigned, uint64_t); 
+int pcibr_slot_pwr(vertex_hdl_t pcibr_vhdl, pciio_slot_t slot, int up, char *err_msg);
 
 
 /* 
@@ -351,7 +352,7 @@
         goto enable_unlock;
     }
 
-    error = pcibr_slot_attach(pcibr_vhdl, slot, NULL,
+    error = pcibr_slot_attach(pcibr_vhdl, slot, 0,
                               req_p->req_resp.resp_l1_msg,
 			      &req_p->req_resp.resp_sub_errno);
 

--Boundary-00=_0EHaA1RLHM3Qn74--
