From: Erich Focht <efocht@ess.nec.de>
Date: Mon, 09 Dec 2002 12:15:49 +0000
Subject: [Linux-ia64] Configurable NUMA node memory size
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------Boundary-00=_D2QUK8NHXEC4SCDOLHGB"
Message-Id: <marc-linux-ia64-105590709805517@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--------------Boundary-00=_D2QUK8NHXEC4SCDOLHGB
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable

Hi,

following the requests from Xavier and Jesse I introduced a
configuration parameter for the maximum memory per NUMA node. The
DIG_BANKSHIFT is set accordingly, the current choices are:
         512MB/bank:  16GB/node,
        2048MB/bank:  64GB/node,
        8192MB/bank: 256GB/node.

The patch is for 2.5.50+ia64. Please consider applying it.

Thanks,
Erich

--------------Boundary-00=_D2QUK8NHXEC4SCDOLHGB
Content-Type: text/x-diff;
  charset="iso-8859-15";
  name="conf_numa_nodesize-2.5.50-ia64.path"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="conf_numa_nodesize-2.5.50-ia64.path"

diff -urNp linux-2.5.50-ia64/arch/ia64/Kconfig linux-2.5.50-ia64-digshift/arch/ia64/Kconfig
--- linux-2.5.50-ia64/arch/ia64/Kconfig	2002-12-09 11:23:01.000000000 +0100
+++ linux-2.5.50-ia64-digshift/arch/ia64/Kconfig	2002-12-09 12:25:25.000000000 +0100
@@ -220,6 +220,23 @@ config NUMA
 	  Access).  This option is for configuring high-end multiprocessor
 	  server systems.  If in doubt, say N.
 
+choice
+	prompt "Maximum Memory per NUMA Node" if NUMA && IA64_DIG
+	depends on NUMA && IA64_DIG
+	default IA64_NODESIZE_16GB
+
+config IA64_NODESIZE_16GB
+	bool "16GB"
+
+config IA64_NODESIZE_64GB
+	bool "64GB"
+
+config IA64_NODESIZE_256GB
+	bool "256GB"
+
+endchoice
+
+
 config VIRTUAL_MEM_MAP
 	bool "Enable Virtual Mem Map" if IA64_GENERIC || IA64_DIG
 	depends on !NUMA
diff -urNp linux-2.5.50-ia64/include/asm-ia64/mmzone.h linux-2.5.50-ia64-digshift/include/asm-ia64/mmzone.h
--- linux-2.5.50-ia64/include/asm-ia64/mmzone.h	2002-11-27 23:36:24.000000000 +0100
+++ linux-2.5.50-ia64-digshift/include/asm-ia64/mmzone.h	2002-12-09 12:02:08.000000000 +0100
@@ -104,12 +104,22 @@ extern unsigned long max_low_pfn;
 
 /*
  * Bank definitions.
- * Current settings for DIG: 512MB/bank, 16GB/node.
+ * Configurable settings for DIG: 512MB/bank:  16GB/node,
+ *                               2048MB/bank:  64GB/node,
+ *                               8192MB/bank: 256GB/node.
  */
 #define NR_BANKS_PER_NODE	32
-#define BANK_OFFSET(addr)	((unsigned long)(addr) & (BANKSIZE-1))
-#define DIG_BANKSHIFT		29
+#if defined(CONFIG_IA64_NODESIZE_16GB)
+# define DIG_BANKSHIFT		29
+#elif defined(CONFIG_IA64_NODESIZE_64GB)
+# define DIG_BANKSHIFT		31
+#elif defined(CONFIG_IA64_NODESIZE_256GB)
+# define DIG_BANKSHIFT		33
+#else
+# error Unsupported bank and nodesize!
+#endif
 #define BANKSIZE		(1UL << DIG_BANKSHIFT)
+#define BANK_OFFSET(addr)	((unsigned long)(addr) & (BANKSIZE-1))
 #define NR_BANKS		(NR_BANKS_PER_NODE * NR_NODES)
 
 /*

--------------Boundary-00=_D2QUK8NHXEC4SCDOLHGB--


