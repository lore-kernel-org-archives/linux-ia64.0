From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 16 Mar 2005 01:33:22 +0000
Subject: __IA64_UNCACHED_OFFSET undefined...
Message-Id: <16951.36066.84031.81177@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	Changeset
jes@wildopensource.com[torvalds]|ChangeSet|20050314001633|21074 
introduced new functions into include/asm-ia64/uaccess.h, and broke
IA64 compilation.  I think it needs the attached additional change:

Compile log shows:
include2/asm/uaccess.h: In function `xlate_dev_mem_ptr':
include2/asm/uaccess.h:382: error: `__IA64_UNCACHED_OFFSET' undeclared (first use in this function)
include2/asm/uaccess.h:382: error: (Each undeclared identifier is reported only once
include2/asm/uaccess.h:382: error: for each function it appears in.)
include2/asm/uaccess.h: In function `xlate_dev_kmem_ptr':
include2/asm/uaccess.h:400: error: `__IA64_UNCACHED_OFFSET' undeclared (first use in this function)


Index: linux-2.5-import/include/asm-ia64/uaccess.h
=================================--- linux-2.5-import.orig/include/asm-ia64/uaccess.h	2005-03-15 12:28:43.000428390 +1100
+++ linux-2.5-import/include/asm-ia64/uaccess.h	2005-03-16 12:32:32.899217137 +1100
@@ -40,6 +40,7 @@
 
 #include <asm/intrinsics.h>
 #include <asm/pgtable.h>
+#include <asm/io.h>
 
 /*
  * For historical reasons, the following macros are grossly misnamed:
