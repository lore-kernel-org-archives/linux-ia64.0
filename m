From: Matthew Wilcox <willy@debian.org>
Date: Mon, 23 Feb 2004 19:18:57 +0000
Subject: [PATCH] SAL version is not zero-padded
Message-Id: <20040223191857.GE25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


SAL is version 3.1, not 3.01.

diff -urpNX build-tools/dontdiff linus-2.6/arch/ia64/kernel/sal.c pciexp-2.6/arch/ia64/kernel/sal.c
--- linus-2.6/arch/ia64/kernel/sal.c	2003-07-29 13:00:27.000000000 -0400
+++ pciexp-2.6/arch/ia64/kernel/sal.c	2004-02-23 11:53:12.000000000 -0500
@@ -106,7 +106,7 @@ ia64_sal_init (struct ia64_sal_systab *s
 	/*
 	 * revisions are coded in BCD, so %x does the job for us
 	 */
-	printk(KERN_INFO "SAL v%x.%02x: oem=%.32s, product=%.32s\n",
+	printk(KERN_INFO "SAL v%x.%x: oem=%.32s, product=%.32s\n",
 	       systab->sal_rev_major, systab->sal_rev_minor,
 	       systab->oem_id, systab->product_id);
 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
