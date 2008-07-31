From: Jack Steiner <steiner@sgi.com>
Date: Thu, 31 Jul 2008 12:52:50 +0000
Subject: [Patch] - Eliminate trailing backquote in IA64_SGI_UV
Message-Id: <20080731125250.GA15319@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Eliminate trailing backquote in IA64_SGI_UV congig.

Signed-off-by: Jack Steiner <steiner@sgi.com>


---
 arch/ia64/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux/arch/ia64/Kconfig
=================================--- linux.orig/arch/ia64/Kconfig	2008-07-16 17:48:42.000000000 -0500
+++ linux/arch/ia64/Kconfig	2008-07-31 07:50:22.000000000 -0500
@@ -171,8 +171,8 @@ config IA64_SGI_SN2
 	  to select this option.  If in doubt, select ia64 generic support
 	  instead.
 
-config IA64_SGI_UV`
-	bool "SGI-UV`"
+config IA64_SGI_UV
+	bool "SGI-UV"
 	select NUMA
 	select ACPI_NUMA
 	select SWIOTLB
