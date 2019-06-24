From: Jessica Yu <jeyu@kernel.org>
Date: Mon, 24 Jun 2019 12:32:00 +0000
Subject: Re: [PATCH modules v2 0/2] Fix handling of exit unwinding sections (on ARM)
Message-Id: <20190624123200.GB22519@linux-8ccs>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190607104912.6252-1-matthias.schiffer@ew.tq-group.com>
 <c52edcd84b01970113fc046d11c38276d51886e0.camel@ew.tq-group.com>
In-Reply-To: <c52edcd84b01970113fc046d11c38276d51886e0.camel@ew.tq-group.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
Cc: Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

+++ Matthias Schiffer [21/06/19 14:35 +0200]:
>On Fri, 2019-06-07 at 12:49 +0200, Matthias Schiffer wrote:
>> For some time (050d18d1c651 "ARM: 8650/1: module: handle negative
>> R_ARM_PREL31 addends correctly", v4.11+), building a kernel without
>> CONFIG_MODULE_UNLOAD would lead to module loads failing on ARM
>> systems with
>> certain memory layouts, with messages like:
>>
>>   imx_sdma: section 16 reloc 0 sym '': relocation 42 out of range
>>   (0x7f015260 -> 0xc0f5a5e8)
>>
>> (0x7f015260 is in the module load area, 0xc0f5a5e8 a regular vmalloc
>> address; relocation 42 is R_ARM_PREL31)
>>
>> This is caused by relocatiosn in the .ARM.extab.exit.text and
>> .ARM.exidx.exit.text sections referencing the .exit.text section. As
>> the
>> module loader will omit loading .exit.text without
>> CONFIG_MODULE_UNLOAD,
>> there will be relocations from loaded to unloaded sections; the
>> resulting
>> huge offsets trigger the sanity checks added in 050d18d1c651.
>>
>> IA64 might be affected by a similar issue - sections with names like
>> .IA_64.unwind.exit.text and .IA_64.unwind_info.exit.text appear in
>> the ld
>> script - but I don't know much about that arch.
>>
>> Also, I'm not sure if this is stable-worthy - just enabling
>> CONFIG_MODULE_UNLOAD should be a viable workaround on affected
>> kernels.
>>
>> v2: Use __weak function as suggested by Jessica
>
>Hi Russell,
>
>this patch series is still waiting for your thoughts - in reponse to
>v1, Jessica already offered to take it through her tree if you give
>your Acked-by.
>
>Thanks,
>
>Matthias

Hi Matthias,

There doesn't seem to be any complaints and I think the patchset looks
good, so I've taken it up the modules-next tree. Thanks!

Jessica
