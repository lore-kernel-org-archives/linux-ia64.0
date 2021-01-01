From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Fri, 01 Jan 2021 14:06:20 +0000
Subject: Re: [PATCH] sh: add support for TIF_NOTIFY_SIGNAL
Message-Id: <31b34cfc-8d6e-d3b4-e29f-1ec485f5b368@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <5fcc82b4-89ae-3bca-10ab-6ad933565cee@kernel.dk>
 <ae29ab73-ee7a-2bb7-3fd8-3037f40c1cbd@kernel.dk>
 <5611bde9-67e7-6ff6-defc-9b02ea830fac@physik.fu-berlin.de>
 <9ea14eb3-d698-5499-ba4c-c6a3c35cd8d4@kernel.dk>
 <47f79645-53b7-b11c-167a-f5721b53df02@physik.fu-berlin.de>
 <9d9acec6-1e8c-2d68-5dfa-d58c11cf5cc4@kernel.dk>
 <070780c4-445e-6373-c8f4-1c72d0f3b4e0@physik.fu-berlin.de>
 <1047f3e5-4599-c34f-3176-9f41d2e1246b@kernel.dk>
In-Reply-To: <1047f3e5-4599-c34f-3176-9f41d2e1246b@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-sh@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Hi Jens!

On 11/17/20 4:06 PM, Jens Axboe wrote:
> On 11/16/20 10:26 PM, John Paul Adrian Glaubitz wrote:
>> Hi Jens!
>>
>> On 11/9/20 3:14 PM, Jens Axboe wrote:
>>>> Sorry for the delay. I'm busy at the moment and my SH board is currently
>>>> building the Perl 5.32 package for Debian. Will try to test your patches
>>>> by tomorrow, also ia64.
>>>
>>> Thanks, both would be appreciated! Just CC'ed you on the updated patch
>>> for sh.
>>
>> Is this still relevant for testing? I'm ready to test now, much later than
>> I thought, sorry.
>>
>> I'm going to build Linus' latest kernel for my SH and IA64 machines now
>> and then I can test additional patches on top of it.
> 
> Thanks, would definitely still appreciate testing. You can just run
> linux-next if you want, it's got everything in there. Or apply the
> separate patches to -git, either approach is fine.

Apologies for the late reply.

I just pulled Linus' latest tree today with your patch for SH included and
I'm not seeing any regressions.

Is there away to test the change itself?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
