From: "Zi Yan" <ziy@nvidia.com>
Date: Thu, 06 May 2021 15:42:21 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <25C004DA-44C1-4331-B290-F4473A3AF05D@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_09B22BBF-03CA-4BD7-90B5-4F00D05F266E_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
In-Reply-To: <20210506152623.178731-1-zi.yan@sent.com>
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

--=_MailMate_09B22BBF-03CA-4BD7-90B5-4F00D05F266E_=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On 6 May 2021, at 11:26, Zi Yan wrote:

> From: Zi Yan <ziy@nvidia.com>
>
> Hi all,
>
> This patchset tries to remove the restriction on memory hotplug/hotremo=
ve
> granularity, which is always greater or equal to memory section size[1]=
=2E
> With the patchset, kernel is able to online/offline memory at a size in=
dependent
> of memory section size, as small as 2MB (the subsection size).
>
> The motivation is to increase MAX_ORDER of the buddy allocator and page=
block
> size without increasing memory hotplug/hotremove granularity at the sam=
e time,
> so that the kernel can allocator 1GB pages using buddy allocator and ut=
ilizes
> existing pageblock based anti-fragmentation, paving the road for 1GB TH=
P
> support[2].
>
> The patchset utilizes the existing subsection support[3] and changes th=
e
> section size alignment checks to subsection size alignment checks. Ther=
e are
> also changes to pageblock code to support partial pageblocks, when page=
block
> size is increased along with MAX_ORDER. Increasing pageblock size can e=
nable
> kernel to utilize existing anti-fragmentation mechanism for gigantic pa=
ge
> allocations.
>
> The last patch increases SECTION_SIZE_BITS to demonstrate the use of me=
mory
> hotplug/hotremove subsection, but is not intended to be merged as is. I=
t is
> there in case one wants to try this out and will be removed during the =
final
> submission.
>
> Feel free to give suggestions and comments. I am looking forward to you=
r
> feedback.
>
> Thanks.

Added the missing references.

[1] https://lore.kernel.org/linux-mm/4b3006cf-3391-6839-904e-b415613198cb=
@redhat.com/
[2] https://lore.kernel.org/linux-mm/20200928175428.4110504-1-zi.yan@sent=
=2Ecom/
[3] https://patchwork.kernel.org/project/linux-nvdimm/cover/156092349300.=
979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com/

>
> Zi Yan (7):
>   mm: sparse: set/clear subsection bitmap when pages are
>     onlined/offlined.
>   mm: set pageblock_order to the max of HUGETLB_PAGE_ORDER and
>     MAX_ORDER-1
>   mm: memory_hotplug: decouple memory_block size with section size.
>   mm: pageblock: allow set/unset migratetype for partial pageblock
>   mm: memory_hotplug, sparse: enable memory hotplug/hotremove
>     subsections
>   arch: x86: no MAX_ORDER exceeds SECTION_SIZE check for 32bit vdso.
>   [not for merge] mm: increase SECTION_SIZE_BITS to 31
>
>  arch/ia64/Kconfig                |   1 -
>  arch/powerpc/Kconfig             |   1 -
>  arch/x86/Kconfig                 |  15 +++
>  arch/x86/entry/vdso/Makefile     |   1 +
>  arch/x86/include/asm/sparsemem.h |   2 +-
>  drivers/base/memory.c            | 176 +++++++++++++++----------------=

>  drivers/base/node.c              |   2 +-
>  include/linux/memory.h           |   8 +-
>  include/linux/mmzone.h           |   2 +
>  include/linux/page-isolation.h   |   8 +-
>  include/linux/pageblock-flags.h  |   9 --
>  mm/Kconfig                       |   7 --
>  mm/memory_hotplug.c              |  22 ++--
>  mm/page_alloc.c                  |  40 ++++---
>  mm/page_isolation.c              |  30 +++---
>  mm/sparse.c                      |  55 ++++++++--
>  16 files changed, 219 insertions(+), 160 deletions(-)
>
> -- =

> 2.30.2


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_09B22BBF-03CA-4BD7-90B5-4F00D05F266E_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAmCUDl0PHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKwfIP/j4mtx3y0ccLIUsgx7lvwtos8eCqs2V7JGeD
jAcbXTqiE2jHoRA2+tIXQ/181PPSnYoWtMHIX8heOBzdIANslGpI96cgMfKFuDpZ
r0+c7/0LfndyxXEi/avRGsGvdmKwa3gG/cxq69dOxUuG23z4NIYwaSjKMYBS55GV
ML98nqEGwnQQC0mDc3pcic6LMCHQjeQcff3r/wNMUZL4Mm8MEAbxnHdcPJIdQtLU
eSNXQCJg0QCrQd0LEokCieDPvmsa9WxPjPjAu5TB85mr0reT9MHb1uac2TLpQTRo
F36hRpneJnu+4WACSUHPhw2l4rFiwHi00Y83lc8TIOCqK3qAt5h04mNdkTczeMBg
F9oGPrBLQA6GFtaQoWQ12t79gwTloJEJyVhtsYbrYix9XdQy9SltbrpDHaU5TvYz
mg4jPZe9CZwYngFHd61GS7chKrK7hVrIevPNTS+khgnCiDDdxs5WJl2pILfbXNDI
CZHoX6Vvsr6aZeqFYNTv004Q20D+4yH51hEOVZ3Z5KjLY3iHnghk0GvrZkb2wiAr
mqd1tkWYW3ZVxz8jfF9fpHWDvl8WgPLdXKl2wJtiStfp5qCUr724oQyrsMHx3BiP
2bPdalSxc+cd+fS4zj0gAWbH+l1M5NhPYM2OphiJcjAmX2Y4v81n59jf6ksvsFf+
23wXbePJ
=JdYV
-----END PGP SIGNATURE-----

--=_MailMate_09B22BBF-03CA-4BD7-90B5-4F00D05F266E_=--
