From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Sat, 23 Aug 2014 02:31:15 +0000
Subject: Re: [PATCH v2] arch: Kconfig: Let all little endian architectures define CPU_LITTLE_ENDIAN explicitl
Message-Id: <53F7FCF3.4000800@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <53EA99C3.90203@gmail.com> <CAMuHMdV_2b-A+eE--cXEFA68=72HK6mqx8+TCXRMVkyhESLYxQ@mail.gmail.com> <53F724DD.1080605@suse.cz>
In-Reply-To: <53F724DD.1080605@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Marek <mmarek@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Jean Delvare <jdelvare@suse.de>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Salter <msalter@redhat.com>, "a-jacquiot@ti.com" <a-jacquiot@ti.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kbuild <linux-kbuild@vger.kernel.org>

On 8/22/14 19:09, Michal Marek wrote:
> Dne 13.8.2014 10:03, Geert Uytterhoeven napsal(a):
>> CC kbuild
>>
>> On Wed, Aug 13, 2014 at 12:48 AM, Chen Gang <gang.chen.5i5j@gmail.com> wrote:
>>> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
>>> index c49a775..0510a5d 100644
>>> --- a/arch/arm/Kconfig
>>> +++ b/arch/arm/Kconfig
>>> @@ -199,6 +199,11 @@ config NEED_DMA_MAP_STATE
>>>  config ARCH_SUPPORTS_UPROBES
>>>         def_bool y
>>>
>>> +config CPU_LITTLE_ENDIAN
>>> +       depends on !CPU_BIG_ENDIAN
>>> +       def_bool y
>>> +
>>> +
>>>  config ARCH_HAS_DMA_SET_COHERENT_MASK
>>>         bool
>>
>> As this is a common symbol, and replicated for all affected architectures,
>> I'm wondering if we should have the "config CPU_LITTLE_ENDIAN" in
>> common Kconfig code instead, and make the individual architectures do a
>> "select CPU_LITTLE_ENDIAN"?
> 
> Yes!
> 
> 
>> Also we could have "config CPU_BIG_ENDIAN", too, and error out
>> if none or both are selected (can Kconfig error out?).
> 
> We can error out in the Makefile, if there is consensus that we should
> be doing so.
> 

OK, thanks. I have sent patch v3 for it, and did not check related error
in Kconfig files.

Please check the related patches (excuse me, I send the patch v3 only
according to "scripts/maintainers.pl", maybe not cc to you explicitly).


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
