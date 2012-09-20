From: Stephan Schreiber <info@fs-driver.org>
Date: Thu, 20 Sep 2012 14:16:03 +0000
Subject: [RFC/PATCH v2] ia64, SR870, EFI bug breaks ata_piix, uninitialized ICH4 IDE EXBAR mem resource
Message-Id: <20120920161603.Horde.aF7BBcL8999QWyUjk2AmsNA@webmail.df.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120916183914.Horde._TGALdjz9kRQVgCy6ATxxJA@webmail.df.eu>
 <20120917115619.13d3a3cb@pyramind.ukuu.org.uk>
In-Reply-To: <20120917115619.13d3a3cb@pyramind.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, 679545@bugs.debian.org, jrnieder@gmail.com

description of the symptoms which you have already read on the initial =20
RFC/PATCH=3D=3D=3D>

Kernel 3.2.23 with Debian patches (Debian Wheezy, testing)
Debian bug#679545 (http://bugs.debian.org/cgi-bin/bugreport.cgi?bugg9545)

Machine: Dell PowerEdge 3250 (equivalent with Intel SR870BH2)
Processor: 2x Itanium Madison 1.5GHz 6M
Memory: 4GB

Intel ICH4 (82801DB), IDE host adapter. The ata_piix module fails to =20
initialize.

A snippet from dmesg:
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0-3-mckinley (Debian 3.2.23-1) =20
(debian-kernel@lists.debian.org) (gcc version 4.6.3 (Debian 4.6.3-8) ) =20
#1 SMP Mon Jul 23 09:01:02 UTC 2012
...
[    0.065516] pci 0000:00:1f.1: [8086:24cb] type 0 class 0x000101
[    0.065530] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.065541] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.065552] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
[    0.065563] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
[    0.065574] pci 0000:00:1f.1: reg 20: [io  0x1000-0x100f]
[    0.065585] pci 0000:00:1f.1: reg 24: [mem 0x00000000-0x000003ff]
...
[    1.640965] libata version 3.00 loaded.
[    1.641656] ata_piix 0000:00:1f.1: version 2.13
[    1.641671] ata_piix 0000:00:1f.1: device not available (can't =20
reserve [mem 0x00000000-0x000003ff])
[    1.641747] ata_piix: probe of 0000:00:1f.1 failed with error -22
...

lspci -vvxxx reports:

00:1f.1 IDE interface: Intel Corporation 82801DB (ICH4) IDE Controller =20
(rev 02) (prog-if 8a [Master SecP PriP])
	Subsystem: Intel Corporation Device 3404
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- =20
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- =20
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 0
	Region 0: I/O ports at 01f0 [size=3D8]
	Region 1: I/O ports at 03f4 [size=3D1]
	Region 2: I/O ports at 0170 [size=3D8]
	Region 3: I/O ports at 0374 [size=3D1]
	Region 4: I/O ports at 1000 [size=16]
00: 86 80 cb 24 05 00 80 02 02 8a 01 01 00 00 00 00
10: 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00
20: 01 10 00 00 00 00 00 00 00 00 00 00 86 80 04 34
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00
40: 03 a3 00 80 00 00 00 00 01 00 02 00 00 00 00 00
50: 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00
60: 08 00 00 00 00 00 00 00 08 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 60 0f 00 00 00 00 00 00


You can read in the "Intel 82801DB I/O Controller Hub 4 (ICH4)" datasheet
(http://www.intel.com/content/dam/www/public/us/en/documents/datasheets/828=
01db-io-controller-hub-4-datasheet.pdf)
about the EXBAR register at offset 0x24 (4 bytes):
"EXBAR register
This is a memory mapped BAR that requires 1 KB of DWord-aligned memory =20
that is Intel reserved
for future functionality. BIOS needs to program the base address for a =20
1-KB memory space."

The dump shows that EXBAR is 0x0000, equal to the default value after =20
reset; EFI doesn't initialize it.

ata_piix uses pcim_enable_device() which enables this along with the =20
I/O BARs. In systems based on the Intel SR870 platform the firmware =20
does not initialize the EXBAR and pcim_enable_device() fails because =20
the memory region 0x0-0x3FF cannot be allocated.

<=3D=3D=DEscription of the symptoms which you have already read on the =20
initial RFC/PATCH



