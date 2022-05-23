From: mawupeng <mawupeng1@huawei.com>
Date: Mon, 23 May 2022 11:48:33 +0000
Subject: Re: [PATCH 0/2] Add support to relocate kernel image to mirrored region
Message-Id: <2a8cc751-dd72-6fe7-9a33-d6f24769f57d@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXGSStDgj9ABmUaTLnBmpQFksh3wx4tx=mJohum4GQe3Gg@mail.gmail.com>
 <20220419070150.254377-1-mawupeng1@huawei.com>
 <CAMj1kXHr2RdYSPor1st1ZnL=O42c8N6e=bNG+eFhatfefWLUrw@mail.gmail.com>
 <c65d22b4-f654-21aa-bd5f-d4f8b0939a25@huawei.com>
 <7058b8d8-c0cb-108e-0db9-2fdf5fb154cf@huawei.com>
 <CAMj1kXHnL12j6FPGtEeSQB2-kHzoVF+LJMUF9YBq43Yi1UntDg@mail.gmail.com>
 <CAMj1kXFP9kA_rJ8DfP1Ln=W++xL1Rvdojb8ZuNLoOJx2mLkysA@mail.gmail.com>
In-Reply-To: <CAMj1kXFP9kA_rJ8DfP1Ln=W++xL1Rvdojb8ZuNLoOJx2mLkysA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: ardb@kernel.org
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, mawupeng1@huawei.com



=E5=9C=A8 2022/5/20 14:52, Ard Biesheuvel =E5=86=99=E9=81=93:
> On Fri, 20 May 2022 at 08:52, Ard Biesheuvel <ardb@kernel.org> wrote:
>>
>> On Thu, 19 May 2022 at 13:09, mawupeng <mawupeng1@huawei.com> wrote:
>>>
>>>
>>>
>>> =E5=9C=A8 2022/5/7 17:28, mawupeng =E5=86=99=E9=81=93:
>>>>
>>>>
>>>> =E5=9C=A8 2022/5/3 17:58, Ard Biesheuvel =E5=86=99=E9=81=93:
>>>>> On Tue, 19 Apr 2022 at 08:43, Wupeng Ma <mawupeng1@huawei.com> wrote:
>>>>>>
>>>>>> From: Ma Wupeng <mawupeng1@huawei.com>
>>>>>>
>>>>>> Now system image will perfer to be located to mirrored regions both =
KASLR
>>>>>> on and off.
>>>>>>
>>>>>
>>>>> Hello Ma Wupeng,
>>>>>
>>>>> I wonder if we could simplify this as follows:
>>>>> - ignore the non-KASLR case for now, and rely on the bootloader  > lo=
ad the image into mirrored memory if it exists;
>>>>
>>>> In grub, memory for static image is allocated via the following path:
>>>>
>>>> grub_cmd_linux
>>>>     kernel =3D grub_malloc(filelen)
>>>>     kernel_alloc_addr =3D grub_efi_allocate_any_pages (kernel_alloc_pa=
ges)
>>>>     grub_memcpy (kernel_addr, kernel, grub_min(filelen, kernel_size))
>>>>      grub_loader_set (grub_linux_boot, grub_linux_unload, 0)
>>>>
>>>> Can we get memory from mirrored region by the following steps:
>>>> 1. get memory map by calling grub_efi_get_memory_map()
>>>> 2. iter all memory map to find a suitable mirrored memory area
>>>> 3. locate kernel image to this area
>>>>
>>>> So, if kaslr is not enabled
>>>>    - grub will load kernel into mirrored region
>>>> else
>>>>    - arm64-stub.c will relocate kernel image to mirrored region
>>>>
>>>> Is this feasible?
>>>
>>> Is this a feasible proposal to relocate the static kernel image itself
>>> into more reliable memory?
>>>
>>
>> I'm not sure, it all depends on the firmware.
>>
>> When GRUB calls LoadImage(), the firmware will reallocate the image
>> and unpack it there. So it is really the firmware's job to ensure that
>> the image is loaded into a suitable location.
>>
>> I have some code here that implements a EFI based decompressor, and
>> which loads the kernel image into mirrored memory if it exists,
>> without the need to move it again. It could trivially be modified to
>> deal with non-randomized loads as well.
>>
>=20
> Code is here
> https://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git/log/?h=EFi=
-decompressor-v2

I will test this later.

Thanks.

> .
