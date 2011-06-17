From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 17 Jun 2011 18:25:21 +0000
Subject: Re: [PATCH] firmware: Make firmware drivers generally available
Message-Id: <BANLkTi=idGOgMkBXF6p-Uo9ARAmgb1uR_g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110617103218.GA29723@opensource.wolfsonmicro.com>
 <1308310831-27861-1-git-send-email-lars@metafoo.de> <4DFB53B3.8070806@ladisch.de>
 <BANLkTimWfT_LSLX36oLcSSYNqi4buBiJUQ@mail.gmail.com> <4DFB98EE.9000609@ladisch.de>
In-Reply-To: <4DFB98EE.9000609@ladisch.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Clemens Ladisch <clemens@ladisch.de>
Cc: Lars-Peter Clausen <lars@metafoo.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Fri, Jun 17, 2011 at 14:11, Clemens Ladisch wrote:
> Mike Frysinger wrote:
>> On Fri, Jun 17, 2011 at 09:16, Clemens Ladisch wrote:
>> > It looks as if sigma.c doesn't actually belong into drivers/firmware.
>> > That directory is for code that lets the kernel access the firmware
>> > of the platform that the kernel itself runs on.
>>
>> -EMISSINGBETTERSUGGESTION
>
> I *knew* somebody would ask.  :)
>
> "drivers/firmware" is the obvious name for both, but that makes
> it ambiguous.  I'd suggest to split the two subsystems into
> "drivers/host-firmware" and "drivers/device-firmware".

i honestly dont see how this is better.  the drivers/firmware/ isnt
exactly overflowing, and differentiating between the two modes doesnt
seem to gain us anything.
-mike
