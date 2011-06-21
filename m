From: Mike Frysinger <vapier@gentoo.org>
Date: Tue, 21 Jun 2011 01:45:56 +0000
Subject: Re: [uclinux-dist-devel] [PATCH] firmware: Make firmware drivers
Message-Id: <BANLkTinGMN8A99YZMVa1XDRuy3rUSO2UGg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110617103218.GA29723@opensource.wolfsonmicro.com>
 <1308310831-27861-1-git-send-email-lars@metafoo.de> <4DFB53B3.8070806@ladisch.de>
 <BANLkTimWfT_LSLX36oLcSSYNqi4buBiJUQ@mail.gmail.com> <4DFB98EE.9000609@ladisch.de>
 <BANLkTi=idGOgMkBXF6p-Uo9ARAmgb1uR_g@mail.gmail.com> <20110621003507.GG1905@opensource.wolfsonmicro.com>
In-Reply-To: <20110621003507.GG1905@opensource.wolfsonmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Lars-Peter Clausen <lars@metafoo.de>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, x86@kernel.org, Clemens Ladisch <clemens@ladisch.de>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, uclinux-dist-devel@blackfin.uclinux.org, Thomas Gleixner <tglx@linutronix.de>

On Mon, Jun 20, 2011 at 20:35, Mark Brown wrote:
> On Fri, Jun 17, 2011 at 02:25:21PM -0400, Mike Frysinger wrote:
>> On Fri, Jun 17, 2011 at 14:11, Clemens Ladisch wrote:
>> > "drivers/firmware" is the obvious name for both, but that makes
>> > it ambiguous.  I'd suggest to split the two subsystems into
>> > "drivers/host-firmware" and "drivers/device-firmware".
>
>> i honestly dont see how this is better.  the drivers/firmware/ isnt
>> exactly overflowing, and differentiating between the two modes doesnt
>> seem to gain us anything.
>
> Do we have anything like an actual subsystem in firmware?  If we do and
> it's sensible to do things that affect all firmwares then splitting
> seems reasonable but if not then it's less clear.

i dont think there is.  we havent hit enough critical mass yet to warrant it.
-mike
