From: Matthew Wilcox <willy@debian.org>
Date: Sat, 14 Aug 2004 22:05:37 +0000
Subject: [PATCH] Don't allow hw_random to be selected on ia64
Message-Id: <20040814220537.GD12936@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The hw_random driver includes some i386 asm so won't compile on ia64.

diff -urpNX dontdiff linus-2.6/drivers/char/Kconfig parisc-2.6/drivers/char/Kconfig
--- linus-2.6/drivers/char/Kconfig	Sat Aug 14 11:16:31 2004
+++ parisc-2.6/drivers/char/Kconfig	Sat Aug 14 11:05:28 2004
@@ -689,7 +689,7 @@ config NWFLASH
 
 config HW_RANDOM
 	tristate "Intel/AMD/VIA HW Random Number Generator support"
-	depends on (X86 || IA64) && PCI
+	depends on X86 && PCI
 	---help---
 	  This driver provides kernel-side support for the Random Number
 	  Generator hardware found on Intel i8xx-based motherboards,

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
