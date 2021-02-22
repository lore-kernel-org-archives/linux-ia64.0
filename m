From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 22 Feb 2021 23:55:50 +0000
Subject: Re: 5.11 regression: "ia64: add support for TIF_NOTIFY_SIGNAL" breaks ia64 boot
Message-Id: <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
 <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
In-Reply-To: <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <axboe@kernel.dk>, Sergei Trofimovich <slyich@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Sergei!

On 2/23/21 12:34 AM, Jens Axboe wrote:
> On 2/22/21 4:05 PM, Sergei Trofimovich wrote:
>> Hia Jens!
>>
>> Tried 5.11 on rx3600 box and noticed it has
>> a problem handling init (5.10 booted fine):
>>
>> INIT: version 2.98 booting
>>
>>    OpenRC 0.42.1 is starting up Gentoo Linux (ia64)
>>
>> mkdir `/run/openrc': Read-only file system
>> mkdir `/run/openrc/starting': No such file or directory
>> mkdir `/run/openrc/started': No such file or directory
>> mkdir `/run/openrc/stopping': No such file or directory
>> mkdir `/run/openrc/inactive': No such file or directory
>> mkdir `/run/openrc/wasinactive': No such file or directory
>> mkdir `/run/openrc/failed': No such file or directory
>> mkdir `/run/openrc/hotplugged': No such file or directory
>> mkdir `/run/openrc/daemons': No such file or directory
>> mkdir `/run[   14.595059] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
>> [   14.599059] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b ]---
>>
>> I suspect we build bad signal stack frame for userspace.

For me, Debian also stopped booting on ia64 with systemd and I bisected it to this
change. Glad to see I'm not the only one.

The changes Jens suggested back then unfortunately didn't help :(.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
