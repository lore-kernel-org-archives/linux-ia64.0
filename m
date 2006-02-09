From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 09 Feb 2006 01:06:19 +0000
Subject: [PATCH 1/2]: Tollhouse HP: IA64 arch changes
Message-Id: <20060209010555.26182.70583.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/sn and include/asm-ia64/sn changes required to support Tollhouse
system PCI hotplug, fixes the ia64_sn_sysctl_ioboard_get call, and introduces
the PRF_HOTPLUG_SUPPORT feature bit.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit 2ab0f68bd8613bf0a41a28c122d36ffe63a4489c
tree 73b27cb686e96ffbc56f04032ce8c21ae1cecb13
parent 913e4a75572354995b330f57082d9a86250cd75f
author Prarit Bhargava <prarit@sgi.com> Wed, 08 Feb 2006 13:47:03 -0500
committer Prarit Bhargava <prarit@sgi.com> Wed, 08 Feb 2006 13:47:03 -0500

 arch/ia64/sn/kernel/io_init.c           |   29 +++++++++++++++++++++++++++++
 arch/ia64/sn/kernel/tiocx.c             |   10 ++++++++--
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |   17 +++++++++++++++++
 include/asm-ia64/sn/l1.h                |    3 ++-
 include/asm-ia64/sn/pcibr_provider.h    |    1 +
 include/asm-ia64/sn/pcidev.h            |    1 +
 include/asm-ia64/sn/sn_feature_sets.h   |    3 +--
 include/asm-ia64/sn/sn_sal.h            |   24 ++++++++++++++----------
 8 files changed, 73 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index d7e4d79..a9944a1 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -13,6 +13,8 @@
 #include <asm/sn/sn_feature_sets.h>
 #include <asm/sn/geo.h>
 #include <asm/sn/io.h>
+#include <asm/sn/l1.h>
+#include <asm/sn/module.h>
 #include <asm/sn/pcibr_provider.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
@@ -728,9 +730,36 @@ cnodeid_get_geoid(cnodeid_t cnode)
 
 }
 
+void sn_generate_path(struct pci_bus *pci_bus, char *address)
+{
+	nasid_t nasid;
+	cnodeid_t cnode;
+	geoid_t geoid;
+	moduleid_t moduleid;
+	u16 bricktype;
+
+	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(pci_bus)->bs_base);
+	cnode = nasid_to_cnodeid(nasid);
+	geoid = cnodeid_get_geoid(cnode);
+	moduleid = geo_module(geoid);
+
+	sprintf(address, "module_%c%c%c%c%.2d",
+		'0'+RACK_GET_CLASS(MODULE_GET_RACK(moduleid)),
+		'0'+RACK_GET_GROUP(MODULE_GET_RACK(moduleid)),
+		'0'+RACK_GET_NUM(MODULE_GET_RACK(moduleid)),
+		MODULE_GET_BTCHAR(moduleid), MODULE_GET_BPOS(moduleid));
+
+	/* Tollhouse requires slot id to be displayed */
+	bricktype = MODULE_GET_BTYPE(moduleid);
+	if ((bricktype = L1_BRICKTYPE_191010) ||
+	    (bricktype = L1_BRICKTYPE_1932))
+			sprintf(address, "%s^%d", address, geo_slot(geoid));
+}
+
 subsys_initcall(sn_pci_init);
 EXPORT_SYMBOL(sn_pci_fixup_slot);
 EXPORT_SYMBOL(sn_pci_unfixup_slot);
 EXPORT_SYMBOL(sn_pci_controller_fixup);
 EXPORT_SYMBOL(sn_bus_store_sysdata);
 EXPORT_SYMBOL(sn_bus_free_sysdata);
