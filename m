From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 07 Feb 2006 22:11:57 +0000
Subject: [2.6 patch] IA64_GENERIC shouldn't select other stuff
Message-Id: <20060207221157.GA3524@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

IA64_GENERIC shouldn't select other stuff.

select'ing ACPI without select'ing PCI had broken ACPI in the past (the 
current workaround is that ACPI select's PCI).

Select'ing NUMA means that the illegal configuration NUMA=y, FLATMEM=y 
is possible.

The generic setting might be required in some places, but select'ing 
some options like NUMA while not select'ing some other similar 
important options like PCI doesn't make much sense.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig.old	2006-02-07 23:07:29.000000000 +0100
+++ linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig	2006-02-07 23:07:55.000000000 +0100
@@ -72,9 +72,6 @@
 
 config IA64_GENERIC
 	bool "generic"
-	select ACPI
-	select NUMA
-	select ACPI_NUMA
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure

