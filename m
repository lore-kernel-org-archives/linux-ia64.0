From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 26 Oct 2018 19:05:25 +0000
Subject: Re: [PATCH v2 0/2] arm64: Cut rebuild time when changing CONFIG_BLK_DEV_INITRD
Message-Id: <53ec9df5-ef2a-edc5-be1c-bca32959c0bc@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181024193256.23734-1-f.fainelli@gmail.com>
 <CAL_Jsq+KCOv6pXXHhHDZ+7-QUrmtMDvSjEVhK15yZ3qbnn61Ag@mail.gmail.com>
 <20181025093833.GA23607@rapoport-lnx>
 <CAL_JsqL62ttsGSbE1BS5v-mX3pKE-p_HyvuZD6nB+GUbQyetzg@mail.gmail.com>
 <20181025172935.GA27364@rapoport-lnx>
 <CAL_JsqJrMq+QHvuOsqEdCFchmXsd4s2XKUD_TboKzeEQprJvjg@mail.gmail.com>
 <1bb3bd63-a88e-b668-ea36-f0f985c0e2b1@gmail.com>
 <20181026110708.GA3814@rapoport-lnx>
In-Reply-To: <20181026110708.GA3814@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Rob Herring <robh@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Marc Zyngier <marc.zyngier@arm.com>, Olof Johansson <olof@lixom.net>, linux-alpha@vger.kernel.org, arcml <linux-snps-arc@lists.infradead.org>, "moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Linux-MIPS <linux-mips>

On 10/26/18 4:07 AM, Mike Rapoport wrote:
> On Thu, Oct 25, 2018 at 04:07:13PM -0700, Florian Fainelli wrote:
>> On 10/25/18 2:13 PM, Rob Herring wrote:
>>> On Thu, Oct 25, 2018 at 12:30 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>>>>
>>>> On Thu, Oct 25, 2018 at 08:15:15AM -0500, Rob Herring wrote:
>>>>> +Ard
>>>>>
>>>>> On Thu, Oct 25, 2018 at 4:38 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>>>>>>
>>>>>> On Wed, Oct 24, 2018 at 02:55:17PM -0500, Rob Herring wrote:
>>>>>>> On Wed, Oct 24, 2018 at 2:33 PM Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>>>>>>
>>>>>>>> Hi all,
>>>>>>>>
>>>>>>>> While investigating why ARM64 required a ton of objects to be rebuilt
>>>>>>>> when toggling CONFIG_DEV_BLK_INITRD, it became clear that this was
>>>>>>>> because we define __early_init_dt_declare_initrd() differently and we do
>>>>>>>> that in arch/arm64/include/asm/memory.h which gets included by a fair
>>>>>>>> amount of other header files, and translation units as well.
>>>>>>>
>>>>>> I think arm64 does not have to redefine __early_init_dt_declare_initrd().
>>>>>> Something like this might be just all we need (completely untested,
>>>>>> probably it won't even compile):
> 
> [ ... ]
>  
>> FWIW, I am extracting the ARM implementation that parses the initrd
>> early command line parameter and the "setup" code doing the page
>> boundary alignment and memblock checking into a helper into lib/ that
>> other architectures can re-use. So far, this removes the need for
>> unicore32, arc and arm to duplicate essentially the same logic.
> 
> Presuming you are going to need asm-generic/initrd.h for that as well,
> using override for __early_init_dt_declare_initrd in arm64 version of
> initrd.h might be the simplest option.

What I am contemplating doing is promote
phys_initrd_start/phys_initrd_size to be global variables (similar to
initrd_start, initrd_end) and have a generic helper function for parsing
the initrd= command line parameter and finally removing
__early_init_dt_declare_initrd() because we could have
early_init_dt_check_for_initrd() just populate
phys_initrd_start/phys_initrd_size directly as well as
initrd_start/initrd_end using __va() to preserve compatibility with
architectures that rely on this. Then I would convert ARM64 to check for
phys_initrd_start which is really what it is is trying to do in
arch/arm64/mm/init.c::arm64_memblock_init().

Does that sound like a reasonable approach?
-- 
Florian
