From: Rajesh Shah <rajesh.shah@intel.com>
Date: Wed, 06 Apr 2005 22:36:29 +0000
Subject: Re: tiger_defconfig build fails for 2.6.12-rc2-mm1
Message-Id: <20050406153629.A31796@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405165047.A21553@unix-os.sc.intel.com>
In-Reply-To: <20050405165047.A21553@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 06, 2005 at 02:56:34PM -0700, Andrew Morton wrote:
> 
> I don't see why bk-acpi-alpha-build-fix.patch needed to be reverted?

With that patch in I get:

In file included from drivers/firmware/pcdp.c:18:
drivers/firmware/pcdp.h:48: error: field `addr' has incomplete type
drivers/firmware/pcdp.c: In function `setup_serial_console':
drivers/firmware/pcdp.c:27: error: `ACPI_ADR_SPACE_SYSTEM_MEMORY' undeclared (first use in this function)
drivers/firmware/pcdp.c:27: error: (Each undeclared identifier is reported only once
drivers/firmware/pcdp.c:27: error: for each function it appears in.)
make[2]: *** [drivers/firmware/pcdp.o] Error 1
make[1]: *** [drivers/firmware] Error 2
make[1]: *** Waiting for unfinished jobs....

KAMEZAWA Hiroyuki had posted this patch, and it fixes it for
me too:

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

Rajesh
