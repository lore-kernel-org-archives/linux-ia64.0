From: "Zi Yan" <ziy@nvidia.com>
Date: Thu, 06 May 2021 18:49:09 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <3A6D54CF-76F4-4401-A434-84BEB813A65A@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_4E6142BD-3CD1-474B-93C8-703340E8202A_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
 <9D7FD316-988E-4B11-AC1C-64FF790BA79E@nvidia.com>
 <3a51f564-f3d1-c21f-93b5-1b91639523ec@redhat.com>
 <16962E62-7D1E-4E06-B832-EC91F54CC359@nvidia.com>
 <f3a2152c-685b-2141-3e33-b2bcab8b6010@redhat.com>
In-Reply-To: <f3a2152c-685b-2141-3e33-b2bcab8b6010@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--=_MailMate_4E6142BD-3CD1-474B-93C8-703340E8202A_=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On 6 May 2021, at 12:28, David Hildenbrand wrote:

> On 06.05.21 17:50, Zi Yan wrote:
>> On 6 May 2021, at 11:40, David Hildenbrand wrote:
>>
>>>>>> The last patch increases SECTION_SIZE_BITS to demonstrate the use =
of memory
>>>>>> hotplug/hotremove subsection, but is not intended to be merged as =
is. It is
>>>>>> there in case one wants to try this out and will be removed during=
 the final
>>>>>> submission.
>>>>>>
>>>>>> Feel free to give suggestions and comments. I am looking forward t=
o your
>>>>>> feedback.
>>>>>
>>>>> Please not like this.
>>>>
>>>> Do you mind sharing more useful feedback instead of just saying a lo=
t of No?
>>>
>>> I remember reasoning about this already in another thread, no? Either=
 you're ignoring my previous feedback or my mind is messing with me.
>>
>> I definitely remember all your suggestions:
>>
>> 1. do not use CMA allocation for 1GB THP.
>> 2. section size defines the minimum size in which we can add_memory(),=
 so we cannot increase it.
>>
>> I am trying an alternative here. I am not using CMA allocation and not=
 increasing the minimum size of add_memory() by decoupling the memory blo=
ck size from section size, so that add_memory() can add a memory block sm=
aller (as small as 2MB, the subsection size) than section size. In this w=
ay, section size can be increased freely. I do not see the strong tie bet=
ween add_memory() and section size, especially we have subsection bitmap =
support.
>
> Okay, let me express my thoughts, I could have sworn I explained back t=
hen why I am not a friend of messing with the existing pageblock size:

Thanks for writing down your thoughts in detail. I will clarify my high-l=
evel plan below too.

>
> 1. Pageblock size
>
> There are a couple of features that rely on the pageblock size to be re=
asonably small to work as expected. One example is virtio-balloon free pa=
ge reporting, then there is virtio-mem (still also glued MAX_ORDER) and w=
e have CMA (still also glued to MAX_ORDER). Most probably there are more.=
 We track movability/ page isolation per pageblock; it's the smallest gra=
nularity you can effectively isolate pages or mark them as CMA (MIGRATE_I=
SOLATE, MIGRATE_CMA). Well, and there are "ordinary" THP / huge pages mos=
t of our applications use and will use, especially on smallish systems.
>
> Assume you bump up the pageblock order to 1G. Small VMs won't be able t=
o report any free pages to the hypervisor. You'll take the "fine-grained"=
 out of virtio-mem. Each CMA area will have to be at least 1G big, which =
turns CMA essentially useless on smallish systems (like we have on arm64 =
with 64k base pages -- pageblock_size is 512MB and I hate it).

I understand the issue of having large pageblock in small systems. My pla=
n for this issue is to make MAX_ORDER a variable (pageblock size would be=
 set according to MAX_ORDER) that can be adjusted based on total memory a=
nd via boot time parameter. My apology since I did not state this clearly=
 in my cover letter and it confused you. When we have a boot time adjusta=
ble MAX_ORDER, large pageblock like 1GB would only appear for systems wit=
h large memory. For small VMs, pageblock size would stay at 2MB, so all y=
our concerns on smallish systems should go away.

>
> Then, imagine systems that have like 4G of main memory. By stopping gro=
uping at 2M and instead grouping at 1G you can very easily find yourself =
in the system where all your 4 pageblocks are unmovable and you essential=
ly don't optimize for huge pages in that environment any more.
>
> Long story short: we need a different mechanism on top and shall leave =
the pageblock size untouched, it's too tightly integrated with page isola=
tion, ordinary THP, and CMA.

I think it is better to make pageblock size adjustable based on total mem=
ory of a system. It is not reasonable to have the same pageblock size acr=
oss systems with memory sizes from <1GB to several TBs. Do you agree?

>
> 2. Section size
>
> I assume the only reason you want to touch that is because pageblock_si=
ze <=3D section_size, and I guess that's one of the reasons I dislike it =
so much. Messing with the section size really only makes sense when we wa=
nt to manage metadata for larger granularity within a section.

Perhaps it is worth checking if it is feasible to make pageblock_size > s=
ection_size, so we can still have small sections when pageblock_size are =
large. One potential issue for that is when PFN discontinues at section b=
oundary, we might have partial pageblock when pageblock_size is big. I gu=
ess supporting partial pageblock (or different pageblock sizes like you m=
entioned below ) would be the right solution.

