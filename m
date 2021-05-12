From: David Hildenbrand <david@redhat.com>
Date: Wed, 12 May 2021 16:14:06 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <e132fdd9-65af-1cad-8a6e-71844ebfe6a2@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
 <YJUqrOacyqI+kiKW@dhcp22.suse.cz>
 <792d73e2-5d63-74a5-5554-20351d5532ff@redhat.com>
 <746780E5-0288-494D-8B19-538049F1B891@nvidia.com>
In-Reply-To: <746780E5-0288-494D-8B19-538049F1B891@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Zi Yan <ziy@nvidia.com>, Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

>>
>> As stated somewhere here already, we'll have to look into making alloc_c=
ontig_range() (and main users CMA and virtio-mem) independent of MAX_ORDER =
and mainly rely on pageblock_order. The current handling in alloc_contig_ra=
nge() is far from optimal as we have to isolate a whole MAX_ORDER - 1 page =
-- and on ZONE_NORMAL we'll fail easily if any part contains something unmo=
vable although we don't even want to allocate that part. I actually have th=
at on my list (to be able to fully support pageblock_order instead of MAX_O=
RDER -1 chunks in virtio-mem), however didn't have time to look into it.
>=20
> So in your mind, for gigantic page allocation (> MAX_ORDER), alloc_contig=
_range()
> should be used instead of buddy allocator while pageblock_order is kept a=
t a small
> granularity like 2MB. Is that the case? Isn=E2=80=99t it going to have hi=
gh fail rate
> when any of the pageblocks within a gigantic page range (like 1GB) become=
s unmovable?
> Are you thinking additional mechanism/policy to prevent such thing happen=
ing as
> an additional step for gigantic page allocation? Like your ZONE_PREFER_MO=
VABLE idea?
>=20

I am not fully sure yet where the journey will go , I guess nobody=20
knows. Ultimately, having buddy support for >=3D current MAX_ORDER (IOW,=20
increasing MAX_ORDER) will most probably happen, so it would be worth=20
investigating what has to be done to get that running as a first step.

Of course, we could temporarily think about wiring it up in the buddy like

if (order < MAX_ORDER)
	__alloc_pages()...
else
	alloc_contig_pages()

but it doesn't really improve the situation IMHO, just an API change.

So I think we should look into increasing MAX_ORDER, seeing what needs=20
to be done to have that part running while keeping the section size and=20
the pageblock order as is. I know that at least memory=20
onlining/offlining, cma, alloc_contig_range(), ... needs tweaking,=20
especially when we don't increase the section size (but also if we would=20
due to the way page isolation is currently handled). Having a MAX_ORDER=20
-1 page being partially in different nodes might be another thing to=20
look into (I heard that it can already happen right now, but I don't=20
remember the details).

The next step after that would then be better fragmentation avoidance=20
for larger granularity like 1G THP.

>>
>> Further, page onlining / offlining code and early init code most probabl=
y also needs care if MAX_ORDER - 1 crosses sections. Memory holes we might =
suddenly have in MAX_ORDER - 1 pages might become a problem and will have t=
o be handled. Not sure which other code has to be tweaked (compaction? page=
 isolation?).
>=20
> Can you elaborate it a little more? From what I understand, memory holes =
mean valid
> PFNs are not contiguous before and after a hole, so pfn++ will not work, =
but
> struct pages are still virtually contiguous assuming SPARSE_VMEMMAP, mean=
ing page++
> would still work. So when MAX_ORDER - 1 crosses sections, additional code=
 would be
> needed instead of simple pfn++. Is there anything I am missing?

I think there are two cases when talking about MAX_ORDER and memory holes:

1. Hole with a valid memmap: the memmap is initialize to PageReserved()
    and the pages are not given to the buddy. pfn_valid() and
    pfn_to_page() works as expected.
2. Hole without a valid memmam: we have that CONFIG_HOLES_IN_ZONE thing
    already, see include/linux/mmzone.h. pfn_valid_within() checks are
    required. Doesn't win a beauty contest, but gets the job done in
    existing setups that seem to care.

"If it is possible to have holes within a MAX_ORDER_NR_PAGES, then we=20
need to check pfn validity within that MAX_ORDER_NR_PAGES block.=20
pfn_valid_within() should be used in this case; we optimise this away=20
when we have no holes within a MAX_ORDER_NR_PAGES block."

CONFIG_HOLES_IN_ZONE is just a bad name for this.

(increasing the section size implies that we waste more memory for the=20
memmap in holes. increasing MAX_ORDER means that we might have to deal=20
with holes within MAX_ORDER chunks)

We don't have too many pfn_valid_within() checks. I wonder if we could=20
add something that is optimized for "holes are a power of two and=20
properly aligned", because pfn_valid_within() right not deals with holes=20
of any kind which makes it somewhat inefficient IIRC.

>=20
> BTW, to test a system with memory holes, do you know is there an easy of =
adding
> random memory holes to an x86_64 VM, which can help reveal potential miss=
ing pieces
> in the code? Changing BIOS-e820 table might be one way, but I have no ide=
a on
> how to do it on QEMU.

It might not be very easy that way. But I heard that some arm64 systems=20
have crazy memory layouts -- maybe there, it's easier to get something=20
nasty running? :)

https://lkml.kernel.org/r/YJpEwF2cGjS5mKma@kernel.org

I remember there was a way to define the e820 completely on kernel=20
cmdline, but I might be wrong ...

--=20
Thanks,

David / dhildenb
