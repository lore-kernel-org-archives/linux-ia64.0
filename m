From: Xavier Bru <xavier.bru@bull.net>
Date: Mon, 21 Jun 2004 16:19:56 +0000
Subject: 2.6.7: kallsyms --all-symbols shows a shift in the symbol addreses
Message-Id: <40D70AAC.2010006@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi all!

There is a problem with the all kallsyms support in 2.6.7=20
scripts/kallsyms.c.
Building the table reserves the adresses for all the kernel symbols in=20
first step, then generates the effective addresses of the symbols in step 2.
The problem is that the symbols used to build the symbol table are not=20
taken in account for the size calculation, but are included in the table=20
in step 2.
This makes the table "bigger" than was allocated, and the symbols that=20
come behind are shifted.
This makes kallsyms (and KDB) give wrong addresses for these symbols.

One solution is to exclude from the symbol table the symbols used for=20
building it (As was provided in KDB patch :-)

--- linux-2.6.7.ori/scripts/kallsyms.c    Wed Jun 16 07:20:26 2004
+++ linux-2.6.7/scripts/kallsyms.c    Mon Jun 21 15:26:57 2004
@@ -74,6 +74,12 @@ symbol_valid(struct sym_entry *s)
=20
     if (strstr(s->sym, "_compiled."))
         return 0;
+    if (!strcmp(s->sym, "kallsyms_addresses"))
+        return 0;
+    if (!strcmp(s->sym, "kallsyms_num_syms"))
+        return 0;
+    if (!strcmp(s->sym, "kallsyms_names"))
+        return 0;
=20
     return 1;
 }

herafter the traces of the problem:
----------------------------------
$ grep numnode System.map
a000000100930740 G numnodes
# grep kallsyms_addresses /proc/kallsyms
a000000100894470 d kallsyms_addresses
# grep numnodes  /proc/kallsyms
a000000100930700 d numnodes

Entering kdb (current=3D0xa000000100724000, pid 0) on processor 0 due to=20
Keyboard Entry
[0]kdb> md numnodes
0xa000000100930700 00000000 00000000 00008000 00000000   ................
0xa000000100930710 00799470 a0000001 5f757063 00007075   p.y.... cpu_up..
0xa000000100930720 00799628 a0000001 00000000 00000000   (.y.... ........
0xa000000100930730 00000003 0000000a 000015de 00000000   ........=DE.......
0xa000000100930740 00000004 00000000 00001feb 00001860   ........=EB...`...
                   XXXXXXXX here it is !!!!
0xa000000100930750 00000100 00000000 0000000a 00000028   ............(...
0xa000000100930760 000001f4 00000bb8 00000002 0000003c   =F4...=B8.......<.=
..
0xa000000100930770 00000000 00000032 00010000 00000eb8   ....2.......=B8...
[0]kdb>

With the fix:
------------
$ grep numnodes System.map
a000000100930700 G numnodes

# grep kallsyms_addresses /proc/kallsyms
# grep numnodes  /proc/kallsyms
a000000100930700 d numnodes

Entering kdb (current=3D0xa000000100724000, pid 0) on processor 0 due to=20
Keyboard Entry
[0]kdb> md numnodes
0xa000000100930700 00000004 00000000 00001feb 0000181f   ........=EB.......
                   XXXXXXXX OK
0xa000000100930710 00000100 00000000 0000000a 00000028   ............(...
0xa000000100930720 000001f4 00000bb8 00000002 0000003c   =F4...=B8.......<.=
..

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

