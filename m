From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 17 Sep 2003 14:18:14 +0000
Subject: [patch] include/asm-ia64/acpi.h
Message-Id: <marc-linux-ia64-106380837411487@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

asm/acpi.h relies on struct pci_vector_struct which is defined in
asm/system.h

Cheers,
Jes

--- /usr/tmp/TmpDir.13540-0/linux/include/asm-ia64/acpi.h_1.5	Wed Sep 17 07:16:58 2003
+++ linux/include/asm-ia64/acpi.h	Wed Sep 17 07:10:11 2003
@@ -30,6 +30,8 @@
 
 #ifdef __KERNEL__
 
+#include <asm/system.h>
+
 #define COMPILER_DEPENDENT_INT64	long
 #define COMPILER_DEPENDENT_UINT64	unsigned long
 
