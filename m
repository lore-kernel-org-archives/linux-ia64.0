From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 07 Aug 2003 15:52:15 +0000
Subject: Re: [PATCH] trivial 2.4/2.6 PCI name change/addition
Message-Id: <marc-linux-ia64-106027200822148@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106019991620116@msgid-missing>
In-Reply-To: <marc-linux-ia64-106019991620116@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 07 August 2003 6:32 am, Marcelo Tosatti wrote:
> On Wed, 6 Aug 2003, Bjorn Helgaas wrote:
> > On Wednesday 06 August 2003 1:54 pm, Alex Williamson wrote:
> > >    This patch renames the PCI-X adapter found in HP zx1 and sx1000
> > > ia64 systems to something more generic and descriptive.  It also
> > > adds an ID for the PCI adapter used in sx1000.  Patches against
> > > 2.4.21+ia64 and 2.6.0-test2+ia64 attached.  Thanks,
> > 
> > I applied this for the 2.4 ia64 patch.
> > 
> > Marcelo, do we need to do anything else to get this in your tree?
> 
> 
> Actually this doesnt apply cleanly to my tree Bjorn.
> 
> Can you please send me an updated patch? 

Oops, sorry about that.  Here's an updated one.  It doesn't include
the agpgart bit because you don't have the latest HP ZX1 gart
code.  I'll try to get that merged up soon.


=== drivers/pci/pci.ids 1.37 vs edited ==--- 1.37/drivers/pci/pci.ids	Sun Jun 29 09:10:14 2003
+++ edited/drivers/pci/pci.ids	Thu Aug  7 10:43:57 2003
@@ -1348,6 +1348,7 @@
 		103c 1226  Keystone SP2
 		103c 1227  Powerbar SP2
 		103c 1282  Everest SP2
+	1054  PCI Local Bus Adapter
 	1064  79C970 PCnet Ethernet Controller
 	108b  Visualize FXe
 	10c1  NetServer Smart IRQ Router
@@ -1359,7 +1360,8 @@
 	121c  NetServer PCI COM Port Decoder
 	1229  zx1 System Bus Adapter
 	122a  zx1 I/O Controller
-	122e  zx1 Local Bus Adapter
+	122e  PCI-X/AGP Local Bus Adapter
+	127c  sx1000 I/O Controller
 	1290  Auxiliary Diva Serial Port
 	2910  E2910A PCIBus Exerciser
 	2925  E2925A 32 Bit, 33 MHzPCI Exerciser & Analyzer
=== include/linux/pci_ids.h 1.67 vs edited ==--- 1.67/include/linux/pci_ids.h	Tue Aug  5 09:37:33 2003
+++ edited/include/linux/pci_ids.h	Thu Aug  7 10:38:29 2003
@@ -589,11 +589,13 @@
 #define PCI_DEVICE_ID_HP_DIVA1		0x1049
 #define PCI_DEVICE_ID_HP_DIVA2		0x104A
 #define PCI_DEVICE_ID_HP_SP2_0		0x104B
+#define PCI_DEVICE_ID_HP_PCI_LBA	0x1054
 #define PCI_DEVICE_ID_HP_REO_SBA	0x10f0
 #define PCI_DEVICE_ID_HP_REO_IOC	0x10f1
 #define PCI_DEVICE_ID_HP_ZX1_SBA	0x1229
 #define PCI_DEVICE_ID_HP_ZX1_IOC	0x122a
-#define PCI_DEVICE_ID_HP_ZX1_LBA	0x122e
+#define PCI_DEVICE_ID_HP_PCIX_LBA	0x122e
+#define PCI_DEVICE_ID_HP_SX1000_IOC	0x127c
 
 #define PCI_VENDOR_ID_PCTECH		0x1042
 #define PCI_DEVICE_ID_PCTECH_RZ1000	0x1000

