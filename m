From: Keith Owens <kaos@sgi.com>
Date: Wed, 12 Jan 2005 07:07:26 +0000
Subject: Re: Linux 2.6.11-rc1
Message-Id: <23675.1105513646@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Tue, 11 Jan 2005 21:09:21 -0800."
             <Pine.LNX.4.58.0501112100250.2373@ppc970.osdl.org> 
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tue, 11 Jan 2005 21:09:21 -0800 (PST), 
Linus Torvalds <torvalds@osdl.org> wrote:
>Ok, the big merges after 2.6.10 are hopefully over, and 2.6.11-rc1 is out 
>there.

Export pcibios_resource_to_bus in ia64 to match other architectures.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/pci/pci.c
=================================--- linux.orig/arch/ia64/pci/pci.c	2005-01-12 17:07:23.000000000 +1100
+++ linux/arch/ia64/pci/pci.c	2005-01-12 18:04:12.000000000 +1100
@@ -367,6 +367,7 @@ void pcibios_resource_to_bus(struct pci_
 	region->start = res->start - offset;
 	region->end = res->end - offset;
 }
+EXPORT_SYMBOL(pcibios_resource_to_bus);
 
 void pcibios_bus_to_resource(struct pci_dev *dev,
 		struct resource *res, struct pci_bus_region *region)

