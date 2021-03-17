From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 17 Mar 2021 17:53:04 +0000
Subject: Re: 5.11 regression: "ia64: add support for TIF_NOTIFY_SIGNAL" breaks ia64 boot
Message-Id: <c2098299-68c6-78da-da43-c848ee4eb7b0@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
 <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
 <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
 <20210223083507.43b5a6dd@sf>
 <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
 <9441757f-d4bc-a5b5-5fb0-967c9aaca693@physik.fu-berlin.de>
 <20210223192743.0198d4a9@sf>
 <8d54dd1d-a035-8dff-64dc-7175aba6033f@physik.fu-berlin.de>
In-Reply-To: <8d54dd1d-a035-8dff-64dc-7175aba6033f@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyich@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi!

On 3/17/21 6:42 PM, John Paul Adrian Glaubitz wrote:
>> Here are dmesg and config from my machine with successfull boot:
>>     https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.11
>>     https://dev.gentoo.org/~slyfox/configs/guppy-config-5.11
> 
> Just gave it a try using this kernel configuration. It's never loading the hpsa
> module for me which I find really strange. The module isn't even showing up in
> the kernel message buffer.

Never mind. I just forgot to create an initrd this time, user error :-).

Works again.

>>> [    0.036000] ERROR: Invalid distance value range                                                            
>>> [    0.036000]                                                                                                
>>> [    0.036000]   00 00 00 00 00 00
>>
>> I don't see this string in the 5.11 kernel source. But
>>    https://lore.kernel.org/lkml/161356785681.20312.13022545187499987936.tip-bot2@tip-bot2/T/
>> hints it's might be something very new and you are in the
>> middle of 5.12-rc1?
> 
> I'm seeing this using your exact kernel configuration.

This issue is still there, however. Do you see this as well?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
