From: Jack Steiner <steiner@sgi.com>
Date: Tue, 04 Jan 2005 17:09:38 +0000
Subject: [PATCH] - Update SN2 code for running on simulator (2nd try)
Message-Id: <20050104170937.GA21254@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050104142411.GA22312@sgi.com>
In-Reply-To: <20050104142411.GA22312@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Update the hack in sn_io_addr() that is used when running on the
system simulator. The change is needed for running on systems with 
the new shub2 chipset.

Note that this change affects simulator runs only.

	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/arch/ia64/sn/kernel/iomv.c
=================================--- linux.orig/arch/ia64/sn/kernel/iomv.c	2005-01-03 19:53:47.745120404 -0600
+++ linux/arch/ia64/sn/kernel/iomv.c	2005-01-04 11:06:59.394846071 -0600
@@ -32,7 +32,6 @@ void *sn_io_addr(unsigned long port)
 		return ((void *)(port | __IA64_UNCACHED_OFFSET));
 	} else {
 		/* but the simulator uses them... */
-		unsigned long io_base;
 		unsigned long addr;
 
 		/*
@@ -40,13 +39,9 @@ void *sn_io_addr(unsigned long port)
 		 * for accessing registers in bedrock local block
 		 * (so we don't do port&0xfff)
 		 */
-		if ((port >= 0x1f0 && port <= 0x1f7) ||
-		    port = 0x3f6 || port = 0x3f7) {
-			io_base = GLOBAL_MMR_ADDR(get_nasid(), 0xfcc000000UL);
-			addr = io_base | ((port >> 2) << 12) | (port & 0xfff);
-		} else {
-			addr = __ia64_get_io_port_base() | ((port >> 2) << 2);
-		}
+		addr = (is_shub2() ? 0xc00000028c000000UL : 0xc0000087cc000000UL) | ((port >> 2) << 12);
+		if ((port >= 0x1f0 && port <= 0x1f7) || port = 0x3f6 || port = 0x3f7)
+			addr |= port;
 		return (void *)addr;
 	}
 }
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


