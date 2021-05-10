From: "Zi Yan" <ziy@nvidia.com>
Date: Mon, 10 May 2021 14:36:04 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <746780E5-0288-494D-8B19-538049F1B891@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_E335F9A6-81B9-4542-8F00-632486119085_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
 <YJUqrOacyqI+kiKW@dhcp22.suse.cz>
 <792d73e2-5d63-74a5-5554-20351d5532ff@redhat.com>
In-Reply-To: <792d73e2-5d63-74a5-5554-20351d5532ff@redhat.com>
To: David Hildenbrand <david@redhat.com>, Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--=_MailMate_E335F9A6-81B9-4542-8F00-632486119085_=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On 7 May 2021, at 10:00, David Hildenbrand wrote:

> On 07.05.21 13:55, Michal Hocko wrote:
>> [I haven't read through respective patches due to lack of time but let=

>>   me comment on the general idea and the underlying justification]
>>
>> On Thu 06-05-21 17:31:09, David Hildenbrand wrote:
>>> On 06.05.21 17:26, Zi Yan wrote:
>>>> From: Zi Yan <ziy@nvidia.com>
>>>>
>>>> Hi all,
>>>>
>>>> This patchset tries to remove the restriction on memory hotplug/hotr=
emove
>>>> granularity, which is always greater or equal to memory section size=
[1].
>>>> With the patchset, kernel is able to online/offline memory at a size=
 independent
>>>> of memory section size, as small as 2MB (the subsection size).
>>>
>>> ... which doesn't make any sense as we can only online/offline whole =
memory
>>> block devices.
>>
>> Agreed. The subsection thingy is just a hack to workaround pmem
>> alignement problems. For the real memory hotplug it is quite hard to
>> argue for reasonable hotplug scenarios for very small physical memory
>> ranges wrt. to the existing sparsemem memory model.
>>
>>>> The motivation is to increase MAX_ORDER of the buddy allocator and p=
ageblock
>>>> size without increasing memory hotplug/hotremove granularity at the =
same time,
>>>
>>> Gah, no. Please no. No.
>>
>> Agreed. Those are completely independent concepts. MAX_ORDER is can be=

>> really arbitrary irrespective of the section size with vmemmap sparse
>> model. The existing restriction is due to old sparse model not being
>> able to do page pointer arithmetic across memory sections. Is there an=
y
>> reason to stick with that memory model for an advance feature you are
>> working on?

No. I just want to increase MAX_ORDER. If the existing restriction can
be removed, that will be great.

>
> I gave it some more thought yesterday. I guess the first thing we shoul=
d look into is increasing MAX_ORDER and leaving pageblock_order and secti=
on size as is -- finding out what we have to tweak to get that up and run=
ning. Once we have that in place, we can actually look into better fragme=
ntation avoidance etc. One step at a time.

It makes sense to me.

>
> Because that change itself might require some thought. Requiring that b=
igger MAX_ORDER depends on SPARSE_VMEMMAP is something reasonable to do.

OK, if with SPARSE_VMEMMAP MAX_ORDER can be set to be bigger than
SECTION_SIZE, it is perfectly OK to me. Since 1GB THP support, which I
want to add ultimately, will require SPARSE_VMEMMAP too (otherwise,
all page++ will need to be changed to nth_page(page,1)).

>
> As stated somewhere here already, we'll have to look into making alloc_=
contig_range() (and main users CMA and virtio-mem) independent of MAX_ORD=
ER and mainly rely on pageblock_order. The current handling in alloc_cont=
ig_range() is far from optimal as we have to isolate a whole MAX_ORDER - =
1 page -- and on ZONE_NORMAL we'll fail easily if any part contains somet=
hing unmovable although we don't even want to allocate that part. I actua=
lly have that on my list (to be able to fully support pageblock_order ins=
tead of MAX_ORDER -1 chunks in virtio-mem), however didn't have time to l=
ook into it.

