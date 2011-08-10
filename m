From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 10 Aug 2011 17:57:44 +0000
Subject: [IA64] fix "allnoconfig" build
Message-Id: <4e42c69821435a3638@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Link errors:
arch/ia64/kernel/built-in.o: In function `arch_setup_dmar_msi':
(.text+0x35972): undefined reference to `dmar_msi_write'
... and more ...

because allnoconfig has CONFIG_DMAR=y due to the "select DMAR"
in arch/ia64/Kconfig under config IA64_GENERIC.

Drop that select, but add CONFIG_DMAR=y to generic_defconfig so
we keep testbuilding the DMAR code.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 1248547..3ff7785 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -162,7 +162,6 @@ config IA64_GENERIC
 	select ACPI_NUMA
 	select SWIOTLB
 	select PCI_MSI
-	select DMAR
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 1d7bca0..0e5cd14 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -234,3 +234,4 @@ CONFIG_CRYPTO_MD5=y
 # CONFIG_CRYPTO_ANSI_CPRNG is not set
 CONFIG_CRC_T10DIF=y
 CONFIG_MISC_DEVICES=y
+CONFIG_DMAR=y
