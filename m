From: Jesse Barnes <jbarnes@sgi.com>
Date: Sat, 27 Mar 2004 00:03:37 +0000
Subject: [PATCH] only scan PCI busses that exist
Message-Id: <200403261603.37747.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_ZTMZAYWioL7EM7o"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_ZTMZAYWioL7EM7o
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

sn_pci_init was unconditionally scanning 255 PCI busses, even though only a 
few are actually present on most systems.  This patch adds a check to make 
sure a given bus exists before doing the scan, which saves a little memory 
and also makes /sys/devices reflect reality a bit more closely.

Thanks,
Jesse

--Boundary-00=_ZTMZAYWioL7EM7o
Content-Type: text/plain;
  charset="us-ascii";
  name="pci-not-all-busses.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="pci-not-all-busses.patch"

===== arch/ia64/sn/io/machvec/pci_bus_cvlink.c 1.36 vs edited =====
--- 1.36/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Thu Feb 19 09:12:31 2004
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Fri Mar 26 15:50:30 2004
@@ -811,7 +811,6 @@
 	/*
 	 * set pci_raw_ops, etc.
 	 */
-
 	sgi_master_io_infr_init();
 
 	for (cnode = 0; cnode < numnodes; cnode++) {
@@ -826,16 +825,16 @@
 #endif
 
 	controller = kmalloc(sizeof(struct pci_controller), GFP_KERNEL);
-	if (controller) {
-		memset(controller, 0, sizeof(struct pci_controller));
-		/* just allocate some devices and fill in the pci_dev structs */
-		for (i = 0; i < PCI_BUSES_TO_SCAN; i++)
-			pci_scan_bus(i, &sn_pci_ops, controller);
+	if (!controller) {
+		printk(KERN_WARNING "cannot allocate PCI controller\n");
+		return 0;
 	}
 
-	/*
-	 * actually find devices and fill in hwgraph structs
-	 */
+	memset(controller, 0, sizeof(struct pci_controller));
+
+	for (i = 0; i < PCI_BUSES_TO_SCAN; i++)
+		if (pci_bus_to_vertex(i))
+			pci_scan_bus(i, &sn_pci_ops, controller);
 
 	done_probing = 1;
 
@@ -857,13 +856,8 @@
 	 * set the root start and end so that drivers calling check_region()
 	 * won't see a conflict
 	 */
-
-#ifdef CONFIG_IA64_SGI_SN_SIM
-	if (! IS_RUNNING_ON_SIMULATOR()) {
-		ioport_resource.start  = 0xc000000000000000;
-		ioport_resource.end =    0xcfffffffffffffff;
-	}
-#endif
+	ioport_resource.start = 0xc000000000000000;
+	ioport_resource.end = 0xcfffffffffffffff;
 
 	/*
 	 * Set the root start and end for Mem Resource.

--Boundary-00=_ZTMZAYWioL7EM7o--
