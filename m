From: Xavier Bru <xavier.bru@bull.net>
Date: Thu, 27 Nov 2003 15:42:12 +0000
Subject: Missing code in bootmem.c for discontigmem
Message-Id: <marc-linux-ia64-106994770902664@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello all,

Booting 2.6.0-test10 on Numa system, we fall in:
    Kernel panic: map_single: bounce buffer is not DMA'ble
due to alloc_bootmem_low_pages() returning a highmem address at sw IO TLB
initialization:
    Placing software IO TLB between 0xe0000030014e4000 - 0xe0000030016e4000
This was OK in test9 due to init_bootmem_core() sorting the pgdat_list.
Restoring the previous code, system boots OK (using the last scsi=20
patches :-)
Herafter the patch:

diff --exclude-from /home2/xb/proc/diff.exclude -Nur 0t10/mm/bootmem.c=20
linux-2.6.0-test10.old/mm/bootmem.c
--- 0t10/mm/bootmem.c    2003-11-24 02:31:28.000000000 +0100
+++ linux-2.6.0-test10.old/mm/bootmem.c    2003-11-27 15:19:53.000000000=20
+0100
@@ -48,8 +48,24 @@
     bootmem_data_t *bdata =3D pgdat->bdata;
     unsigned long mapsize =3D ((end - start)+7)/8;
=20
-    pgdat->pgdat_next =3D pgdat_list;
-    pgdat_list =3D pgdat;
+
+    /*
+     * sort pgdat_list so that the lowest one comes first,
+     * which makes alloc_bootmem_low_pages work as desired.
+     */
+    if (!pgdat_list || pgdat_list->node_start_pfn >=20
pgdat->node_start_pfn) {
+        pgdat->pgdat_next =3D pgdat_list;
+        pgdat_list =3D pgdat;
+    } else {
+        pg_data_t *tmp =3D pgdat_list;
+        while (tmp->pgdat_next) {
+            if (tmp->pgdat_next->node_start_pfn > pgdat->node_start_pfn)
+                break;
+            tmp =3D tmp->pgdat_next;
+        }
+        pgdat->pgdat_next =3D tmp->pgdat_next;
+        tmp->pgdat_next =3D pgdat;
+    }
=20
     mapsize =3D (mapsize + (sizeof(long) - 1UL)) & ~(sizeof(long) - 1UL);
     bdata->node_bootmem_map =3D phys_to_virt(mapstart << PAGE_SHIFT);

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


