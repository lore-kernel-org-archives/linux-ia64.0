From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 19 Mar 2004 01:48:11 +0000
Subject: Re: [3/3] claim PCI resources on ia64
Message-Id: <16474.20827.21678.283540@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040318235024.GH25059@parcelfarce.linux.theplanet.co.uk>
	<20040318235250.GK25059@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040318235250.GK25059@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@zip.com.au>
Cc: Matthew Wilcox <willy@debian.org>, Greg KH <greg@kroah.com>, David Mosberger <davidm@hpl.hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Matthew tells me that applying this patch without the others will result
in error messages (harmless, but still...).  I'm OK with the patch, so
I'd appreciate it if whoever takes the other patches could apply this
one, too.

Thanks,

-----------------------------------------------------------------------
From: Matthew Wilcox <willy@debian.org>
Sender: <willy@www.linux.org.uk>
To: Matthew Wilcox <willy@debian.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@zip.com.au>,
        Greg KH <greg@kroah.com>, David Mosberger <davidm@hpl.hp.com>,
        linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Subject: [3/3] claim PCI resources on ia64
Date: Thu, 18 Mar 2004 23:52:50 +0000


Call pci_claim_resources() so we can see what PCI resources are being used.

Index: arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/pci/pci.c,v
retrieving revision 1.7
diff -u -p -r1.7 pci.c
--- a/arch/ia64/pci/pci.c	16 Mar 2004 15:39:51 -0000	1.7
+++ b/arch/ia64/pci/pci.c	18 Mar 2004 23:40:52 -0000
@@ -367,6 +366,7 @@ pcibios_fixup_device_resources (struct p
 				dev->resource[i].end   += window->offset;
 			}
 		}
+		pci_claim_resource(dev, i);
 	}
 }
 

-- 
