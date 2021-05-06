From: "Zi Yan" <ziy@nvidia.com>
Date: Thu, 06 May 2021 15:37:15 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <9D7FD316-988E-4B11-AC1C-64FF790BA79E@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_20560B3D-9CB2-4483-BBC2-6D4DFD4AF167_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
In-Reply-To: <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--=_MailMate_20560B3D-9CB2-4483-BBC2-6D4DFD4AF167_=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On 6 May 2021, at 11:31, David Hildenbrand wrote:

> On 06.05.21 17:26, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> Hi all,
>>
>> This patchset tries to remove the restriction on memory hotplug/hotrem=
ove
>> granularity, which is always greater or equal to memory section size[1=
].
>> With the patchset, kernel is able to online/offline memory at a size i=
ndependent
>> of memory section size, as small as 2MB (the subsection size).
>
> ... which doesn't make any sense as we can only online/offline whole me=
mory block devices.

Why limit the memory block size to section size? Patch 3 removes the rest=
riction
by using (start_pfn, nr_pages) to allow memory block size goes below sect=
ion size.
Also we have subsection bitmap available to tell us which subsection is o=
nline,
there is no reason to force memory block size to match section size.

>
>>
>> The motivation is to increase MAX_ORDER of the buddy allocator and pag=
eblock
>> size without increasing memory hotplug/hotremove granularity at the sa=
me time,
>
> Gah, no. Please no. No.
>
>> so that the kernel can allocator 1GB pages using buddy allocator and u=
tilizes
>> existing pageblock based anti-fragmentation, paving the road for 1GB T=
HP
>> support[2].
>
> Not like this, please no.
>
>>
>> The patchset utilizes the existing subsection support[3] and changes t=
he
>> section size alignment checks to subsection size alignment checks. The=
re are
>> also changes to pageblock code to support partial pageblocks, when pag=
eblock
>> size is increased along with MAX_ORDER. Increasing pageblock size can =
enable
>> kernel to utilize existing anti-fragmentation mechanism for gigantic p=
age
>> allocations.
>
> Please not like this.
>
>>
>> The last patch increases SECTION_SIZE_BITS to demonstrate the use of m=
emory
>> hotplug/hotremove subsection, but is not intended to be merged as is. =
It is
>> there in case one wants to try this out and will be removed during the=
 final
>> submission.
>>
>> Feel free to give suggestions and comments. I am looking forward to yo=
ur
>> feedback.
>
> Please not like this.

Do you mind sharing more useful feedback instead of just saying a lot of =
No?

Thanks.


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_20560B3D-9CB2-4483-BBC2-6D4DFD4AF167_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAmCUDSsPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKuzEP/jmIOHHfzAPAXeBAyTyp5XWNQJbjDR7uTubU
wbuJC5jOofGdiSKypbdGSB5ta/srQPxD8wEeXFfBDKgTeL438WTPlchWYTQE0rst
hzSVWGQYddrh5V3BGXqRTRoUIIJicIVo053gqojjoDhxNWnCA+xThcoIpFoIADe3
PlG5o4CQjzfE+vjawuuiCRhSW8vlFg0Sxyg2TV1T47IMdvogvazYSJVuhuUp/5l2
iOfaartwDXifmb+88qMGXuulvThLlD5I7eXCqrs/Y1AtkW3O++cwmCOSwKrT/9r9
6vs3fRel0PSM66B2lLpWynmv0EjtQbSW2yq7RMBswI62WhjwSNaieTtLX+1VG+tT
19MlmlrAdg97LIkWRh97si6z1xTsh7C712gPLXfijBPebruYtVts3XDSDwTS982+
1HIEYnnM7BUDxvoZ8F1zRTHIauSioFyV1IhJnYxhfamYBtZzAfbbT/hOsi28nVZ7
6PXf4oyJeLLcjlbQ+9MROFbbwZNhDoABW3iIfwalNL0IdErLP8Uh34AF2YOLdKOy
Xv2hWs+1SNnhqZH1XfHRvFFxdte2P/rpXVh7qR48MfPw/58bWGgnLJvwNecighkm
vLE6VBMxUjtTI9N5gu+KqCJwNIvhGGfUCffA+e9UQ5xPrB7NgkH4W2kDMpocCiUE
hODKA/KB
=h9b6
-----END PGP SIGNATURE-----

--=_MailMate_20560B3D-9CB2-4483-BBC2-6D4DFD4AF167_=--
