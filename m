From: Jack Steiner <steiner@sgi.com>
Date: Wed, 27 Oct 2004 16:49:45 +0000
Subject: [PATCH] - Update asm-ia64/sn/sn_cpuid.h macros (add missing file)
Message-Id: <20041027164945.GA13655@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041026114649.GA12741@sgi.com>
In-Reply-To: <20041026114649.GA12741@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony - please apply

(I missed a file in the cleanup code that I sent yesterday.)


SGI SN code currently makes assumptions about the bits in the LID
register. These assumptions do not conform to the bit specifications
from Intel. For example, SN currently assumes that bits [28:16] of
the LID contain the physical node ID of a node.

This patch eliminates these assumptions. A SAL call is now used to translate
LID values to the NASID/subnode/slice values that are needed for SN
platforms. The results of the SAL call are saved in the SN nodepda.

----

Signed-off-by: Jack Steiner <steiner@sgi.com>


----






diff -Naurp linux_base/arch/ia64/sn/kernel/iomv.c linux/arch/ia64/sn/kernel/iomv.c
--- linux_base/arch/ia64/sn/kernel/iomv.c	2004-10-22 11:36:31 -05:00
+++ linux/arch/ia64/sn/kernel/iomv.c	2004-10-23 21:32:01 -05:00
@@ -9,6 +9,7 @@
 #include <linux/module.h>
 #include <asm/io.h>
 #include <asm/delay.h>
+#include <asm/sn/nodepda.h>
 #include <asm/sn/simulator.h>
 #include <asm/sn/pda.h>
 #include <asm/sn/sn_cpuid.h>
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


