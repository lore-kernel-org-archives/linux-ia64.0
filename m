From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 02 Feb 2005 22:19:18 +0000
Subject: PATCH: Fix 2.6 kernel ia64 directives
Message-Id: <20050202221918.GA7973@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The new ia64 assembler caught a few directive bugs. Here is the patch.
 

H.J.
--- linux-2.6.9/arch/ia64/kernel/ivt.S.unwind	2004-10-18 14:53:22.000000000 -0700
+++ linux-2.6.9/arch/ia64/kernel/ivt.S	2005-02-02 12:00:27.562232125 -0800
@@ -547,7 +547,7 @@ ENTRY(dirty_bit)
 #endif
 	mov pr=r31,-1				// restore pr
 	rfi
-END(idirty_bit)
+END(dirty_bit)
 
 	.org ia64_ivt+0x2400
 /////////////////////////////////////////////////////////////////////////////////////////
