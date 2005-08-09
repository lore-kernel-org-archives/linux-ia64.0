From: Christoph Hellwig <hch@lst.de>
Date: Tue, 09 Aug 2005 20:38:00 +0000
Subject: [PATCH] update CONFIG_PCI description
Message-Id: <20050809203800.GA28917@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The current one doesn't even make sense anymore on i386 where it
apparently came from.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig	2005-07-24 23:24:52.000000000 +0200
+++ linux-2.6/arch/ia64/Kconfig	2005-08-09 22:36:26.000000000 +0200
@@ -392,15 +392,8 @@
 config PCI
 	bool "PCI support"
 	help
-	  Find out whether you have a PCI motherboard. PCI is the name of a
-	  bus system, i.e. the way the CPU talks to the other stuff inside
-	  your box. Other bus systems are ISA, EISA, MicroChannel (MCA) or
-	  VESA. If you have PCI, say Y, otherwise N.
-
-	  The PCI-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, contains valuable
-	  information about which PCI hardware does work under Linux and which
-	  doesn't.
+	  There is no IA64 hardware without PCI/PCI-X/PCI-Express busses.
+	  Say Y here unless running on the HP simulator.
 
 config PCI_DOMAINS
 	bool
