From: Xavier Bru <Xavier.Bru@bull.net>
Date: Tue, 26 Aug 2003 15:39:32 +0000
Subject: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106191285716253@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


... but 2.5.72 was OK :-)

Booting on a 4 nodes Itanium machine, with=20
	CONFIG_NUMA=3Dy
	CONFIG_ACPI_NUMA=3Dy
	CONFIG_DISCONTIGMEM=3Dy
	# CONFIG_VIRTUAL_MEM_MAP is not set

system hangs after a message:
"On node 1 totalpages: <a very very BIG number that looks garbage>"

Having a look to the code, it seems that problem is due to memory
initialisation changes:
 . unlike 2.5.72, find_memory() is now called before
acpi_numa_init(), and supposes that numnodes =3D 1. So only 1
bootmem_data_t struct is initialised.
 . acpi_numa_init() then finds in SRAT that 4 nodes exist.
 . when paging_init calls discontig_paging_init only bootmem_data_t
for node 0 is initialized, and garbage is found for nodes 1 to 3.

I tried to put find_memory()  after acpi_numa_init() as in 2.5.72, but=20
now we get:
     bootmem alloc of 100 bytes failed! in acpi_table_init()
that now uses the bootmem allocator.

I wonder what should be the right order for initialisation, and if
there are ia64 platforms running 2.6.0 with CONFIG_NUMA. Any help is
apreciated.
Thanks in advance.
Xavier.

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________
