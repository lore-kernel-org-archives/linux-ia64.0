From: Xavier Bru <xavier.bru@bull.net>
Date: Thu, 04 Dec 2003 12:37:21 +0000
Subject: Problem booting Adaptec Ultra 320 driver with discontigmem support.
Message-Id: <marc-linux-ia64-107054139923799@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello, all

Running  2.6.0-test11 with Adaptec Ultra 320 driver that provides full=20
64-bit support
we hit a BUG in blk_queue_bounce_limit() due to physical address greater=20
than allowed by the dma mask.
Having a look into the code, it appears that the computation to allow=20
full 64-bit support takes in account the size of the installed memory=20
instead of the max physical address of the platform.
For example on  a platform with 32GB of memory distributed in 1 TB=20
physical address space, only 39-bits physical addresses are supported=20
instead of the 40 bits needed.

IOSAPIC: vector 54 -> CPU 0x04e0, enabled
scsi0 : Adaptec AIC79XX PCI-X SCSI HBA DRIVER, Rev 1.3.9
        <Adaptec 39320D Ultra320 SCSI adapter>
        aic7902: Ultra320 Wide Channel A, SCSI Id=3D7, PCI-X 101-133Mhz, 51=
2 SCBs

kernel BUG at drivers/block/ll_rw_blk.c:271!
swapper[1]: bugcheck! 0 [1]

Herafter a patch that fixes the problem:

--- linux-2.6.0-test11/drivers/scsi/aic7xxx/aic79xx_osm.c    2003-11-24=20
02:32:03.000000000 +0100
+++ linux-2.6.0-test11.new/drivers/scsi/aic7xxx/aic79xx_osm.c   =20
2003-12-03 14:39:51.000000000 +0100
@@ -62,6 +62,7 @@
=20
 #include <linux/mm.h>        /* For fetching system memory size */
=20
+extern unsigned long blk_max_pfn;
 /*
  * Lock protecting manipulation of the ahd softc list.
  */
@@ -2158,10 +2159,9 @@
 uint64_t
 ahd_linux_get_memsize(void)
 {
-    struct sysinfo si;
-
-    si_meminfo(&si);
-    return ((uint64_t)si.totalram << PAGE_SHIFT);
+    /* Need to take in account the max physical address in case
+     * of discontiguous memory. */
+    return ((uint64_t)blk_max_low_pfn << PAGE_SHIFT);
 }
=20
 /*

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