+EXPORT_SYMBOL(sn_generate_path);
diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index d263d3e..1d30fc9 100644
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -371,9 +371,15 @@ static void tio_corelet_reset(nasid_t na
 
 static int is_fpga_tio(int nasid, int *bt)
 {
-	int ioboard_type;
+	u16 ioboard_type;
+	s64 rc;
 
-	ioboard_type = ia64_sn_sysctl_ioboard_get(nasid);
+	rc = ia64_sn_sysctl_ioboard_get(nasid, &ioboard_type);
+	if (rc) {
+		printk(KERN_WARNING "ia64_sn_sysctl_ioboard_get failed: %ld\n",
+		       rc);
+		return 0;
+	}
 
 	switch (ioboard_type) {
 	case L1_BRICKTYPE_SA:
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
index 2fac270..e0c6b6a 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -74,6 +74,22 @@ static int sal_pcibr_error_interrupt(str
 	return (int)ret_stuff.v0;
 }
 
+u16 sn_ioboard_to_pci_bus(struct pci_bus *pci_bus)
+{
+	s64 rc;
+	u16 ioboard;
+	nasid_t nasid = NASID_GET(SN_PCIBUS_BUSSOFT(pci_bus)->bs_base);
+
+	rc = ia64_sn_sysctl_ioboard_get(nasid, &ioboard);
+	if (rc) {
+		printk(KERN_WARNING "ia64_sn_sysctl_ioboard_get failed: %ld\n",
+		       rc);
+		return 0;
+	}
+
+	return ioboard;
+}
+
 /* 
  * PCI Bridge Error interrupt handler.  Gets invoked whenever a PCI 
  * bridge sends an error interrupt.
@@ -252,3 +268,4 @@ pcibr_init_provider(void)
 
 EXPORT_SYMBOL_GPL(sal_pcibr_slot_enable);
 EXPORT_SYMBOL_GPL(sal_pcibr_slot_disable);
+EXPORT_SYMBOL_GPL(sn_ioboard_to_pci_bus);
diff --git a/include/asm-ia64/sn/l1.h b/include/asm-ia64/sn/l1.h
index e3b8191..344bf44 100644
--- a/include/asm-ia64/sn/l1.h
+++ b/include/asm-ia64/sn/l1.h
@@ -34,6 +34,8 @@
 #define L1_BRICKTYPE_IA		0x6b            /* k */
 #define L1_BRICKTYPE_ATHENA	0x2b            /* + */
 #define L1_BRICKTYPE_DAYTONA	0x7a            /* z */
+#define L1_BRICKTYPE_1932	0x2c		/* . */
+#define L1_BRICKTYPE_191010	0x2e		/* , */
 
 /* board type response codes */
 #define L1_BOARDTYPE_IP69       0x0100          /* CA */
@@ -46,5 +48,4 @@
 #define L1_BOARDTYPE_DAYTONA    0x0800          /* AD */
 #define L1_BOARDTYPE_INVAL      (-1)            /* invalid brick type */
 
-
 #endif /* _ASM_IA64_SN_L1_H */
diff --git a/include/asm-ia64/sn/pcibr_provider.h b/include/asm-ia64/sn/pcibr_provider.h
index 9334078..3fb56b4 100644
--- a/include/asm-ia64/sn/pcibr_provider.h
+++ b/include/asm-ia64/sn/pcibr_provider.h
@@ -156,4 +156,5 @@ extern int sal_pcibr_slot_enable(struct 
 				 void *resp);
 extern int sal_pcibr_slot_disable(struct pcibus_info *soft, int device,
 				  int action, void *resp);
+extern u16 sn_ioboard_to_pci_bus(struct pci_bus *pci_bus);
 #endif
diff --git a/include/asm-ia64/sn/pcidev.h b/include/asm-ia64/sn/pcidev.h
index 38cdffb..eac3561 100644
--- a/include/asm-ia64/sn/pcidev.h
+++ b/include/asm-ia64/sn/pcidev.h
@@ -76,6 +76,7 @@ extern void sn_pci_controller_fixup(int 
  				    struct pci_bus *bus);
 extern void sn_bus_store_sysdata(struct pci_dev *dev);
 extern void sn_bus_free_sysdata(void);
+extern void sn_generate_path(struct pci_bus *pci_bus, char *address);
 extern void sn_pci_fixup_slot(struct pci_dev *dev);
 extern void sn_pci_unfixup_slot(struct pci_dev *dev);
 extern void sn_irq_lh_init(void);
diff --git a/include/asm-ia64/sn/sn_feature_sets.h b/include/asm-ia64/sn/sn_feature_sets.h
index 9ca642c..c279d67 100644
--- a/include/asm-ia64/sn/sn_feature_sets.h
+++ b/include/asm-ia64/sn/sn_feature_sets.h
@@ -33,8 +33,7 @@ extern int sn_prom_feature_available(int
 
 #define PRF_PAL_CACHE_FLUSH_SAFE	0
 #define PRF_DEVICE_FLUSH_LIST		1
-
-
+#define PRF_HOTPLUG_SUPPORT		2
 
 /* --------------------- OS Features -------------------------------*/
 
diff --git a/include/asm-ia64/sn/sn_sal.h b/include/asm-ia64/sn/sn_sal.h
index e77f0c9..246f43a 100644
--- a/include/asm-ia64/sn/sn_sal.h
+++ b/include/asm-ia64/sn/sn_sal.h
@@ -907,18 +907,22 @@ ia64_sn_sysctl_tio_clock_reset(nasid_t n
 /*
  * Get the associated ioboard type for a given nasid.
  */
-static inline int
-ia64_sn_sysctl_ioboard_get(nasid_t nasid)
+static inline s64
+ia64_sn_sysctl_ioboard_get(nasid_t nasid, u16 *ioboard)
 {
-        struct ia64_sal_retval rv;
-        SAL_CALL_REENTRANT(rv, SN_SAL_SYSCTL_OP, SAL_SYSCTL_OP_IOBOARD,
-                        nasid, 0, 0, 0, 0, 0);
-        if (rv.v0 != 0)
-                return (int)rv.v0;
-        if (rv.v1 != 0)
-                return (int)rv.v1;
+	struct ia64_sal_retval isrv;
+	SAL_CALL_REENTRANT(isrv, SN_SAL_SYSCTL_OP, SAL_SYSCTL_OP_IOBOARD,
+			   nasid, 0, 0, 0, 0, 0);
+	if (isrv.v0 != 0) {
+		*ioboard = isrv.v0;
+		return isrv.status;
+	}
+	if (isrv.v1 != 0) {
+		*ioboard = isrv.v1;
+		return isrv.status;
+	}
 
-        return 0;
+	return isrv.status;
 }
 
 /**
