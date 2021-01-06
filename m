From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 06 Jan 2021 10:46:53 +0000
Subject: Re: [PATCH] ia64: fix xchg() warning
Message-Id: <c49a5ed2-c3d5-8cb4-7d28-7087eea2e707@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210104085806.4176886-1-arnd@kernel.org>
 <ad54481b-15da-e795-0c1a-bd54d3e8ab87@physik.fu-berlin.de>
 <CAK8P3a3zDB5wh-bdg+fq6nvg9gHrESFhhgss4f47VJ1JOvoE1Q@mail.gmail.com>
 <71274a7cdf7d48bf9c2fda873fa37727@intel.com>
 <CAK8P3a2KhaEZ-ErAXGi0wOr_z2YT-GUV7r5QMhUoV+e+tpc5zw@mail.gmail.com>
 <20210105153603.GA17644@agluck-desk2.amr.corp.intel.com>
In-Reply-To: <20210105153603.GA17644@agluck-desk2.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Arnd Bergmann <arnd@kernel.org>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi!

On 1/5/21 4:36 PM, Luck, Tony wrote:
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 0f2e55faaf7f..b74093803154 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -8432,11 +8432,8 @@ F: drivers/i3c/
>>  F: include/linux/i3c/
>>
>>  IA64 (Itanium) PLATFORM
>> -M: Tony Luck <tony.luck@intel.com>
>> -M: Fenghua Yu <fenghua.yu@intel.com>
>>  L: linux-ia64@vger.kernel.org
>> -S: Odd Fixes
>> -T: git git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git
>> +S: Orphan
>>  F: Documentation/ia64/
>>  F: arch/ia64/
>>
>> Is that what you had in mind? I see that Fenghua Yu has not been
>> actively involved for a long time. If you are both out, that would
>> make the port unmaintained, but that may actually help find someone
>> else to either volunteer as a maintainer or pay someone if they
>> have a commercial interest.
> 
> Yes. Fenghua has moved to working on other things, so that looks good.
> 
> Acked-by: Tony Luck <tony.luck@intel.com>

I wonder whether I can take over maintainership. I'm certainly not experienced as
Tony or Fenghua, but I guess one can grow with the task, can't one?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
