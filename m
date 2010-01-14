From: Alex Chiang <achiang@hp.com>
Date: Thu, 14 Jan 2010 00:53:04 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <20100114005304.GC27766@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001130851310.24496@router.home>
In-Reply-To: <alpine.DEB.2.00.1001130851310.24496@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org

* Christoph Lameter <cl@linux-foundation.org>:
> On Tue, 12 Jan 2010, Alex Chiang wrote:
>=20
> > My HP rx8640 (ia64, 16 CPUs) is experiencing a bad paging request
> > during boot.
>=20
> Hmmm... Thats with 64k page size?

Yes.

CONFIG_IA64_PAGE_SIZE_64KB=3Dy

> > SLUB: Unable to allocate memory from node 2
> > SLUB: Allocating a useless per node structure in order to be able to co=
ntinue
>=20
> Huh? What wrong with node 2?

I've seen that message for quite some time now.

Here's some info from the EFI shell.

Shell> dimmconfig

MEMORY INFORMATION

         Cab/     Total    Active   Failed  SW Deconf HW Deconf
   Cell  Slot      Mem      Mem     DIMMs     DIMMs     DIMMs   Unknown
   ----  -----  --------- --------- ------  --------- --------- -------
     0    0/0    32768 MB  32768 MB    0         0         0        0
     1    0/1    32768 MB  32768 MB    0         0         0        0

   Active Memory           : 65536 MB
     Interleaved Memory    :   512 MB
     NonInterleaved Memory : 65024 MB
   Installed Memory        : 65536 MB

Firmware puts each cell into a NUMA node, so we should really
only have 2 nodes, but for some reason, that 3rd node gets
created too. I haven't inspected the SRAT/SLIT on this machine
recently, but can do so if you want me to.

> >  [<a0000001001a7c60>] kmem_cache_open+0x420/0xca0
> >                                 sp=E00007860955fdf0 bsp=E0000786095512e0
> >  [<a0000001001a8cf0>] dma_kmalloc_cache+0x2d0/0x440
> >                                 sp=E00007860955fdf0 bsp=E000078609551290
>=20
> Maybe we miscalculated the number of DMA caches needed.
>=20
> Does this patch fix it?

Nope, same oops.

Hm... from the boot log

ACPI: SLIT table looks invalid. Not used.
Number of logical nodes in system =3D 3
Number of memory chunks in system =3D 5
...
Virtual mem_map starts at 0xa07ffffe5a400000
Zone PFN ranges:
  DMA      0x00000001 -> 0x00010000
  Normal   0x00010000 -> 0x0787fc00
Movable zone start PFN for each node
early_node_map[5] active PFN ranges
    2: 0x00000001 -> 0x00001ffe
    0: 0x07002000 -> 0x07005db7
    0: 0x07005db8 -> 0x0707fb00
    1: 0x07800000 -> 0x0787fbd9
    1: 0x0787fbe8 -> 0x0787fbfd
On node 0 totalpages: 514815
free_area_init_node: node 0, pgdat e000070020080000, node_mem_map a07fffffe=
2470000
  Normal zone: 440 pages used for memmap
  Normal zone: 514375 pages, LIFO batch:1
On node 1 totalpages: 523246
free_area_init_node: node 1, pgdat e000078000090080, node_mem_map a07ffffff=
e400000
  Normal zone: 448 pages used for memmap
  Normal zone: 522798 pages, LIFO batch:1
On node 2 totalpages: 8189
free_area_init_node: node 2, pgdat e000000000120100, node_mem_map a07ffffe5=
a400000
  DMA zone: 7 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 8182 pages, LIFO batch:0

So the kernel doesn't like the SLIT; does it go off and create
its own NUMA nodes then?

/ac