>
> We allocate metadata per section. We mark whole sections early/online/p=
resent/.... Yes, in case of vmemmap, we manage the memmap in smaller gran=
ularity using the sub-section map, some kind of hack to support some ZONE=
_DEVICE cases better.
>
> Let's assume we introduce something new "gigapage_order", corresponding=
 to 1G. We could either decide to squeeze the metadata into sections, hav=
ing to increase the section size, or manage that metadata differently.
>
> Managing it differently certainly makes the necessary changes easier. I=
nstead of adding more hacks into sections, rather manage that metadata at=
 differently place / in a different way.

Can you elaborate on managing it differently?

>
> See [1] for an alternative. Not necessarily what I would dream off, but=
 just to showcase that there might be alternative to group pages.

I saw this patch too. It is an interesting idea to separate different all=
ocation orders into different regions, but it would not work for gigantic=
 page allocations unless we have large pageblock size to utilize existing=
 anti-fragmentation mechanisms.


>
> 3. Grouping pages > pageblock_order
>
> There are other approaches that would benefit from grouping at > pagebl=
ock_order and having bigger MAX_ORDER. And that doesn't necessarily mean =
to form gigantic pages only, we might want to group in multiple granulari=
ty on a single system. Memory hot(un)plug is one example, but also optimi=
zing memory consumption by powering down DIMM banks. Also, some architect=
ures support differing huge page sizes (aarch64) that could be improved w=
ithout CMA. Why not have more than 2 THP sizes on these systems?
>
> Ideally, we'd have a mechanism that tries grouping on different granula=
rity, like for every order in pageblock_order ... max_pageblock_order (e.=
g., 1 GiB), and not only add one new level of grouping (or increase the s=
ingle grouping size).

I agree. In some sense, supporting partial pageblock and increasing pageb=
lock size (e.g., to 1GB) is, at the high level, quite similar to having m=
ultiple pageblock sizes. But I am not sure if we really want to support m=
ultiple pageblock sizes, since it creates pageblock fragmentation when we=
 want to change migratetype for part of a pageblock. This means we would =
break a large pageblock into small ones if we just want to steal a subset=
 of pages from MOVEABLE for UNMOVABLE allocations. Then pageblock loses i=
ts most useful anti-fragmentation feature. Also it seems to be a replicat=
ion of buddy allocator functionalities when it comes to pageblock split a=
nd merge.


The above is really a nice discussion with you on pageblock, section, mem=
ory hotplug/hotremove, which also helps me understand more on the issues =
with increasing MAX_ORDER to enable 1GB page allocation.

In sum, if I get it correctly, the issues I need to address are:

1. large pageblock size (which is needed when we bump MAX_ORDER for gigan=
tic page allocation from buddy allocator) is not good for machines with s=
mall memory.

2. pageblock size is currently tied with section size (which made me want=
 to bump section size).


For 1, I think making MAX_ORDER a variable that can be set based on total=
 memory size and adjustable via boot time parameter should solve the prob=
lem. For small machines, we will keep MAX_ORDER as small as we have now l=
ike 4MB, whereas for large machines, we can increase MAX_ORDER to utilize=
 gigantic pages.

For 2, supporting partial pageblock and allow a pageblock to cross multip=
le sections would break the tie between pageblock size and section to sol=
ve the issue.

I am going to look into them. What do you think?

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_4E6142BD-3CD1-474B-93C8-703340E8202A_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAmCUOiUPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKQxwQAIwdvlJCO/3aI45RAe4SVGdMAicXn3W5vkpK
QwXwEyiAWQDQN7VFEZDpffx/A4sP3D4Seh2V8l+xBj3cNnElnbWzbxnm7D/9TuOi
QiXpADUS5MGwO1JAtqQ/fgwuOjPIKXXvw1e/8u5NRh17CCoATGc165leSJqrTt6T
XntZXgH76lVxmYO0bswzb5yojVVo3OKiIlpAy1dtDyELzw67dnof0h3qnRTOlFJo
XQUIMfA3KeVTVvR+66IWPxjr6Gqjibd3ntZMkGVUB54yjPClEJ1+yyBfVJDvnfag
v8TosgUBN9gXeUi1uk2TngTwP7ydsq6xec/8EI7/f0RUmY+LJnoyIXhirI1rb3fB
PnyJch0jTyqwdQ0m/UxCS9w2meAfbpkUDxUcXLYa1eGq5B6zWiagEmpEw6plxa3P
yRl+r3GUfwUIRP3lAVkP+gNjuh4xmnk9eia5DrSEbSlSyDozCNYfhpO0GRwxpyXJ
zZBoWmI+suY582hIPI5rfXJDvypet5zeq8Ao3eyIFqu99PQzDlJIG1HflnK0+XIE
03lHj5E/vGGs8eFE6MrAIhcaRU5YZVFFlk7hrLi7XYWDDKiYddgLhMStvO/aBol5
qGZ296qRxnByo5U6GkTFdXXCKVqcWPpvwn8tH+P7uCQ4UZIheKXlsJWsZDJnMnAN
den8JOoa
=rO6N
-----END PGP SIGNATURE-----

--=_MailMate_4E6142BD-3CD1-474B-93C8-703340E8202A_=--
