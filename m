From: David Hildenbrand <david@redhat.com>
Date: Tue, 04 Dec 2018 09:47:33 +0000
Subject: Re: [PATCH RFCv2 3/4] mm/memory_hotplug: Introduce and use more memory types
Message-Id: <b8e03810-41d6-55cb-9546-62c73c7f4d7f@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130175922.10425-1-david@redhat.com>
 <20181130175922.10425-4-david@redhat.com>
 <20181204104454.522a3ba2@naga.suse.cz>
In-Reply-To: <20181204104454.522a3ba2@naga.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: =?UTF-8?Q?Michal_Such=c3=a1nek?= <msuchanek@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.co>

On 04.12.18 10:44, Michal Such=C3=A1nek wrote:
> On Fri, 30 Nov 2018 18:59:21 +0100
> David Hildenbrand <david@redhat.com> wrote:
>=20
>> Let's introduce new types for different kinds of memory blocks and use
>> them in existing code. As I don't see an easy way to split this up,
>> do it in one hunk for now.
>>
>> acpi:
>>  Use DIMM or DIMM_UNREMOVABLE depending on hotremove support in the kern=
el.
>>  Properly change the type when trying to add memory that was already
>>  detected and used during boot (so this memory will correctly end up as
>>  "acpi" in user space).
>>
>> pseries:
>>  Use DIMM or DIMM_UNREMOVABLE depending on hotremove support in the kern=
el.
>>  As far as I see, handling like in the acpi case for existing blocks is
>>  not required.
>>
>> probed memory from user space:
>>  Use DIMM_UNREMOVABLE as there is no interface to get rid of this code
>>  again.
>>
>> hv_balloon,xen/balloon:
>>  Use BALLOON. As simple as that :)
>>
>> s390x/sclp:
>>  Use a dedicated type S390X_STANDBY as this type of memory and it's
>>  semantics are very s390x specific.
>>
>> powernv/memtrace:
>>  Only allow to use BOOT memory for memtrace. I consider this code in
>>  general dangerous, but we have to keep it working ... most probably just
>>  a debug feature.
>=20
> I don't think it should be arbitrarily restricted like that.
>=20

Well code that "randomly" offlines/onlines/removes/adds memory blocks
that it does not own (hint: nobody else in the kernel does that), should
be restricted to types we can guarantee to work.

> Thanks
>=20
> Michal
>=20


--=20

Thanks,

David / dhildenb
