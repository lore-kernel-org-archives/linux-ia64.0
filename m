From: Christian Hildner <christian.hildner@hob.de>
Date: Thu, 11 Jul 2002 12:33:59 +0000
Subject: [Linux-ia64] /proc/pal/.../tr_info
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------A4C7EA7716679E2C1ECB3A84"
Message-Id: <marc-linux-ia64-105590701905764@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

Dies ist eine mehrteilige Nachricht im MIME-Format.
--------------A4C7EA7716679E2C1ECB3A84
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi!

I made a patch for arch/ia64/kernel/palinfo.c that gives more
information when calling tr_info. Please check and apply if you agree.
The patch is relative to 2.4.18.

Christian
--------------A4C7EA7716679E2C1ECB3A84
Content-Type: text/plain; charset=us-ascii;
 name="palinfo.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="palinfo.patch"

--- palinfo.c_orig	Tue Mar 19 11:22:28 2002
+++ palinfo.c	Thu Jul 11 11:26:53 2002
@@ -13,6 +13,7 @@
  * 08/21/2000	S.Eranian	updated to July 2000 PAL specs
  * 02/05/2001   S.Eranian	fixed module support
  * 10/23/2001	S.Eranian	updated pal_perf_mon_info bug fixes
+ * 07/11/2002   C.Hildner	changes in tr_info (christian.hildner@hob.de)
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -681,8 +682,7 @@
 	int i, j;
 	u64 max[3], pgm;
 	struct ifa_reg {
-		u64 valid:1;
-		u64 ig:11;
+		u64 ig:12;
 		u64 vpn:52;
 	} *ifa_reg;
 	struct itir_reg {
@@ -730,7 +730,7 @@
 
 		ifa_reg  = (struct ifa_reg *)&tr_buffer[2];
 
-		if (ifa_reg->valid == 0) continue;
+		if ((ifa_reg->ig & 1) == 0) continue;	// PAL is setting this bit if translation is valid
 
 		gr_reg   = (struct gr_reg *)tr_buffer;
 		itir_reg = (struct itir_reg *)&tr_buffer[1];
@@ -738,33 +738,51 @@
 
 		pgm	 = -1 << (itir_reg->ps - 12);
 		p += sprintf(p, "%cTR%d: av=%d pv=%d dv=%d mv=%d\n" \
-				"\tppn  : 0x%lx\n" \
-				"\tvpn  : 0x%lx\n" \
-				"\tps   : ",
-
+				"\tgr.ig    : 0x%03x\n" \
+				"\tgr.ed    : %d\n" \
+				"\tgr.ppn   : 0x%010lx  (ppn 0x%016lx)\n" \
+				"\tgr.ar    : %d\n" \
+				"\tgr.pl    : %d\n" \
+				"\tgr.d     : %d\n" \
+				"\tgr.a     : %d\n" \
+				"\tgr.ma    : %d\n" \
+				"\tgr.p     : %d\n" \
+				"\titir.key : 0x%06x\n" \
+				"\titir.ps  : %d  (Pagesize ",
 				"ID"[i],
 				j,
 				tr_valid.pal_tr_valid_s.access_rights_valid,
 				tr_valid.pal_tr_valid_s.priv_level_valid,
 				tr_valid.pal_tr_valid_s.dirty_bit_valid,
 				tr_valid.pal_tr_valid_s.mem_attr_valid,
-				(gr_reg->ppn & pgm)<< 12,
-				(ifa_reg->vpn & pgm)<< 12);
+				gr_reg->ig, 
+				gr_reg->ed,
+				gr_reg->ppn,
+				(gr_reg->ppn & pgm) << 12,
+				gr_reg->ar,
+				gr_reg->pl,
+				gr_reg->d,
+				gr_reg->a,
+				gr_reg->ma,
+				gr_reg->p,
+				itir_reg->key,
+				itir_reg->ps);
 
 		p = bitvector_process(p, 1<< itir_reg->ps);
 
-		p += sprintf(p, "\n\tpl   : %d\n" \
-				"\tar   : %d\n" \
-				"\trid  : %x\n" \
-				"\tp    : %d\n" \
-				"\tma   : %d\n" \
-				"\td    : %d\n",
-				gr_reg->pl,
-				gr_reg->ar,
+		p += sprintf(p, ")\n" \
+				"\tifa.vpn  : 0x%013lx  (vpn 0x%016lx region %ld)\n" \
+				"\tifa.ig   : 0x%03x\n" \
+				"\trr.rid   : 0x%06x\n" \
+				"\trr.ig2   : 0x%02x\n" \
+				"\trr.ig1   : %d\n",
+				ifa_reg->vpn,
+				(ifa_reg->vpn & pgm) << 12,
+				ifa_reg->vpn >> 49,
+				ifa_reg->ig,
 				rid_reg->rid,
-				gr_reg->p,
-				gr_reg->ma,
-				gr_reg->d);
+				rid_reg->ig2,
+				rid_reg->ig1);
 		}
 	}
 	return p - page;


--------------A4C7EA7716679E2C1ECB3A84--


