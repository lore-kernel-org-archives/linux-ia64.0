From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 14 Oct 2004 02:30:27 +0000
Subject: [PATCH] uninitialised flags element could cause crashes
Message-Id: <20041014023027.GK16153@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


window is not zeroed, so the flags should be assigned, not modified.
This can lead to crashes at boot if the IO and Memory resources overlap.

Index: pci-2.6/arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/pci/pci.c,v
retrieving revision 1.15
diff -u -p -r1.15 pci.c
--- pci-2.6/arch/ia64/pci/pci.c	30 Sep 2004 12:07:43 -0000	1.15
+++ pci-2.6/arch/ia64/pci/pci.c	14 Oct 2004 02:07:10 -0000
@@ -275,7 +275,7 @@ add_window (struct acpi_resource *res, v
 			return AE_OK;
 
 		window = &info->controller->window[info->controller->windows++];
-		window->resource.flags |= flags;
+		window->resource.flags	= flags;
 		window->resource.start  = addr.min_address_range;
 		window->resource.end    = addr.max_address_range;
 		window->offset		= offset;

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
