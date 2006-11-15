From: Mel Gorman <mel@csn.ul.ie>
Date: Wed, 15 Nov 2006 16:26:59 +0000
Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <Pine.LNX.4.64.0611151509490.7171@skynet.skynet.ie>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="29444707-151450499-1163603445=:7171"
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--29444707-151450499-1163603445=:7171
Content-Type: TEXT/PLAIN; CHARSET=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0611151612311.7171@skynet.skynet.ie>

On Wed, 15 Nov 2006, Zou, Nanhai wrote:

>> -----Original Message-----
>> From: Mel Gorman [mailto:mel@csn.ul.ie]
>> Sent: 2006=E5=B9=B411=E6=9C=8815=E6=97=A5 7:42
>> To: Zou, Nanhai
>> Cc: Horms; Andy Whitcroft; Linux-IA64; Bob Picco; Andrew Morton; Dave Ha=
nsen;
>> Andi Kleen; Benjamin Herrenschmidt; Paul Mackerras; Keith Mannthey; Luck=
, Tony;
>> KAMEZAWA Hiroyuki; Yasunori Goto; Khalid Aziz
>> Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
>>
>> On Tue, 14 Nov 2006, Zou, Nanhai wrote:
>>
>>>> -----Original Message-----
>>>> From: linux-ia64-owner@vger.kernel.org
>>>> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Mel Gorman
>>>> Sent: 2006=C3=84=C3=AA11=C3=94=C3=8210=C3=88=C3=95 19:47
>>>> To: Zou, Nanhai
>>>> Cc: Horms; Andy Whitcroft; Linux-IA64; Bob Picco; Andrew Morton; Dave
>> Hansen;
>>>> Andi Kleen; Benjamin Herrenschmidt; Paul Mackerras; Keith Mannthey; Lu=
ck,
>> Tony;
>>>> KAMEZAWA Hiroyuki; Yasunori Goto; Khalid Aziz
>>>> Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdum=
p
>>>>
>>>> On Fri, 10 Nov 2006, Zou, Nanhai wrote:
>>>>
>>>>>> -----Original Message-----
>>>>>> From: linux-ia64-owner@vger.kernel.org
>>>>>> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Zou Nan hai
>>>>>> Sent: 2006=C3=84=C3=AA11=C3=94=C3=823=C3=88=C3=95 18:07
>>>>>> To: Mel Gorman
>>>>>> Cc: Horms; Andy Whitcroft; Linux-IA64; Bob Picco; Andrew Morton; Dav=
e
>>>> Hansen;
>>>>>> Andi Kleen; Benjamin Herrenschmidt; Paul Mackerras; Keith Mannthey; =
Luck,
>>>> Tony;
>>>>>> KAMEZAWA Hiroyuki; Yasunori Goto; Khalid Aziz
>>>>>> Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kd=
ump
>>>>>>
>>>>>> On Fri, 2006-11-03 at 17:27, Mel Gorman wrote:
>>>>>>> On Fri, 3 Nov 2006, Zou, Nanhai wrote:
>>>>>>>
>>>>>>>> Hi,
>>>>>>>> =09This patch should fix the issue.
>>>>>>>>
>>>>>>>
>>>>>>> It would appear to fix the issue for IA64 but you are blotting over=
 the
