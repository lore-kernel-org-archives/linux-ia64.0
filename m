From: Yinghai Lu <yinghai@kernel.org>
Date: Mon, 12 Jan 2015 19:23:15 +0000
Subject: [PATCH 05/10] PCI, ia64: clip firmware assigned resource under parent bridge's
Message-Id: <1421090600-9750-6-git-send-email-yinghai@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421090600-9750-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <1421090600-9750-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-ia64@vger.kernel.org

Some bios put range that is not fully coverred by root bus resources.
Try to clip them and update them in pci bridge bars.

We'd like to fix other arches instead of just x86.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=85491
Reported-by: Marek Kordik <kordikmarek@gmail.com>
Fixes: 5b28541552ef ("PCI: Restrict 64-bit prefetchable bridge windows to 6=
4-bit resources")
Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/pci/pci.c | 71 +++++++++++++++++++++++++++++++++----------------=
----
 1 file changed, 44 insertions(+), 27 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 291a582..a3f9e27 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -487,45 +487,57 @@ int pcibios_root_bridge_prepare(struct pci_host_bridg=
e *bridge)
 	return 0;
 }
=20
-static int is_valid_resource(struct pci_dev *dev, int idx)
+void pcibios_fixup_device_resources(struct pci_dev *dev)
 {
-	unsigned int i, type_mask =3D IORESOURCE_IO | IORESOURCE_MEM;
-	struct resource *devr =3D &dev->resource[idx], *busr;
+	int idx;
=20
 	if (!dev->bus)
-		return 0;
+		return;
=20
-	pci_bus_for_each_resource(dev->bus, busr, i) {
-		if (!busr || ((busr->flags ^ devr->flags) & type_mask))
+	for (idx =3D 0; idx < PCI_BRIDGE_RESOURCES; idx++) {
+		struct resource *r =3D &dev->resource[idx];
+
+		if (!r->flags || r->parent || !r->start)
 			continue;
-		if ((devr->start) && (devr->start >=3D busr->start) &&
-				(devr->end <=3D busr->end))
-			return 1;
+
+		if (pci_claim_resource(dev, idx) >=3D 0)
+			continue;
+
+		/* try again with clip */
+		if (pci_bus_clip_resource(dev, r)) {
+			pci_update_resource(dev, idx);
+			pci_claim_resource(dev, idx);
+		}
 	}
-	return 0;
 }
+EXPORT_SYMBOL_GPL(pcibios_fixup_device_resources);
=20
-static void pcibios_fixup_resources(struct pci_dev *dev, int start, int li=
mit)
+static bool pcibios_fixup_bridge_resources(struct pci_dev *dev)
 {
-	int i;
+	int idx;
+	bool changed =3D false;
+
+	if (!dev->bus)
+		return changed;
+
+	for (idx =3D PCI_BRIDGE_RESOURCES; idx < PCI_NUM_RESOURCES; idx++) {
+		struct resource *r =3D &dev->resource[idx];
=20
-	for (i =3D start; i < limit; i++) {
-		if (!dev->resource[i].flags)
+		if (!r->flags || r->parent || !r->start)
 			continue;
-		if ((is_valid_resource(dev, i)))
-			pci_claim_resource(dev, i);
-	}
-}
=20
-void pcibios_fixup_device_resources(struct pci_dev *dev)
-{
-	pcibios_fixup_resources(dev, 0, PCI_BRIDGE_RESOURCES);
-}
-EXPORT_SYMBOL_GPL(pcibios_fixup_device_resources);
+		if (pci_claim_resource(dev, idx) >=3D 0)
+			continue;
=20
-static void pcibios_fixup_bridge_resources(struct pci_dev *dev)
-{
-	pcibios_fixup_resources(dev, PCI_BRIDGE_RESOURCES, PCI_NUM_RESOURCES);
+		/* try again after clip for pci bridge*/
+		if ((dev->class >> 8) =3D PCI_CLASS_BRIDGE_PCI &&
+		    pci_bus_clip_resource(dev, r)) {
+			changed =3D true;
+			pci_claim_resource(dev, idx);
+		}
+	}
+
+	return changed;
 }
=20
 /*
@@ -536,9 +548,14 @@ void pcibios_fixup_bus(struct pci_bus *b)
 	struct pci_dev *dev;
=20
 	if (b->self) {
+		bool changed;
+
 		pci_read_bridge_bases(b);
-		pcibios_fixup_bridge_resources(b->self);
+		changed =3D pcibios_fixup_bridge_resources(b->self);
+		if (changed)
+			pci_setup_bridge(b);
 	}
+
 	list_for_each_entry(dev, &b->devices, bus_list)
 		pcibios_fixup_device_resources(dev);
 	platform_pci_fixup_bus(b);
--=20
1.8.4.5