So in your mind, for gigantic page allocation (> MAX_ORDER), alloc_contig=
_range()
should be used instead of buddy allocator while pageblock_order is kept a=
t a small
granularity like 2MB. Is that the case? Isn=E2=80=99t it going to have hi=
gh fail rate
when any of the pageblocks within a gigantic page range (like 1GB) become=
s unmovable?
Are you thinking additional mechanism/policy to prevent such thing happen=
ing as
an additional step for gigantic page allocation? Like your ZONE_PREFER_MO=
VABLE idea?

>
> Further, page onlining / offlining code and early init code most probab=
ly also needs care if MAX_ORDER - 1 crosses sections. Memory holes we mig=
ht suddenly have in MAX_ORDER - 1 pages might become a problem and will h=
ave to be handled. Not sure which other code has to be tweaked (compactio=
n? page isolation?).

Can you elaborate it a little more? From what I understand, memory holes =
mean valid
PFNs are not contiguous before and after a hole, so pfn++ will not work, =
but
struct pages are still virtually contiguous assuming SPARSE_VMEMMAP, mean=
ing page++
would still work. So when MAX_ORDER - 1 crosses sections, additional code=
 would be
needed instead of simple pfn++. Is there anything I am missing?

BTW, to test a system with memory holes, do you know is there an easy of =
adding
random memory holes to an x86_64 VM, which can help reveal potential miss=
ing pieces
in the code? Changing BIOS-e820 table might be one way, but I have no ide=
a on
how to do it on QEMU.

>
> Figuring out what needs care itself might take quite some effort.
>
> One thing I was thinking about as well: The bigger our MAX_ORDER, the s=
lower it could be to allocate smaller pages. If we have 1G pages, splitti=
ng them down to 4k then takes 8 additional steps if I'm, not wrong. Of co=
urse, that's the worst case. Would be interesting to evaluate.

Sure. I am planning to check it too. As a simple start, I am going to run=
 will it scale
benchmarks to see if there is any performance difference between differen=
t MAX_ORDERs.

Thank you for all these valuable inputs. They are very helpful. I appreci=
ate them.


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_E335F9A6-81B9-4542-8F00-632486119085_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAmCZRNQPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKVCoP/0NXDCk4NDzURRYmnwbWMoc/8v67Y4ZQ2U47
rHYejHxvW9f/cg0lhZy205pPnYZKo3N82+yAPYpeEiV+YXmygOE+LDebvcv3I2oJ
n5/hWIix4sO7mTiJW1ZPhXFJkrGvWC/pF94YuVwl1NVwAmRgqSbYONuRrQ4slE/e
8WgDuprcQDqPGlBtGZWw2+zPyy0q8v/MRdY0lii6EU7/36vce1L6yuqHLOPmOqpw
U1xzmiUE02AA6+XwzMVPZJdABJhTQMjVjOyNx2CeJYGvidf6NFIWtH5gSOIgit8R
Kkfq8hsDScvJL2cBz5RX/QTvhRpWaaf6dAm3ERO+0E1n8/Azpjai6cNo2wh03Ly0
vszQuHyJGpIoZOwv+mX0+OZ7IKfk6VhCLo9dMJRMzTdwE87zg2q1hHDfRfEhvNAD
tbfIz0ySnfGxX+oEeaPKu+8oa2OfQ08noGGU0mnJRNXY8xGX2I6CmWV9YI5xyAf+
DOAsQnC7Qy/IjfYPnRzu4zB9r19HvjSpTSAx+yGnPNvhPNMNiSE06jFdkEms5tlx
RRDklENKX30+Tsqz1FuTyGDI3FYmpdBPD4lZGGcBIAn6EI5xj7uHO+LTd4wtaWNn
y3mM6MyTM89uae/wauqCYE50Ua9inabY8W6DQ9sncd2RXecvCMh0ivcCebMepQPG
v2QZ0RvL
=96Ul
-----END PGP SIGNATURE-----

--=_MailMate_E335F9A6-81B9-4542-8F00-632486119085_=--
