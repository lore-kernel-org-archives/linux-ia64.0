From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 20 Oct 2005 20:36:28 +0000
Subject: [PATCH 0/1] ia64:  numa emulation
Message-Id: <1129840588.6182.36.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Subdivide an ia64 SMP platform into fake numa nodes -- e.g., for testing
fixes and tool development w/o having access to actual numa platform.

I developed this patch when I saw Andi Kleen's x86_64 numa emulation
patch and have been maintaining it for my own use since 2.6.10.  Peter
Chubb suggested that I posted it to the ia64 list for discussion, and
perhaps [someday] possible inclusion in the kernel.  Below is a longish
description of the patch.  I'll post the actual patch as a separate
message.

By the way:  I know of at least one other such patch that Bob Picco
maintains for his use, altho' I wasn't aware of it when I put this on
together.  Some messages I've seen on this [or maybe other?] mailing
list lead me to believe that other such patches may exist.

---
IA64 Numa Emulation

How to configure:

Select NUMA_EMU config parameter.

[shamelessly copied from Andi Kleen's x86_64 numa emulation]

----------------
How to invoke:

boot command line argument:  numa=FAke[=3DN]

[also copied from Andi's x86_64 numa emulation]

N =3D number of fake nodes requested, default=3D2.
N is constrained to min( # actual cpus, MAX_NUMNODES )
N < 2 abandons numa emulation

----------------
Other limitations:

1) won't attempt to subdivide a NUMA platform.  Abandons emulation
   if system ACPI provides an SRAT with >1 proximity domain.

2) no attempt to support memory-less nodes nor cpu-less nodes.

3) no way to specify memory per node.  simply divides existing phys
   mem ~equally amoung emulated nodes.  Excess [remainder] to node 0.

4) simple round robin assignment of phys cpus to emulated nodes.
   Will require work for, e.g., multicore/SMT if we want siblings
   in same node.  To do otherwise would probably confuse the
   scheduling domain setup.

----------------
Approach:

During acpi_arch_numa_fixup():
after finding numa=FAke[=3DN] boot parameter, and validating N,
<=3D1 SRAT proximity domain, etc., populate variables and structures
that would be filled from ACPI/SRAT/SLIT in actual numa platform: =20

	+ pxm_flags[] -- array of SRAT proximity domains
	+ node_cpuid[] -- array of {phys cpuid, pxm/node id}
		  indexed by logical cpu id.
	+ srat_num_cpus -- # of cpus found in [emulated] SRAT
	+ node_memblks[] -- array of phys memory ranges and
	  pxm/node affinity for each
	+ num_node_memblks -- number of valid entries in=20
	  node_memblks[] array.
	+ slit_table -- pointer to emulated ACPI SLIT

Then, acpi_arch_numa_fixup() will just "do the right thing".  Emulation
is at low enough level that the rest of the system required no
additional
changes.

Note:  I use a custom EFI memory map walker to find physical memory,
regardless of its usage to populate the node_memblks[] and to compute
total memory.

----------------
Interaction with Virtual Mem Map and Buddy System:

IA64 [prior to sparesmem] uses a virtual memory map for page structs.
The
virtual mem map for each node must be aligned on on max order boundary.
For a real system, with holes between nodes, it does not matter if
memory
[page structs] actually exist for all virtual pages in the virtual mem
map.
However, with emulated nodes, there may be no holes between the emulated
nodes' assigned memory.  Therefore, the boundaries between nodes must be
on a max order boundary.  Otherwise, pages under the virtual mem map
for,
say, node 1 that is rounded down to max order boundary will be assigned
to
both node 0 AND node 1.  [Voice of experience ;-)] =20

So, I have to round UP the boundary between nodes to a max order
boundary.
I had to decrease the CONFIG_FORCE_MAX_ZONEORDER to 14 [256M boundary]
when
numa emulation configured in to give node 0 sufficient memory on
smallish
[~4GB] systems.

Also, because of interaction of max order and huge tlb fs [hard coded
HPAGE_SHIFT_DEFAULT], I disable hugetlbfs when numa emulation is
configured.=20
Back around 2.6.10, I recall seeing discussion of dynamically sizing
hugetlbfs
based on max order.  I haven't tracked this to see if it went in.  But,
if it
did, one could reenable hugetlbfs and adapted to the reduced max order
automatically.

None of this may be required with sparsemem.

----------------
Testing:

I have tested this Numa emulation on an HP rx2600 [2-cpu ia64] with 2-
nodes
[of course!] under each kernel release since 2.6.10.  I tested on an
rx46xx
[4-cpus] with 2, 3, and 4 nodes under 2.6.13.  Also, under 2.6.13, I
layered
on the memory hotplug patch series from sr71.net, along with Marcello's=20
migration cache and Ray Bryant's manual page migration patches.  With
this
config, I was able to migrate pages between emulated nodes.

Your mileage may vary...

Lee Schermerhorn


