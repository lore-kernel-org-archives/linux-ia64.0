From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 23 Feb 2021 12:36:32 +0000
Subject: Re: 5.11 regression: "ia64: add support for TIF_NOTIFY_SIGNAL" breaks ia64 boot
Message-Id: <9441757f-d4bc-a5b5-5fb0-967c9aaca693@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
 <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
 <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
 <20210223083507.43b5a6dd@sf>
 <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
In-Reply-To: <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyich@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 2/23/21 10:13 AM, John Paul Adrian Glaubitz wrote:
> On 2/23/21 9:35 AM, Sergei Trofimovich wrote:> On Tue, 23 Feb 2021 00:55:50 +0100
>> John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:
>>
>>> For me, Debian also stopped booting on ia64 with systemd and I bisected it to this
>>> change. Glad to see I'm not the only one.
>>>
>>> The changes Jens suggested back then unfortunately didn't help :(.
>>
>> I wonder if systemd is less tolerant to kernel that throws signal 0 at it.
>>
>> Looks like https://marc.info/?l=linux-ia64&m1404320617004&w=2
>> fixed all the issues for me.
> 
> Just gave it a try and it still doesn't work.

Maybe your other two patches to fix the strace issues are required as well?

Or do you happen to have more patches in the Gentoo kernel?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
