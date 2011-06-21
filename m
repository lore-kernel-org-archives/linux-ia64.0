From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Tue, 21 Jun 2011 00:35:08 +0000
Subject: Re: [PATCH] firmware: Make firmware drivers generally available
Message-Id: <20110621003507.GG1905@opensource.wolfsonmicro.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110617103218.GA29723@opensource.wolfsonmicro.com>
 <1308310831-27861-1-git-send-email-lars@metafoo.de>
 <4DFB53B3.8070806@ladisch.de>
 <BANLkTimWfT_LSLX36oLcSSYNqi4buBiJUQ@mail.gmail.com>
 <4DFB98EE.9000609@ladisch.de>
 <BANLkTi=idGOgMkBXF6p-Uo9ARAmgb1uR_g@mail.gmail.com>
In-Reply-To: <BANLkTi=idGOgMkBXF6p-Uo9ARAmgb1uR_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Mike Frysinger <vapier@gentoo.org>
Cc: Clemens Ladisch <clemens@ladisch.de>, Lars-Peter Clausen <lars@metafoo.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org

On Fri, Jun 17, 2011 at 02:25:21PM -0400, Mike Frysinger wrote:
> On Fri, Jun 17, 2011 at 14:11, Clemens Ladisch wrote:

> > "drivers/firmware" is the obvious name for both, but that makes
> > it ambiguous. =A0I'd suggest to split the two subsystems into
> > "drivers/host-firmware" and "drivers/device-firmware".

> i honestly dont see how this is better.  the drivers/firmware/ isnt
> exactly overflowing, and differentiating between the two modes doesnt
> seem to gain us anything.

Do we have anything like an actual subsystem in firmware?  If we do and
it's sensible to do things that affect all firmwares then splitting
seems reasonable but if not then it's less clear.
