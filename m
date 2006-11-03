From: Mel Gorman <mel@csn.ul.ie>
Date: Fri, 03 Nov 2006 09:27:24 +0000
Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <Pine.LNX.4.64.0611030916230.9787@skynet.skynet.ie>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="29444707-455934317-1162546044=:9787"
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--29444707-455934317-1162546044=:9787
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 3 Nov 2006, Zou, Nanhai wrote:

> Hi,
> =09This patch should fix the issue.
>

It would appear to fix the issue for IA64 but you are blotting over the=20
issue that the map is reporting a one page hole. On arches with really=20
adjacent regions that are getting merged, the regions will appear to=20
overlap by one page. What can happen is something like this

PFN ranges for nodes
Node 1: 0 -> 1000
Node 0: 1000 -> 2000

If your fix was applied, the end effect would be that the nodes appear to=
=20
overlap. The last page on node 1 would end up on the free lists of node 0=
=20
because the memmap for that page will be incorrectly initialised twice.=20
While it wouldn't be very noticeable, it's still buggy.

The right fix is to fix the map. Alternatively, change=20
add_active_range(nid, start_pfn, end_pfn) to add_active-range(nid,=20
start_pfn, end_pfn+1) in the arch-specific code if you know it's the right=
=20
thing to do.

> Thanks
> Zou Nan hai
>
>> -----Original Message-----
>> From: Mel Gorman [mailto:mel@csn.ul.ie]
>> Sent: 2006=C4=EA11=D4=C23=C8=D5 0:27
>> To: Horms
>> Cc: Andy Whitcroft; Zou, Nanhai; linux-ia64@vger.kernel.org; Bob Picco; =
Andrew
>> Morton; Dave Hansen; Andi Kleen; Benjamin Herrenschmidt; Paul Mackerras;=
 Keith
>> Mannthey; Luck, Tony; KAMEZAWA Hiroyuki; Yasunori Goto; Khalid Aziz
>> Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
>>
>> On Thu, 2 Nov 2006, Horms wrote:
>>
>>> On Wed, Nov 01, 2006 at 09:38:38AM +0000, Mel Gorman wrote:
>>>>
>>>> Plan C
>>>>
>>>> Call add_active_ranges() for the the PFN ranges initmem reside in.
>>>> Look at free_initmem() to see how to get the virtual address of the
>>>> range is found and make the appropriate conversion. A variation is to
>>>> call add_active_ranges() for the PFN range the whole kernel resides in
>>>> if you have that information for the crash kernel.
>>>
>>> I've made a version of this approach that seems to work.
>>> I had to update add_active_range so that it merges
>>> ranges that are not overlapping, but do create a continous range.
>>> Is this a correct thing to do?
>>>
>>
>> It's a bit unlikely it's the correct fix. As you can see, the
>> add_active_range() is already able to merge contiguous ranges. If the
>> calls imply there is a one page hole, then there is a one page hole. If
>> the caller is wrong and there isn't a one-page hole, then fix the caller
>> walking the map. Power for example currently merges large numbers of
>> adjacent regions that are registered separetly.
>>
>>
>>> --
>>> Horms
>>>  H: http://www.vergenet.net/~horms/
>>>  W: http://www.valinux.co.jp/en/
>>>
>>> Index: linux-2.6/mm/page_alloc.c
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> --- linux-2.6.orig/mm/page_alloc.c=092006-11-02 16:17:17.000000000 +090=
0
>>> +++ linux-2.6/mm/page_alloc.c=092006-11-02 16:17:22.000000000 +0900
>>> @@ -2407,7 +2407,7 @@
>>> =09=09=09return;
>>>
>>> =09=09/* Merge forward if suitable */
>>> -=09=09if (start_pfn <=3D early_node_map[i].end_pfn &&
>>> +=09=09if (start_pfn <=3D early_node_map[i].end_pfn + 1 &&
>>> =09=09=09=09end_pfn > early_node_map[i].end_pfn) {
>>> =09=09=09early_node_map[i].end_pfn =3D end_pfn;
>>> =09=09=09return;
>>> @@ -2415,7 +2415,7 @@
>>>
>>> =09=09/* Merge backward if suitable */
>>> =09=09if (start_pfn < early_node_map[i].end_pfn &&
>>> -=09=09=09=09end_pfn >=3D early_node_map[i].start_pfn) {
>>> +=09=09=09=09end_pfn + 1 >=3D early_node_map[i].start_pfn) {
>>> =09=09=09early_node_map[i].start_pfn =3D start_pfn;
>>> =09=09=09return;
>>> =09=09}
>>> Index: linux-2.6/arch/ia64/mm/discontig.c
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> --- linux-2.6.orig/arch/ia64/mm/discontig.c=092006-11-02
>> 16:17:59.000000000 +0900
>>> +++ linux-2.6/arch/ia64/mm/discontig.c=092006-11-02 16:18:03.000000000
>> +0900
>>> @@ -689,6 +689,8 @@
>>> =09arch_sparse_init();
>>>
>>> =09efi_memmap_walk(filter_rsvd_memory, count_node_pages);
>>> +=09add_active_range(0, ia64_tpa(_text) >> PAGE_SHIFT,
>>> +=09                 (ia64_tpa(_end) -1 ) >> PAGE_SHIFT);
>>>
>>> #ifdef CONFIG_VIRTUAL_MEM_MAP
>>> =09vmalloc_end -=3D PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
>>>
>>
>> --
>> Mel Gorman
>> Part-time Phd Student                          Linux Technology Center
>> University of Limerick                         IBM Dublin Software Lab
>

--=20
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
--29444707-455934317-1162546044=:9787--
