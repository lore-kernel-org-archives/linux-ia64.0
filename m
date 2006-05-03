From: Jon Mason <jdmason@us.ibm.com>
Date: Wed, 03 May 2006 22:26:58 +0000
Subject: Fwd: [PATCH] ia64: remove asm-ia64/bitops.h self-inclusion
Message-Id: <20060503222657.GB12091@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry, forgot to include the proper people.

----- Forwarded message from Jon Mason <jdmason@us.ibm.com> -----

User-Agent: Mutt/1.5.11
From: Jon Mason <jdmason@us.ibm.com>
To: linux-kernel@vger.kernel.org
Date: 	Tue, 2 May 2006 16:42:28 -0500
Subject: [PATCH] ia64: remove asm-ia64/bitops.h self-inclusion

asm-ia64/bitops.h includes itself.  The #ifndef _ASM_IA64_BITOPS_H
prevents this from being an issue, but it should still be removed.

Cross-compile tested.

Thanks,
Jon

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

diff -r 62dc1eb0c5e2 include/asm-ia64/bitops.h
--- a/include/asm-ia64/bitops.h	Wed Apr 26 16:12:39 2006
+++ b/include/asm-ia64/bitops.h	Tue May  2 16:27:46 2006
@@ -11,7 +11,6 @@
 
 #include <linux/compiler.h>
 #include <linux/types.h>
-#include <asm/bitops.h>
 #include <asm/intrinsics.h>
 
 /**
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

----- End forwarded message -----
