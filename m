From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 02 Mar 2021 22:31:32 +0000
Subject: Re: 5.11 regression: "ia64: add support for TIF_NOTIFY_SIGNAL" breaks ia64 boot
Message-Id: <25dfced0-88b2-b5b3-f1b6-8b8a9931bf90@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
 <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
 <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
 <20210223083507.43b5a6dd@sf>
 <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
 <9441757f-d4bc-a5b5-5fb0-967c9aaca693@physik.fu-berlin.de>
 <20210223192743.0198d4a9@sf> <20210302222630.5056f243@sf>
In-Reply-To: <20210302222630.5056f243@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyich@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Sergei!

On 3/2/21 11:26 PM, Sergei Trofimovich wrote:
> Gave v5.12-rc1 a try today and got a similar boot failure around
> hpsa queue initialization, but my failure is later:
>     https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1
> Maybe I get different error because I flipped on most debugging
> kernel options :)
> 
> Looks like 'ERROR: Invalid distance value range' while being
> very scary are harmless. It's just a new spammy way for kernel
> to report lack of NUMA config on the machine (no SRAT and SLIT
> ACPI tables).
> 
> At least I get hpsa detected on PCI bus. But I guess it's discovered
> configuration is very wrong as I get unaligned accesses:
>     [   19.811570] kernel unaligned access to 0xe000000105dd8295, ip=0xa000000100b874d1
> 
> Bisecting now.

Sounds good. I guess we should get Jens' fix for the signal regression
merged as well as your two fixes for strace.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
