From: Venki Pallipadi <venkatesh.pallipadi@intel.com>
Date: Tue, 22 May 2007 22:35:24 +0000
Subject: [PATCH] Fix using uninitialized data in _PDC setup
Message-Id: <20070522223523.GA14410@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Silly bug in _PDC data setup. Haven't seen any real side-effects of this one
yet. But, needs fixing regardless. This should probably make into stable
kernel as well.

Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>

Index: linux-2.6.22-rc-mm/arch/ia64/kernel/acpi-processor.c
=================================--- linux-2.6.22-rc-mm.orig/arch/ia64/kernel/acpi-processor.c	2007-04-25 20:08:32.000000000 -0700
+++ linux-2.6.22-rc-mm/arch/ia64/kernel/acpi-processor.c	2007-05-22 13:40:17.000000000 -0700
@@ -44,7 +44,7 @@
 
 	buf[0] = ACPI_PDC_REVISION_ID;
 	buf[1] = 1;
-	buf[2] |= ACPI_PDC_EST_CAPABILITY_SMP;
+	buf[2] = ACPI_PDC_EST_CAPABILITY_SMP;
 
 	obj->type = ACPI_TYPE_BUFFER;
 	obj->buffer.length = 12;
