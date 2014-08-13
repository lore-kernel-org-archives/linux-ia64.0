From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Wed, 13 Aug 2014 07:44:18 +0000
Subject: Re: [PATCH v2] arch: Kconfig: Let all little endian architectures define CPU_LITTLE_ENDIAN explicitl
Message-Id: <53EB1752.9010601@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <53EA99C3.90203@gmail.com> <20140813050809.GB30459@ravnborg.org> <53EAF85E.3000208@gmail.com> <53EB0AF6.6060208@zytor.com>
In-Reply-To: <53EB0AF6.6060208@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>, Sam Ravnborg <sam@ravnborg.org>
Cc: Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org, Geert Uytterhoeven <geert@linux-m68k.org>, Jean Delvare <jdelvare@suse.de>, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, msalter@redhat.com, a-jacquiot@ti.com, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org



On 8/13/14 14:51, H. Peter Anvin wrote:
> On 08/12/2014 10:32 PM, Chen Gang wrote:
>>
>> Yeah, we need.
>>
>>> The solution you suggest assumes that an arch is either little or big endian.
>>> But we cannot ignore the hybriads that can do both.
>>>
>>
>> For the architectures which can do both, for me, they are: sh, powerpc,
>> m32r, and mips (may mark CPU_LITTLE_ENDIAN), also are: arm/arm64, and
>> c6x (may mark !CPU_BIG_ENDIAN).
>>
>> For the architectures which only support little endian: x86, and ia64.
>>
>> The left, I assumes they are big endian (no any 'ENDIAN' can be found
>> in their Kconfig files). In my memory, except related with Intel, all
>> are (or support) big endian.
>>
> 
> I'm quite certain that is wrong.  From memory, for example, I believe
> CRIS is littleendian, and sure enough:
> 
> : tazenda 103 ; less arch/cris/include/uapi/asm/byteorder.h
> #ifndef _CRIS_BYTEORDER_H
> #define _CRIS_BYTEORDER_H
> 
> #include <linux/byteorder/little_endian.h>
> 
> #endif
> 

OK, what you said sounds reasonable to me. After search "endian" in
"./arch", xtensa also can be support both big endian or little endian.

> As far as I know, endianism is always a compile-time option on Linux, so
> we should be able to relatively easily define the architecture so that
> we either have hardwired littleendian, bigendian, or prompt.
> 

Yeah, but that may break building and re-config manually. So it is still
necessary to check little endian or big endian during configuration time
("make *config").


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
