From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 01 Apr 2004 21:28:12 +0000
Subject: [PATCH] bring ia64 nodes online properly
Message-Id: <200404011328.12544.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_slIbAafy5PYVIU3"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_slIbAafy5PYVIU3
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Andi's libnuma exposed the fact that we don't bring nodes online properly as 
we discover them in ia64.  Here's a quick patch to fix that.  Tested with 
Andi's numademo program; seems to work fine.

Jesse

--Boundary-00=_slIbAafy5PYVIU3
Content-Type: text/plain;
  charset="us-ascii";
  name="node-set-online.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="node-set-online.patch"

===== arch/ia64/kernel/acpi.c 1.65 vs edited =====
--- 1.65/arch/ia64/kernel/acpi.c	Sat Mar 20 21:28:40 2004
+++ edited/arch/ia64/kernel/acpi.c	Thu Apr  1 13:20:58 2004
@@ -455,6 +455,7 @@
 	for (i = 0; i < MAX_PXM_DOMAINS; i++) {
 		if (pxm_bit_test(i)) {
 			pxm_to_nid_map[i] = numnodes;
+			node_set_online(numnodes);
 			nid_to_pxm_map[numnodes++] = i;
 		}
 	}

--Boundary-00=_slIbAafy5PYVIU3--
