From: "Zi Yan" <ziy@nvidia.com>
Date: Thu, 06 May 2021 19:03:22 +0000
Subject: Re: [RFC PATCH 1/7] mm: sparse: set/clear subsection bitmap when pages are onlined/offlined.
Message-Id: <71EE13C0-9CF7-4F1F-9C17-64500A854BD8@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_43E29186-BF6B-431C-81FF-73AB6A9D28BD_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <20210506152623.178731-2-zi.yan@sent.com>
 <06dfaf69-1173-462c-b85f-8715cb8d108c@redhat.com>
In-Reply-To: <06dfaf69-1173-462c-b85f-8715cb8d108c@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--=_MailMate_43E29186-BF6B-431C-81FF-73AB6A9D28BD_=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On 6 May 2021, at 13:48, David Hildenbrand wrote:

> On 06.05.21 17:26, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> subsection bitmap was set/cleared when a section is added/removed, but=

>> pfn_to_online_page() uses subsection bitmap to check if the page is
>> online, which is not accurate. It was working when a whole section is
>> added/removed during memory hotplug and hotremove. When the following
>> patches enable memory hotplug and hotremove for subsections,
>> subsection bitmap needs to be changed during page online/offline time,=

>> otherwise, pfn_to_online_page() will not give right answers. Move the
>> subsection bitmap manipulation code from section_activate() to
>> online_mem_sections() and section_deactivate() to
>> offline_mem_sections(), respectively.
>>
>> Signed-off-by: Zi Yan <ziy@nvidia.com>
>> ---
>>   mm/sparse.c | 36 +++++++++++++++++++++++++++++++++---
>>   1 file changed, 33 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index b2ada9dc00cb..7637208b8874 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -606,6 +606,7 @@ void __init sparse_init(void)
>>    #ifdef CONFIG_MEMORY_HOTPLUG
>>  +static int fill_subsection_map(unsigned long pfn, unsigned long nr_p=
ages);
>>   /* Mark all memory sections within the pfn range as online */
>>   void online_mem_sections(unsigned long start_pfn, unsigned long end_=
pfn)
>>   {
>> @@ -621,9 +622,12 @@ void online_mem_sections(unsigned long start_pfn,=
 unsigned long end_pfn)
>>    		ms =3D __nr_to_section(section_nr);
>>   		ms->section_mem_map |=3D SECTION_IS_ONLINE;
>> +		fill_subsection_map(pfn, min(end_pfn, pfn + PAGES_PER_SECTION) - pf=
n);
>>   	}
>>   }
>>  +static int clear_subsection_map(unsigned long pfn, unsigned long nr_=
pages);
>> +static bool is_subsection_map_empty(struct mem_section *ms);
>>   /* Mark all memory sections within the pfn range as offline */
>>   void offline_mem_sections(unsigned long start_pfn, unsigned long end=
_pfn)
>>   {
>> @@ -641,7 +645,13 @@ void offline_mem_sections(unsigned long start_pfn=
, unsigned long end_pfn)
>>   			continue;
>>    		ms =3D __nr_to_section(section_nr);
>> -		ms->section_mem_map &=3D ~SECTION_IS_ONLINE;
>> +
>> +		if (end_pfn < pfn + PAGES_PER_SECTION) {
>> +			clear_subsection_map(pfn, end_pfn - pfn);
>> +			if (is_subsection_map_empty(ms))
>> +				ms->section_mem_map &=3D ~SECTION_IS_ONLINE;
>> +		} else
>> +			ms->section_mem_map &=3D ~SECTION_IS_ONLINE;
>>   	}
>>   }
>>  @@ -668,6 +678,17 @@ static void free_map_bootmem(struct page *memmap=
)
>>   	vmemmap_free(start, end, NULL);
>>   }
>>  +static int subsection_map_intersects(struct mem_section *ms, unsigne=
d long pfn,
>> +				     unsigned long nr_pages)
>> +{
>> +	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) =3D { 0 };
>> +	unsigned long *subsection_map =3D &ms->usage->subsection_map[0];
>> +
>> +	subsection_mask_set(map, pfn, nr_pages);
>> +
>> +	return bitmap_intersects(map, subsection_map, SUBSECTIONS_PER_SECTIO=
N);
>> +}
>> +
>>   static int clear_subsection_map(unsigned long pfn, unsigned long nr_=
pages)
>>   {
>>   	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) =3D { 0 };
>> @@ -760,6 +781,12 @@ static void free_map_bootmem(struct page *memmap)=