> My only disagreement here would be putting it in the ia64 paths. If
> someone does the same for x86-32 (and this is EFI so it'll presumbly
> smell the same on all platforms) then we'll want the same.
>
> Better I think to generically catch the 0/0 case.
>
> Alan


Here is a new patch. It extends some existing code in =20
pci_setup_device() which maintains some hard-coded io regions on ide =20
controllers in legacy mode.
The idea is hiding an uninitialized EXBAR just as on the initial patch.
The patch is defensive; it does nothing if
- the controller isn't in legacy mode,
- BAR5 (EXBAR) isn't a memory resource, or
- BAR5 is already initialized.

The patch is generic because it works on both x86-32 and ia64 and also =20
for other ICH4 variants than my rare 82801DB_11 ICH4.
Even the added 'if' statement of this patch is also executed on IDE =20
controllers of other vendors than Intel or on other Intel ICHs, I =20
believe that it won't break anything.

Stephan



--- linux-3.2.23/drivers/pci/probe.c.orig	2012-07-12 05:32:21.000000000 +02=
00
+++ linux-3.2.23/drivers/pci/probe.c	2012-09-19 20:52:24.000000000 +0200
@@ -898,146 +898,158 @@ int pci_setup_device(struct pci_dev *dev
  {
  	u32 class;
  	u8 hdr_type;
  	struct pci_slot *slot;
  	int pos =3D 0;

  	if (pci_read_config_byte(dev, PCI_HEADER_TYPE, &hdr_type))
  		return -EIO;

  	dev->sysdata =3D dev->bus->sysdata;
  	dev->dev.parent =3D dev->bus->bridge;
  	dev->dev.bus =3D &pci_bus_type;
  	dev->hdr_type =3D hdr_type & 0x7f;
  	dev->multifunction =3D !!(hdr_type & 0x80);
  	dev->error_state =3D pci_channel_io_normal;
  	set_pcie_port_type(dev);

  	list_for_each_entry(slot, &dev->bus->slots, list)
  		if (PCI_SLOT(dev->devfn) =3D slot->number)
  			dev->slot =3D slot;

  	/* Assume 32-bit PCI; let 64-bit PCI cards (which are far rarer)
  	   set this higher, assuming the system even supports it.  */
  	dev->dma_mask =3D 0xffffffff;

  	dev_set_name(&dev->dev, "%04x:%02x:%02x.%d", pci_domain_nr(dev->bus),
  		     dev->bus->number, PCI_SLOT(dev->devfn),
  		     PCI_FUNC(dev->devfn));

  	pci_read_config_dword(dev, PCI_CLASS_REVISION, &class);
  	dev->revision =3D class & 0xff;
  	class >>=3D 8;				    /* upper 3 bytes */
  	dev->class =3D class;
  	class >>=3D 8;

  	dev_printk(KERN_DEBUG, &dev->dev, "[%04x:%04x] type %d class %#08x\n",
  		   dev->vendor, dev->device, dev->hdr_type, class);

  	/* need to have dev->class ready */
  	dev->cfg_size =3D pci_cfg_space_size(dev);

  	/* "Unknown power state" */
  	dev->current_state =3D PCI_UNKNOWN;

  	/* Early fixups, before probing the BARs */
  	pci_fixup_device(pci_fixup_early, dev);
  	/* device class may be changed after fixup */
  	class =3D dev->class >> 8;

  	switch (dev->hdr_type) {		    /* header type */
  	case PCI_HEADER_TYPE_NORMAL:		    /* standard header */
  		if (class =3D PCI_CLASS_BRIDGE_PCI)
  			goto bad;
  		pci_read_irq(dev);
  		pci_read_bases(dev, 6, PCI_ROM_ADDRESS);
  		pci_read_config_word(dev, PCI_SUBSYSTEM_VENDOR_ID, &dev->subsystem_vend=
or);
  		pci_read_config_word(dev, PCI_SUBSYSTEM_ID, &dev->subsystem_device);

  		/*
  		 *	Do the ugly legacy mode stuff here rather than broken chip
  		 *	quirk code. Legacy mode ATA controllers have fixed
  		 *	addresses. These are not always echoed in BAR0-3, and
  		 *	BAR0-3 in a few cases contain junk!
+		 *	BAR5 is a memory resource on Intel ICH4 which isn't
+		 *	functional at all. Some BIOS or EFI don't initialize
+		 *	it and would break ata_piix. If the controller is in
+		 *	legacy mode and BAR5 is an uninitialized memory
+		 *	resource, hide it.
  		 */
  		if (class =3D PCI_CLASS_STORAGE_IDE) {
  			u8 progif;
  			pci_read_config_byte(dev, PCI_CLASS_PROG, &progif);
  			if ((progif & 1) =3D 0) {
  				dev->resource[0].start =3D 0x1F0;
  				dev->resource[0].end =3D 0x1F7;
  				dev->resource[0].flags =3D LEGACY_IO_RESOURCE;
  				dev->resource[1].start =3D 0x3F6;
  				dev->resource[1].end =3D 0x3F6;
  				dev->resource[1].flags =3D LEGACY_IO_RESOURCE;
  			}
  			if ((progif & 4) =3D 0) {
  				dev->resource[2].start =3D 0x170;
  				dev->resource[2].end =3D 0x177;
  				dev->resource[2].flags =3D LEGACY_IO_RESOURCE;
  				dev->resource[3].start =3D 0x376;
  				dev->resource[3].end =3D 0x376;
  				dev->resource[3].flags =3D LEGACY_IO_RESOURCE;
  			}
+			if ((progif & 5) =3D 0
+			    && (dev->resource[5].flags & IORESOURCE_MEM)
+			    && dev->resource[5].start =3D 0
+			    && dev->resource[5].end !=3D 0) {
+				dev->resource[5].flags =3D 0;
+				dev->resource[5].end =3D 0;
+			}
  		}
  		break;

  	case PCI_HEADER_TYPE_BRIDGE:		    /* bridge header */
  		if (class !=3D PCI_CLASS_BRIDGE_PCI)
  			goto bad;
  		/* The PCI-to-PCI bridge spec requires that subtractive
  		   decoding (i.e. transparent) bridge must have programming
  		   interface code of 0x01. */
  		pci_read_irq(dev);
  		dev->transparent =3D ((dev->class & 0xff) =3D 1);
  		pci_read_bases(dev, 2, PCI_ROM_ADDRESS1);
  		set_pcie_hotplug_bridge(dev);
  		pos =3D pci_find_capability(dev, PCI_CAP_ID_SSVID);
  		if (pos) {
  			pci_read_config_word(dev, pos + PCI_SSVID_VENDOR_ID, =20
&dev->subsystem_vendor);
  			pci_read_config_word(dev, pos + PCI_SSVID_DEVICE_ID, =20
&dev->subsystem_device);
  		}
  		break;

  	case PCI_HEADER_TYPE_CARDBUS:		    /* CardBus bridge header */
  		if (class !=3D PCI_CLASS_BRIDGE_CARDBUS)
  			goto bad;
  		pci_read_irq(dev);
  		pci_read_bases(dev, 1, 0);
  		pci_read_config_word(dev, PCI_CB_SUBSYSTEM_VENDOR_ID, =20
&dev->subsystem_vendor);
  		pci_read_config_word(dev, PCI_CB_SUBSYSTEM_ID, &dev->subsystem_device);
  		break;

  	default:				    /* unknown header */
  		dev_err(&dev->dev, "unknown header type %02x, "
  			"ignoring device\n", dev->hdr_type);
  		return -EIO;

  	bad:
  		dev_err(&dev->dev, "ignoring class %02x (doesn't match header "
  			"type %02x)\n", class, dev->hdr_type);
  		dev->class =3D PCI_CLASS_NOT_DEFINED;
  	}

  	/* We found a fine healthy device, go go go... */
  	return 0;
  }

  static void pci_release_capabilities(struct pci_dev *dev)
  {
  	pci_vpd_release(dev);
  	pci_iov_release(dev);
  }

  /**
   * pci_release_dev - free a pci device structure when all users of =20
it are finished.
   * @dev: device that's been disconnected
   *
   * Will be called only by the device core when all users of this pci =20
device are
   * done.
   */
  static void pci_release_dev(struct device *dev)
  {
  	struct pci_dev *pci_dev;

  	pci_dev =3D to_pci_dev(dev);
  	pci_release_capabilities(pci_dev);



Signed-off-by: Stephan Schreiber <info@fs-driver.org>