>>>>>>> issue that the map is reporting a one page hole. On arches with rea=
lly
>>>>>>> adjacent regions that are getting merged, the regions will appear t=
o
>>>>>>> overlap by one page. What can happen is something like this
>>>>>>>
>>>>>>> PFN ranges for nodes
>>>>>>> Node 1: 0 -> 1000
>>>>>>> Node 0: 1000 -> 2000
>>>>>>>
>>>>>> Hi,
>>>>>>  But the patch Andy and you are commenting is not my patch...., It w=
as
>>>>>> in the previous thread.
>>>>>> My patch was in the attachment.....
>>>>>>
>>>>>>  Sorry for using outlook to send that patch as attachment, my Linux =
box
>>>>>> was not accessable at the time when I was posting the patch.
>>>>>>  I post the patch again, and copy the discription from my previous m=
ail.
>>>>>>
>>>>>> When ia64 kernel is configured as discontinuous memory model,
>>>>>> active_pages are added through efi_memmap_walk(filter_rsvd_memory,
>>>>>> count_node_pages).
>>>>>> filter_rsvd_memory  will filter out all regions in rsvd_regions incl=
ude
>>>>>> - boot param
>>>>>> - mem map
>>>>>> - initrd
>>>>>> - command line
>>>>>> - **** kernel code and data ***
>>>>>> - kernel map built from efi memmap
>>>>>> - crash kernel reserved region
>>>>>> So the kernel code and data is excluded even without kdump support,
>>>>>> check /proc/iomem and dmesg for early_node_data can verify that.
>>>>>> But magically, the first kernel boots happily without any complain..=
=2E,
>>>>>> I guess that is related to the init value in memmap.
>>>>>>
>>>>>> This patch use another filter to add_acvitive_pages, only exclude cr=
ash
>>>> kernel
>>>>>> reserved region if CONFIG_KEXEC is on.
>>>>>>
>>>>>> Thanks
>>>>>> Zou Nan hai
>>>>>> --- a/arch/ia64/mm/discontig.c=092006-11-02 20:09:47.000000000 -0500
>>>>>> +++ b/arch/ia64/mm/discontig.c=092006-11-02 19:57:27.000000000 -0500
>>>>>> @@ -21,6 +21,7 @@
>>>>>>  #include <linux/acpi.h>
>>>>>>  #include <linux/efi.h>
>>>>>>  #include <linux/nodemask.h>
>>>>>> +#include <linux/kexec.h>
>>>>>>  #include <asm/pgalloc.h>
>>>>>>  #include <asm/tlb.h>
>>>>>>  #include <asm/meminit.h>
>>>>>> @@ -653,8 +654,6 @@ void call_pernode_memory(unsigned long s
>>>>>>  static __init int count_node_pages(unsigned long start, unsigned lo=
ng
>> len,
>>>>>> int node)
>>>>>>  {
>>>>>>  =09unsigned long end =3D start + len;
>>>>>> -
>>>>>> -=09add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
>>>>>>  =09mem_data[node].num_physpages +=3D len >> PAGE_SHIFT;
>>>>>>  =09if (start <=3D __pa(MAX_DMA_ADDRESS))
>>>>>>  =09=09mem_data[node].num_dma_physpages +=3D
>>>>>> @@ -669,7 +668,31 @@ static __init int count_node_pages(unsig
>>>>>>
>>>>>>  =09return 0;
>>>>>>  }
>>>>>> +static __init int add_active_range_wrapper(unsigned long start,
>>>>>> +=09=09unsigned long len, int node)
>>>>>> +{
>>>>>> +=09unsigned long end =3D start + len;
>>>>>> +=09add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
>>>>>> +=09return 0;
>>>>>> +}
>>>>>>
>>>>
>>>> The function name doesn't really tell the reader what it's meant to be
>>>> doing. Something like register_active_ranges() might be a bit better.
>>>>
>>> Ok.
>>>>>> +static int __init
>>>>>> +filter_pernode_memory (unsigned long start, unsigned long end, void
>> *arg)
>>>>>> +{
>>>>>> +=09void (*func)(unsigned long, unsigned long, int);
>>>>>> +=09func =3D arg;
>>>>>> +
>>>>>> +#ifdef CONFIG_KEXEC
>>>>>> +=09if (start > crashk_res.start && start < crashk_res.end)
>>>>>> +=09=09start =3D max(start, crashk_res.end);
>>>>>> +=09if (end > crashk_res.start && end < crashk_res.end)
>>>>>> +=09=09end =3D min(end, crashk_res.start);
>>>>
>>>>
>>>> These two checks appear to deliberatly avoid registering the kernel im=
age
>>>> as an active range. Was that your intention? If so, will you not hit t=
he
>>>> same problem with initmem?
>>>>
>>>  No, the crashk_res.start ~ crashk_res.end is the hole reserved for 2nd
>>> kernel.
>>
>> Then it needs a comment to that effect. It's difficult to see what code =
is
>> executed by the main kernel and what code is executed by the crash kerne=
l.
>>
>>> The kernel himself does not to setup memmap for this area, the
>>> 2nd kernel will handle it.
>>
>> Ok, where does that happen?
>>
>  Ok, I need some explain of how kdump works here...,
> The first kernel leaves a big enough hole, he will not touch the memory=
=20
> in the hole once we have loaded crash dump kernel into the hole. Usually=
=20
> we put an exactly same kernel in that hole. But from first kernel's=20
> point of view, he does not know anything about the second kernel except=
=20
> an entry point. When crash happen, first kernel quickly shutdown the=20
> machine then jump to the entry point. The second kernel will limit its=20
> memory access in that hole expect copy crash dump data from first=20
> kernel's memory range. So this will happen at the second kernel boot=20
> time, the first kernel does not need memory map for the crash area.
>

Ok.

>>> As I have mentioned, this bug also exist even
>>> without kdump patch. You will see first kernels code and data is not
>>> covered by add_active_range if DISCONTIGMEM model is choosen.
>>>
>>
>> But is it's initmem section?
>>
>
>  Yes, initmem section is inside. Please check=20
> arch/ia64/kernel/vmlinux.lds.S the add_active_range is called by a=20
> efi_memmap_walk(filter_rsvd_memory, count_node_pages);=20
> filter_rsvd_memory will exclude everything inside rsvd_region, kernel=20
> code & data is in rsvd_region, please check include/asm-ia64/meminit.h
>

As you say, it's not clear why the normal discontig kernel boots because=20
the regions should have been skipped by add_active_range().

Try your patch and see does it work for kdump. It should work fine in the=
=20
normal case because at very worst, slightly more memmap is allocated than=
=20
is strictly required.

> Thanks
> Zou Nan hai
>
>

--=20
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
--29444707-151450499-1163603445=:7171--