>>   	}
>>   }
>>  +static int subsection_map_intersects(struct mem_section *ms, unsigne=
d long pfn,
>> +				     unsigned long nr_pages)
>> +{
>> +	return 0;
>> +}
>> +
>>   static int clear_subsection_map(unsigned long pfn, unsigned long nr_=
pages)
>>   {
>>   	return 0;
>> @@ -800,7 +827,10 @@ static void section_deactivate(unsigned long pfn,=
 unsigned long nr_pages,
>>   	struct page *memmap =3D NULL;
>>   	bool empty;
>>  -	if (clear_subsection_map(pfn, nr_pages))
>> +	if (WARN((IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP) && !ms->usage) ||
>> +		 subsection_map_intersects(ms, pfn, nr_pages),
>> +				"section already deactivated (%#lx + %ld)\n",
>> +				pfn, nr_pages))
>>   		return;
>>    	empty =3D is_subsection_map_empty(ms);
>> @@ -855,7 +885,7 @@ static struct page * __meminit section_activate(in=
t nid, unsigned long pfn,
>>   		ms->usage =3D usage;
>>   	}
>>  -	rc =3D fill_subsection_map(pfn, nr_pages);
>> +	rc =3D !nr_pages || subsection_map_intersects(ms, pfn, nr_pages);
>>   	if (rc) {
>>   		if (usage)
>>   			ms->usage =3D NULL;
>>
>
> If I am not missing something, this is completely broken for devmem/ZON=
E_DEVICE that never onlines pages. But also when memory blocks are never =
onlined, this would be just wrong. Least thing you would need is a sub-se=
ction online map.

Thanks for pointing this out. I did not know that devmem/ZONE_DEVICE neve=
r onlines pages.

>
> But glimpsing at patch #2, I'd rather stop right away digging deeper in=
to this series :)

What is the issue of patch 2, which makes pageblock_order a variable all =
the time? BTW, patch 2 fixes a bug by exporting pageblock_order, since wh=
en HUGETLB_PAGE_SIZE_VARIABLE is set, virtio-mem will not see pageblock_o=
rder as a variable, which could happen for PPC_BOOK2S_64 with virtio-men =
enabled, right? Or is this an invalid combination?

>
> I think what would really help is drafting a design of how it all could=
 look like and then first discussing the high-level design, investigating=
 how it could play along with all existing users, existing workloads, and=
 existing use cases. Proposing such changes without a clear picture in mi=
nd and a high-level overview might give you some unpleasant reactions fro=
m some of the developers around here ;)

Please see my other email for a high-level design. Also I sent the patchs=
et as a RFC to gather information on users, workloads, use cases I did no=
t know about and I learnt a lot from your replies. :) Feedback is always =
welcome, but I am not sure why it needs to make people unpleasant. ;)


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_43E29186-BF6B-431C-81FF-73AB6A9D28BD_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAmCUPXoPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKgIIP/1oBHjFV/3vJgeuxg081qFnKHZL7261t04Av
tssn5jMT+aaHApq+OMqo7k4wuZfrljqBjU9W45kYpOlIhhYJ3QTnIIotykxsb0yK
gu0l9EIEhtm4jYncABlgJOK6JlLXlzKhgreegTYUq7yLblz10bwNZdZq78rw8KSd
fPJ3v4UJ+QWEB9isfaisfPe54Icu9cIAaoK+5g9tD7lkgqqmOTqy0RuLriz9EQxa
qzM2/5k9ftfw0LixMxuJj8LQkl16OLS6utnrUP8neQ2pBQg1J4jF1PteWLqr2zLl
jo4sz4uzLzeTMaUdmtW1P/OyWgqPSV482BQdPRi7Ui9k3nGB9op8eA2cOHvS5W4r
V0MdFQUc9H4BVavcizDpcGbzlcRGoKxeHVd1w7AISS54fgsot11SWHCJ398c3hH9
89pQg6PrQhtIwitzQW+6EwkuGMVWXXV02f2rI3KrGpmdu2+7lVSVveEmMEzujUsv
+RSjQdvgHehIv6FM5scKVb4YkexTTRCuugYQOT11sALGbFnZ5ECIT6M0dKvoxo5k
6dB0TXAxBrdmH1e+InXeoOXwLQAzArtkqI7q5FC7pbXY4td9XOAAz9Ap4Kdgjm8r
z92AtEGkBdfHcOTQ1MWDppYAIcEQTH4uiPseAl5OpKc6fiEE3zD3vB3EsBwdaBGK
wrvaXB5d
=pEsf
-----END PGP SIGNATURE-----

--=_MailMate_43E29186-BF6B-431C-81FF-73AB6A9D28BD_=--
