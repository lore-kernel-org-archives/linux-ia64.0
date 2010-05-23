From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sun, 23 May 2010 20:01:50 +0000
Subject: [PATCH 154/199] arch/ia64/kernel/unwind_decoder.c: Checkpatch cleanup
Message-Id: <1274644930-26600-6-git-send-email-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/kernel/unwind_decoder.c:14: ERROR: trailing whitespace
arch/ia64/kernel/unwind_decoder.c:66: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:72: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:72: WARNING: suspect code indent for conditional statements (2, 6)
arch/ia64/kernel/unwind_decoder.c:85: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:91: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:92: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:94: WARNING: suspect code indent for conditional statements (2, 10)
arch/ia64/kernel/unwind_decoder.c:102: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:108: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:112: WARNING: suspect code indent for conditional statements (2, 4)
arch/ia64/kernel/unwind_decoder.c:120: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:126: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:127: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:132: WARNING: suspect code indent for conditional statements (2, 4)
arch/ia64/kernel/unwind_decoder.c:140: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:146: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:153: WARNING: suspect code indent for conditional statements (2, 4)
arch/ia64/kernel/unwind_decoder.c:161: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:172: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:181: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:187: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:191: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:197: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:206: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:208: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:208: WARNING: suspect code indent for conditional statements (2, 6)
arch/ia64/kernel/unwind_decoder.c:215: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:215: WARNING: suspect code indent for conditional statements (2, 6)
arch/ia64/kernel/unwind_decoder.c:221: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:223: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:224: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:225: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:226: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:227: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:228: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:229: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:230: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:231: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:232: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:233: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:234: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:235: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:238: WARNING: suspect code indent for conditional statements (2, 4)
arch/ia64/kernel/unwind_decoder.c:240: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:240: WARNING: suspect code indent for conditional statements (2, 6)
arch/ia64/kernel/unwind_decoder.c:255: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:260: WARNING: suspect code indent for conditional statements (2, 4)
arch/ia64/kernel/unwind_decoder.c:268: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:273: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:273: WARNING: suspect code indent for conditional statements (2, 6)
arch/ia64/kernel/unwind_decoder.c:276: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:277: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:280: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:284: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:285: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:286: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:287: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:288: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:289: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:290: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:291: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:292: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:293: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:294: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:295: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:296: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:297: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:298: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:299: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:302: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:304: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:309: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:310: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:312: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:313: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:314: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:315: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:316: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:317: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:318: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:319: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:320: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:321: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:322: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:323: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:324: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:325: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:326: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:327: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:328: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:329: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:330: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:331: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:347: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:350: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:353: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:356: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:367: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:371: WARNING: suspect code indent for conditional statements (2, 4)
arch/ia64/kernel/unwind_decoder.c:379: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:383: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:389: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:393: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:393: WARNING: suspect code indent for conditional statements (2, 6)
arch/ia64/kernel/unwind_decoder.c:395: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:396: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:399: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:399: WARNING: suspect code indent for conditional statements (2, 6)
arch/ia64/kernel/unwind_decoder.c:401: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:408: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:410: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:411: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:412: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:413: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/unwind_decoder.c:414: ERROR: trailing statements should be on next line
arch/ia64/kernel/unwind_decoder.c:422: ERROR: that open brace { should be on the previous line
arch/ia64/kernel/unwind_decoder.c:450: WARNING: space prohibited between function name and open parenthesis '('

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/kernel/unwind_decoder.c |  328 +++++++++++++++++--------------------
 1 files changed, 153 insertions(+), 175 deletions(-)

diff --git a/arch/ia64/kernel/unwind_decoder.c b/arch/ia64/kernel/unwind_decoder.c
index 50ac2d8..e59708b 100644
--- a/arch/ia64/kernel/unwind_decoder.c
+++ b/arch/ia64/kernel/unwind_decoder.c
@@ -11,7 +11,7 @@
  * macros/constants before including this file:
  *
  *  Types:
- *	unw_word	Unsigned integer type with at least 64 bits 
+ *	unw_word	Unsigned integer type with at least 64 bits
  *
  *  Register names:
  *	UNW_REG_BSP
@@ -63,33 +63,32 @@
  */
 
 static unw_word
-unw_decode_uleb128 (unsigned char **dpp)
+unw_decode_uleb128(unsigned char **dpp)
 {
   unsigned shift = 0;
   unw_word byte, result = 0;
   unsigned char *bp = *dpp;
 
-  while (1)
-    {
-      byte = *bp++;
-      result |= (byte & 0x7f) << shift;
-      if ((byte & 0x80) = 0)
-	break;
-      shift += 7;
-    }
-  *dpp = bp;
-  return result;
+while (1) {
+	byte = *bp++;
+	result |= (byte & 0x7f) << shift;
+	if ((byte & 0x80) = 0)
+		break;
+	shift += 7;
+}
+	*dpp = bp;
+	return result;
 }
 
 static unsigned char *
-unw_decode_x1 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_x1(unsigned char *dp, unsigned char code, void *arg)
 {
   unsigned char byte1, abreg;
   unw_word t, off;
 
   byte1 = *dp++;
-  t = unw_decode_uleb128 (&dp);
-  off = unw_decode_uleb128 (&dp);
+  t = unw_decode_uleb128(&dp);
+  off = unw_decode_uleb128(&dp);
   abreg = (byte1 & 0x7f);
   if (byte1 & 0x80)
 	  UNW_DEC_SPILL_SPREL(X1, t, abreg, off, arg);
@@ -99,7 +98,7 @@ unw_decode_x1 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_x2 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_x2(unsigned char *dp, unsigned char code, void *arg)
 {
   unsigned char byte1, byte2, abreg, x, ytreg;
   unw_word t;
@@ -117,14 +116,14 @@ unw_decode_x2 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_x3 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_x3(unsigned char *dp, unsigned char code, void *arg)
 {
   unsigned char byte1, byte2, abreg, qp;
   unw_word t, off;
 
   byte1 = *dp++; byte2 = *dp++;
-  t = unw_decode_uleb128 (&dp);
-  off = unw_decode_uleb128 (&dp);
+  t = unw_decode_uleb128(&dp);
+  off = unw_decode_uleb128(&dp);
 
   qp = (byte1 & 0x3f);
   abreg = (byte2 & 0x7f);
@@ -137,13 +136,13 @@ unw_decode_x3 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_x4 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_x4(unsigned char *dp, unsigned char code, void *arg)
 {
   unsigned char byte1, byte2, byte3, qp, abreg, x, ytreg;
   unw_word t;
 
   byte1 = *dp++; byte2 = *dp++; byte3 = *dp++;
-  t = unw_decode_uleb128 (&dp);
+  t = unw_decode_uleb128(&dp);
 
   qp = (byte1 & 0x3f);
   abreg = (byte2 & 0x7f);
@@ -158,7 +157,7 @@ unw_decode_x4 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_r1 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_r1(unsigned char *dp, unsigned char code, void *arg)
 {
   int body = (code & 0x20) != 0;
   unw_word rlen;
@@ -169,7 +168,7 @@ unw_decode_r1 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_r2 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_r2(unsigned char *dp, unsigned char code, void *arg)
 {
   unsigned char byte1, mask, grsave;
   unw_word rlen;
@@ -184,7 +183,7 @@ unw_decode_r2 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_r3 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_r3(unsigned char *dp, unsigned char code, void *arg)
 {
   unw_word rlen;
 
@@ -194,7 +193,7 @@ unw_decode_r3 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_p1 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_p1(unsigned char *dp, unsigned char code, void *arg)
 {
   unsigned char brmask = (code & 0x1f);
 
@@ -203,56 +202,49 @@ unw_decode_p1 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_p2_p5 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_p2_p5(unsigned char *dp, unsigned char code, void *arg)
 {
-  if ((code & 0x10) = 0)
-    {
-      unsigned char byte1 = *dp++;
-
-      UNW_DEC_BR_GR(P2, ((code & 0xf) << 1) | ((byte1 >> 7) & 1),
-		    (byte1 & 0x7f), arg);
-    }
-  else if ((code & 0x08) = 0)
-    {
-      unsigned char byte1 = *dp++, r, dst;
-
-      r = ((code & 0x7) << 1) | ((byte1 >> 7) & 1);
-      dst = (byte1 & 0x7f);
-      switch (r)
-	{
-	case 0: UNW_DEC_REG_GR(P3, UNW_REG_PSP, dst, arg); break;
-	case 1: UNW_DEC_REG_GR(P3, UNW_REG_RP, dst, arg); break;
-	case 2: UNW_DEC_REG_GR(P3, UNW_REG_PFS, dst, arg); break;
-	case 3: UNW_DEC_REG_GR(P3, UNW_REG_PR, dst, arg); break;
-	case 4: UNW_DEC_REG_GR(P3, UNW_REG_UNAT, dst, arg); break;
-	case 5: UNW_DEC_REG_GR(P3, UNW_REG_LC, dst, arg); break;
-	case 6: UNW_DEC_RP_BR(P3, dst, arg); break;
-	case 7: UNW_DEC_REG_GR(P3, UNW_REG_RNAT, dst, arg); break;
-	case 8: UNW_DEC_REG_GR(P3, UNW_REG_BSP, dst, arg); break;
-	case 9: UNW_DEC_REG_GR(P3, UNW_REG_BSPSTORE, dst, arg); break;
-	case 10: UNW_DEC_REG_GR(P3, UNW_REG_FPSR, dst, arg); break;
-	case 11: UNW_DEC_PRIUNAT_GR(P3, dst, arg); break;
-	default: UNW_DEC_BAD_CODE(r); break;
-	}
-    }
-  else if ((code & 0x7) = 0)
-    UNW_DEC_SPILL_MASK(P4, dp, arg);
-  else if ((code & 0x7) = 1)
-    {
-      unw_word grmask, frmask, byte1, byte2, byte3;
-
-      byte1 = *dp++; byte2 = *dp++; byte3 = *dp++;
-      grmask = ((byte1 >> 4) & 0xf);
-      frmask = ((byte1 & 0xf) << 16) | (byte2 << 8) | byte3;
-      UNW_DEC_FRGR_MEM(P5, grmask, frmask, arg);
-    }
-  else
-    UNW_DEC_BAD_CODE(code);
-  return dp;
+if ((code & 0x10) = 0) {
+	unsigned char byte1 = *dp++;
+
+	UNW_DEC_BR_GR(P2, ((code & 0xf) << 1) | ((byte1 >> 7) & 1),
+		      (byte1 & 0x7f), arg);
+} else if ((code & 0x08) = 0) {
+		unsigned char byte1 = *dp++, r, dst;
+
+		r = ((code & 0x7) << 1) | ((byte1 >> 7) & 1);
+		dst = (byte1 & 0x7f);
+		switch (r) {
+		case 0: UNW_DEC_REG_GR(P3, UNW_REG_PSP, dst, arg); break;
+		case 1: UNW_DEC_REG_GR(P3, UNW_REG_RP, dst, arg); break;
+		case 2: UNW_DEC_REG_GR(P3, UNW_REG_PFS, dst, arg); break;
+		case 3: UNW_DEC_REG_GR(P3, UNW_REG_PR, dst, arg); break;
+		case 4: UNW_DEC_REG_GR(P3, UNW_REG_UNAT, dst, arg); break;
+		case 5: UNW_DEC_REG_GR(P3, UNW_REG_LC, dst, arg); break;
+		case 6: UNW_DEC_RP_BR(P3, dst, arg); break;
+		case 7: UNW_DEC_REG_GR(P3, UNW_REG_RNAT, dst, arg); break;
+		case 8: UNW_DEC_REG_GR(P3, UNW_REG_BSP, dst, arg); break;
+		case 9: UNW_DEC_REG_GR(P3, UNW_REG_BSPSTORE, dst, arg); break;
+		case 10: UNW_DEC_REG_GR(P3, UNW_REG_FPSR, dst, arg); break;
+		case 11: UNW_DEC_PRIUNAT_GR(P3, dst, arg); break;
+		default: UNW_DEC_BAD_CODE(r); break;
+		}
+	} else if ((code & 0x7) = 0)
+			UNW_DEC_SPILL_MASK(P4, dp, arg);
+	  else if ((code & 0x7) = 1) {
+			unw_word grmask, frmask, byte1, byte2, byte3;
+
+			byte1 = *dp++; byte2 = *dp++; byte3 = *dp++;
+			grmask = ((byte1 >> 4) & 0xf);
+			frmask = ((byte1 & 0xf) << 16) | (byte2 << 8) | byte3;
+			UNW_DEC_FRGR_MEM(P5, grmask, frmask, arg);
+		} else
+			UNW_DEC_BAD_CODE(code);
+return dp;
 }
 
 static unsigned char *
-unw_decode_p6 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_p6(unsigned char *dp, unsigned char code, void *arg)
 {
   int gregs = (code & 0x10) != 0;
   unsigned char mask = (code & 0x0f);
@@ -265,17 +257,15 @@ unw_decode_p6 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_p7_p10 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_p7_p10(unsigned char *dp, unsigned char code, void *arg)
 {
-  unsigned char r, byte1, byte2;
-  unw_word t, size;
-
-  if ((code & 0x10) = 0)
-    {
-      r = (code & 0xf);
-      t = unw_decode_uleb128 (&dp);
-      switch (r)
-	{
+unsigned char r, byte1, byte2;
+unw_word t, size;
+
+if ((code & 0x10) = 0) {
+	r = (code & 0xf);
+	t = unw_decode_uleb128 (&dp);
+	switch (r) {
 	case 0:
 	  size = unw_decode_uleb128 (&dp);
 	  UNW_DEC_MEM_STACK_F(P7, t, size, arg);
@@ -298,73 +288,68 @@ unw_decode_p7_p10 (unsigned char *dp, unsigned char code, void *arg)
 	case 15: UNW_DEC_REG_PSPREL(P7, UNW_REG_FPSR, t, arg); break;
 	default: UNW_DEC_BAD_CODE(r); break;
 	}
-    }
-  else
-    {
-      switch (code & 0xf)
-	{
-	case 0x0: /* p8 */
-	  {
-	    r = *dp++;
-	    t = unw_decode_uleb128 (&dp);
-	    switch (r)
-	      {
-	      case  1: UNW_DEC_REG_SPREL(P8, UNW_REG_RP, t, arg); break;
-	      case  2: UNW_DEC_REG_SPREL(P8, UNW_REG_PFS, t, arg); break;
-	      case  3: UNW_DEC_REG_SPREL(P8, UNW_REG_PR, t, arg); break;
-	      case  4: UNW_DEC_REG_SPREL(P8, UNW_REG_LC, t, arg); break;
-	      case  5: UNW_DEC_REG_SPREL(P8, UNW_REG_UNAT, t, arg); break;
-	      case  6: UNW_DEC_REG_SPREL(P8, UNW_REG_FPSR, t, arg); break;
-	      case  7: UNW_DEC_REG_WHEN(P8, UNW_REG_BSP, t, arg); break;
-	      case  8: UNW_DEC_REG_PSPREL(P8, UNW_REG_BSP, t, arg); break;
-	      case  9: UNW_DEC_REG_SPREL(P8, UNW_REG_BSP, t, arg); break;
-	      case 10: UNW_DEC_REG_WHEN(P8, UNW_REG_BSPSTORE, t, arg); break;
-	      case 11: UNW_DEC_REG_PSPREL(P8, UNW_REG_BSPSTORE, t, arg); break;
-	      case 12: UNW_DEC_REG_SPREL(P8, UNW_REG_BSPSTORE, t, arg); break;
-	      case 13: UNW_DEC_REG_WHEN(P8, UNW_REG_RNAT, t, arg); break;
-	      case 14: UNW_DEC_REG_PSPREL(P8, UNW_REG_RNAT, t, arg); break;
-	      case 15: UNW_DEC_REG_SPREL(P8, UNW_REG_RNAT, t, arg); break;
-	      case 16: UNW_DEC_PRIUNAT_WHEN_GR(P8, t, arg); break;
-	      case 17: UNW_DEC_PRIUNAT_PSPREL(P8, t, arg); break;
-	      case 18: UNW_DEC_PRIUNAT_SPREL(P8, t, arg); break;
-	      case 19: UNW_DEC_PRIUNAT_WHEN_MEM(P8, t, arg); break;
-	      default: UNW_DEC_BAD_CODE(r); break;
-	    }
-	  }
-	  break;
-
-	case 0x1:
-	  byte1 = *dp++; byte2 = *dp++;
-	  UNW_DEC_GR_GR(P9, (byte1 & 0xf), (byte2 & 0x7f), arg);
-	  break;
-
-	case 0xf: /* p10 */
-	  byte1 = *dp++; byte2 = *dp++;
-	  UNW_DEC_ABI(P10, byte1, byte2, arg);
-	  break;
-
-	case 0x9:
-	  return unw_decode_x1 (dp, code, arg);
-
-	case 0xa:
-	  return unw_decode_x2 (dp, code, arg);
-
-	case 0xb:
-	  return unw_decode_x3 (dp, code, arg);
-
-	case 0xc:
-	  return unw_decode_x4 (dp, code, arg);
-
-	default:
-	  UNW_DEC_BAD_CODE(code);
-	  break;
+    } else {
+		switch (code & 0xf) {
+			case 0x0: /* p8 */ {
+				r = *dp++;
+				t = unw_decode_uleb128 (&dp);
+				switch (r) {
+				case  1: UNW_DEC_REG_SPREL(P8, UNW_REG_RP, t, arg); break;
+				case  2: UNW_DEC_REG_SPREL(P8, UNW_REG_PFS, t, arg); break;
+				case  3: UNW_DEC_REG_SPREL(P8, UNW_REG_PR, t, arg); break;
+				case  4: UNW_DEC_REG_SPREL(P8, UNW_REG_LC, t, arg); break;
+				case  5: UNW_DEC_REG_SPREL(P8, UNW_REG_UNAT, t, arg); break;
+				case  6: UNW_DEC_REG_SPREL(P8, UNW_REG_FPSR, t, arg); break;
+				case  7: UNW_DEC_REG_WHEN(P8, UNW_REG_BSP, t, arg); break;
+				case  8: UNW_DEC_REG_PSPREL(P8, UNW_REG_BSP, t, arg); break;
+				case  9: UNW_DEC_REG_SPREL(P8, UNW_REG_BSP, t, arg); break;
+				case 10: UNW_DEC_REG_WHEN(P8, UNW_REG_BSPSTORE, t, arg); break;
+				case 11: UNW_DEC_REG_PSPREL(P8, UNW_REG_BSPSTORE, t, arg); break;
+				case 12: UNW_DEC_REG_SPREL(P8, UNW_REG_BSPSTORE, t, arg); break;
+				case 13: UNW_DEC_REG_WHEN(P8, UNW_REG_RNAT, t, arg); break;
+				case 14: UNW_DEC_REG_PSPREL(P8, UNW_REG_RNAT, t, arg); break;
+				case 15: UNW_DEC_REG_SPREL(P8, UNW_REG_RNAT, t, arg); break;
+				case 16: UNW_DEC_PRIUNAT_WHEN_GR(P8, t, arg); break;
+				case 17: UNW_DEC_PRIUNAT_PSPREL(P8, t, arg); break;
+				case 18: UNW_DEC_PRIUNAT_SPREL(P8, t, arg); break;
+				case 19: UNW_DEC_PRIUNAT_WHEN_MEM(P8, t, arg); break;
+				default: UNW_DEC_BAD_CODE(r); break;
+				}
+			}
+			break;
+
+			case 0x1:
+				byte1 = *dp++; byte2 = *dp++;
+				UNW_DEC_GR_GR(P9, (byte1 & 0xf), (byte2 & 0x7f), arg);
+				break;
+
+			case 0xf: /* p10 */
+				byte1 = *dp++; byte2 = *dp++;
+				UNW_DEC_ABI(P10, byte1, byte2, arg);
+				break;
+
+			case 0x9:
+				return unw_decode_x1(dp, code, arg);
+
+			case 0xa:
+				return unw_decode_x2(dp, code, arg);
+
+			case 0xb:
+				return unw_decode_x3(dp, code, arg);
+
+			case 0xc:
+				return unw_decode_x4(dp, code, arg);
+
+			default:
+				UNW_DEC_BAD_CODE(code);
+				break;
+		}
 	}
-    }
-  return dp;
+return dp;
 }
 
 static unsigned char *
-unw_decode_b1 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_b1(unsigned char *dp, unsigned char code, void *arg)
 {
   unw_word label = (code & 0x1f);
 
@@ -376,7 +361,7 @@ unw_decode_b1 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_b2 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_b2(unsigned char *dp, unsigned char code, void *arg)
 {
   unw_word t;
 
@@ -386,40 +371,33 @@ unw_decode_b2 (unsigned char *dp, unsigned char code, void *arg)
 }
 
 static unsigned char *
-unw_decode_b3_x4 (unsigned char *dp, unsigned char code, void *arg)
+unw_decode_b3_x4(unsigned char *dp, unsigned char code, void *arg)
 {
-  unw_word t, ecount, label;
-
-  if ((code & 0x10) = 0)
-    {
-      t = unw_decode_uleb128 (&dp);
-      ecount = unw_decode_uleb128 (&dp);
-      UNW_DEC_EPILOGUE(B3, t, ecount, arg);
-    }
-  else if ((code & 0x07) = 0)
-    {
-      label = unw_decode_uleb128 (&dp);
-      if ((code & 0x08) != 0)
-	UNW_DEC_COPY_STATE(B4, label, arg);
-      else
-	UNW_DEC_LABEL_STATE(B4, label, arg);
-    }
-  else
-    switch (code & 0x7)
-      {
-      case 1: return unw_decode_x1 (dp, code, arg);
-      case 2: return unw_decode_x2 (dp, code, arg);
-      case 3: return unw_decode_x3 (dp, code, arg);
-      case 4: return unw_decode_x4 (dp, code, arg);
-      default: UNW_DEC_BAD_CODE(code); break;
-      }
-  return dp;
+unw_word t, ecount, label;
+
+if ((code & 0x10) = 0) {
+	t = unw_decode_uleb128 (&dp);
+	ecount = unw_decode_uleb128 (&dp);
+	UNW_DEC_EPILOGUE(B3, t, ecount, arg);
+} else	if ((code & 0x07) = 0) {
+		label = unw_decode_uleb128 (&dp);
+		if ((code & 0x08) != 0)
+			UNW_DEC_COPY_STATE(B4, label, arg);
+		else
+			UNW_DEC_LABEL_STATE(B4, label, arg);
+	} else	switch (code & 0x7) {
+		case 1: return unw_decode_x1(dp, code, arg);
+		case 2: return unw_decode_x2(dp, code, arg);
+		case 3: return unw_decode_x3(dp, code, arg);
+		case 4: return unw_decode_x4(dp, code, arg);
+		default: UNW_DEC_BAD_CODE(code); break;
+		}
+return dp;
 }
 
 typedef unsigned char *(*unw_decoder) (unsigned char *, unsigned char, void *);
 
-static unw_decoder unw_decode_table[2][8] -{
+static unw_decoder unw_decode_table[2][8] = {
   /* prologue table: */
   {
     unw_decode_r1,	/* 0 */
@@ -447,7 +425,7 @@ static unw_decoder unw_decode_table[2][8]   * Decode one descriptor and return address of next descriptor.
  */
 static inline unsigned char *
-unw_decode (unsigned char *dp, int inside_body, void *arg)
+unw_decode(unsigned char *dp, int inside_body, void *arg)
 {
   unw_decoder decoder;
   unsigned char code;
-- 
1.7.1.251.gf80a2

