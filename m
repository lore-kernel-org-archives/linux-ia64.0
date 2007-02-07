From: Horms <horms@verge.net.au>
Date: Wed, 07 Feb 2007 06:49:36 +0000
Subject: [PATCH] [IA64] Include kexec.h in arch/ia64/kernel/process.c
Message-Id: <20070207064935.GB726@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org
Cc: Zou Nan hai <nanhai.zou@intel.com>, Khalid Aziz <khalid_aziz@hp.com>, Adrian Bunk <trivial@kernel.org>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

kexec.h is needed by arch/ia64/kernel/process.c so for the
declaration of kexec_disable_iosapic() which is used in machine_shutdown().

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/process.c
=================================--- linux-2.6.orig/arch/ia64/kernel/process.c	2007-02-07 12:43:09.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/process.c	2007-02-07 12:43:16.000000000 +0900
@@ -41,6 +41,7 @@
 #include <asm/uaccess.h>
 #include <asm/unwind.h>
 #include <asm/user.h>
+#include <asm/kexec.h>
 
 #include "entry.h"
 
