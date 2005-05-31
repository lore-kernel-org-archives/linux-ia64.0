From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 31 May 2005 00:26:59 +0000
Subject: BigSur defconfig compilation fails 2.6.12-rc4 (was: tiger_defconfig build fails for 2.6.12-rc2-mm1)
Message-Id: <17051.44883.692341.647737@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Rajesh" = Rajesh Shah <rajesh.shah@intel.com> writes:

Rajesh> In file included from drivers/firmware/pcdp.c:18:
Rajesh> drivers/firmware/pcdp.h:48: error: field `addr' has incomplete type 
Rajesh> drivers/firmware/pcdp.c: In function `setup_serial_console': 
Rajesh> drivers/firmware/pcdp.c:27: error:  `ACPI_ADR_SPACE_SYSTEM_MEMORY' undeclared (first use in this  function) 
Rajesh> drivers/firmware/pcdp.c:27: error: (Each undeclared identifier is reported only once 
Rajesh> drivers/firmware/pcdp.c:27: error: for each function it appears in.) 

Rajesh> KAMEZAWA Hiroyuki had posted this patch, and it fixes it for
Rajesh> me too:


This patch is now needed to get a clean compile in mainline, too.

diff -puN drivers/firmware/pcdp.c~cleanup drivers/firmware/pcdp.c
--- linux-2.6.12-rc2-mm1/drivers/firmware/pcdp.c~cleanup	2005-04-06 15:43:01.000000000 +0900
+++ linux-2.6.12-rc2-mm1-kamezawa/drivers/firmware/pcdp.c	2005-04-06 15:43:24.000000000 +0900
@@ -11,6 +11,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/config.h>
 #include <linux/acpi.h>
 #include <linux/console.h>
 #include <linux/efi.h>
-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
