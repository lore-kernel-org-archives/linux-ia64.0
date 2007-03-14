From: Jay Lan <jlan@sgi.com>
Date: Wed, 14 Mar 2007 18:48:15 +0000
Subject: Re: [Patch] min_low_pfn and max_low_pfn calcultion fix
Message-Id: <45F8436F.7060303@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1172619535.20006.334.camel@linux-znh>
In-Reply-To: <1172619535.20006.334.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jay Lan wrote:
> Jay Lan wrote:
>> Magnus Damm wrote:
>> [snip]
>>>> I tested on 2.6.21-rc3 with DEBUG_VM turned on. The vanilla 2.6.21-rc3
>>>> without Nan-hai's patch, panicked on bugcheck on free_initmem->free_pa=
ge
>>>> as predicted. We still need this patch.
>>> Ok, thanks for testing. =3D)
>>>
>>>> However, the zero-size vmcore problem is back on SN. But that is a
>>>> dfiffernet problem.
>>> Argh, more problems...
>> I found the problem. It was the "elfcorehdr" introduced in 2.6.21-rc1.
>> Without specifying it, the elfcorehdr_addr is initialized to
>> ELFCORE_ADDR_MAX. Later, a check in reserve_elfcorehdr will fail:
>>         if (elfcorehdr_addr >=3D ELFCORE_ADDR_MAX)
>>                 return -EINVAL;
>>
>> Is it supposed to be a physical address to store elf core header?
>> If so, it is not possible for SN to provide a physical address at
>> boot time, just like in the case of crashkernel=3DX@Y where Y is not use=
d.
>=20
> Sorry, the elfcorehdr parameter is provided to the kdump kernel by
> kexec. The problem is in the reserve_elfcorehdr logic introduced in
> 2.6.21-rc1.
>=20
> When booting up the kdump kernel, i observed a failure in
> reserve_elfcorehdr. The below are my debugging messages:
>=20
> elfcorehdr_addr027fe4000, ELFCORE_ADDR_MAX=FFffffffffffffff
> Cannot locate EFI vmcore descriptor
> reserve_elfcorehdr: vmcore descriptor size =3D 0
> reserve_memory: FAIL to reserve reserve_elfcorehdr

Hi Tony,

The kernel code 2.6.21-rc3+ is fine wrt zero-size-vmcore issue.

I have been testing on a rhel5 environment. The /sbin/kexec worked
for me up to 2.6.20.

I then built a new kexec from tot kexec-tools-testing git tree and
i no longer see the zero-size-vmcore problem.

Regards,
 - jay
