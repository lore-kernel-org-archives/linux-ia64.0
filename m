From: "Zi Yan" <ziy@nvidia.com>
Date: Thu, 06 May 2021 15:50:08 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <16962E62-7D1E-4E06-B832-EC91F54CC359@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_EF181C5B-F560-456C-BCA4-7AD984E499FD_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
 <9D7FD316-988E-4B11-AC1C-64FF790BA79E@nvidia.com>
 <3a51f564-f3d1-c21f-93b5-1b91639523ec@redhat.com>
In-Reply-To: <3a51f564-f3d1-c21f-93b5-1b91639523ec@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--=_MailMate_EF181C5B-F560-456C-BCA4-7AD984E499FD_=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On 6 May 2021, at 11:40, David Hildenbrand wrote:

>>>> The last patch increases SECTION_SIZE_BITS to demonstrate the use of=
 memory
>>>> hotplug/hotremove subsection, but is not intended to be merged as is=
=2E It is
>>>> there in case one wants to try this out and will be removed during t=
he final
>>>> submission.
>>>>
>>>> Feel free to give suggestions and comments. I am looking forward to =
your
>>>> feedback.
>>>
>>> Please not like this.
>>
>> Do you mind sharing more useful feedback instead of just saying a lot =
of No?
>
> I remember reasoning about this already in another thread, no? Either y=
ou're ignoring my previous feedback or my mind is messing with me.

I definitely remember all your suggestions:

1. do not use CMA allocation for 1GB THP.
2. section size defines the minimum size in which we can add_memory(), so=
 we cannot increase it.

I am trying an alternative here. I am not using CMA allocation and not in=
creasing the minimum size of add_memory() by decoupling the memory block =
size from section size, so that add_memory() can add a memory block small=
er (as small as 2MB, the subsection size) than section size. In this way,=
 section size can be increased freely. I do not see the strong tie betwee=
n add_memory() and section size, especially we have subsection bitmap sup=
port.


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_EF181C5B-F560-456C-BCA4-7AD984E499FD_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAmCUEDAPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKvJMP/0lV2lDuyjt8qAFqOIf+9/FwjaI5D/Zp45sh
yG07rIN2WsKGzAXTeXMOy2wOZeFkUaYcO7TYTWB2ITMt0AM6ZoBQkHfH93RX1DYx
SKQuvCEHcA8gIzNidDjoDQxZhIXVFcPWqoe1INChH5YlydqRbxrMaRUEbNXFUkh2
Uyoa3KmmghZL+hCfTukkMkD0vzFU4kC6C3J61RBk2JulO6QB8BnVS2FhwoHLqKJE
yfnjvEAxYCjCveV8+L9JS/A4sdWEW+jIeFc9a1Ak0lFBIablXox2vAyyhJHqq9PE
/zyW8EUl+VrbT6B/xDenQMT5WwY0ggxdsjHzvXe4BcsHWSTZq6jFlW5dhlaqn/Rf
WhpRQYni21wq/A4zdF0SVp400TYOvmoBsf9haLygjUXT3rVHkJnd6ItZ6wa+QbPJ
mb3x6lQmNnKRiU5VZt/G8octH7m3O8153e3sT/6ffdE33NhQUC2ncJBCQB+BSflW
JgsOSizD13RI5TmuliD/JFhi37kMrkj4dCuK7hBWBZyHL8DKzCf6y3Iw1VIgyku1
6b9jWQCl4OVxSTyh2rrI0ulvjHbJNSCB+P8w+kQ66qEuZVjlOkKmbCCoL/64diDH
8gR3c2uSEGevWqZzX5Mt0u7C/HYAWqKN0TYpjcuQ0hL9xiYVz8dqdNo/lsfgk4q+
dXFzUKjn
=8W9n
-----END PGP SIGNATURE-----

--=_MailMate_EF181C5B-F560-456C-BCA4-7AD984E499FD_=--
