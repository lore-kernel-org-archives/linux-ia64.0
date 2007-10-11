From: "Xu, Anthony" <anthony.xu@intel.com>
Date: Thu, 11 Oct 2007 08:56:13 +0000
Subject: [PATCH]  correctly use sal call attribute
Message-Id: <51CFAB8CB6883745AE7B93B3E084EBE201244823@pdsmsx412.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51CFAB8CB6883745AE7B93B3E084EBE201244820@pdsmsx412.ccr.corp.intel.com>
In-Reply-To: <51CFAB8CB6883745AE7B93B3E084EBE201244820@pdsmsx412.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Correctly use sal call attribute such as mf-safe and reentrant 


Signed-off-by: Anthony Xu < anthony.xu@intel.com >


diff -urN linux-2.6.23-rc8/arch/ia64/kernel/sal.c
linux/arch/ia64/kernel/sal.c
--- linux-2.6.23-rc8/arch/ia64/kernel/sal.c	2007-09-25
08:33:10.000000000 +0800
+++ linux/arch/ia64/kernel/sal.c	2007-09-29 14:13:10.000000000
+0800
@@ -243,7 +243,7 @@
 	while (!ia64_get_irr(IA64_TIMER_VECTOR))
 		cpu_relax();
 
-	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0,
0, 0);
 
 	if (isrv.status)
 		printk(KERN_ERR "SAL_CAL_FLUSH failed with %ld\n",
isrv.status);
diff -urN linux-2.6.23-rc8/include/asm-ia64/sal.h
linux/include/asm-ia64/sal.h
--- linux-2.6.23-rc8/include/asm-ia64/sal.h	2007-09-25
08:33:10.000000000 +0800
+++ linux/include/asm-ia64/sal.h	2007-09-29 14:16:46.000000000
+0800
@@ -652,7 +652,7 @@
 {
 	struct ia64_sal_retval isrv;
 
-	SAL_CALL(isrv, SAL_FREQ_BASE, which, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_FREQ_BASE, which, 0, 0, 0, 0, 0, 0);
 	*ticks_per_second = isrv.v0;
 	*drift_info = isrv.v1;
 	return isrv.status;
@@ -666,7 +666,7 @@
 ia64_sal_cache_init (void)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_CACHE_INIT, 0, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_CACHE_INIT, 0, 0, 0, 0, 0, 0, 0);
 	return isrv.status;
 }
 
@@ -748,7 +748,8 @@
 ia64_sal_pci_config_read (u64 pci_config_addr, int type, u64 size, u64
*value)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size, type,
0, 0, 0, 0);
+	SAL_CALL_REENTRANT(isrv, SAL_PCI_CONFIG_READ, pci_config_addr,
size,
+	         type, 0, 0, 0, 0);
 	if (value)
 		*value = isrv.v0;
 	return isrv.status;
@@ -759,8 +760,8 @@
 ia64_sal_pci_config_write (u64 pci_config_addr, int type, u64 size, u64
value)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PCI_CONFIG_WRITE, pci_config_addr, size,
value,
-	         type, 0, 0, 0);
+	SAL_CALL_REENTRANT(isrv, SAL_PCI_CONFIG_WRITE, pci_config_addr,
size,
+	         value, type, 0, 0, 0);
 	return isrv.status;
 }
 
@@ -815,7 +816,7 @@
 ia64_sal_physical_id_info(u16 *splid)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0,
0);
 	if (splid)
 		*splid = isrv.v0;
 	return isrv.status;
