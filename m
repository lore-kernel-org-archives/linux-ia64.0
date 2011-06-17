From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 17 Jun 2011 15:56:54 +0000
Subject: Re: [PATCH] firmware: Make firmware drivers generally available
Message-Id: <BANLkTi=heLis-oj2McUHi0dvtDVedZ9Yjw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110617103218.GA29723@opensource.wolfsonmicro.com> <1308310831-27861-1-git-send-email-lars@metafoo.de>
In-Reply-To: <1308310831-27861-1-git-send-email-lars@metafoo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lars-Peter Clausen <lars@metafoo.de>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Fri, Jun 17, 2011 at 07:40, Lars-Peter Clausen wrote:
> Currently only x86, ia64 and blackfin architectures include
> drivers/firmware/Kconfig, as a result firmware drivers are only available on
> these platforms. This has not been a problem historically, because all of the
> firmware drivers were architecture specific.
>
> But this has changed with the addition of the SigmaStudio firmware loader
> (commit e359dc24 "sigma-firmware: loader for Analog Devices' SigmaStudio"),
> which is used to parse and load firmware files for Analog Devices' SigmaDSP
> processors. These DSPs are usually embedded in for example audio codecs, which
> use the I2C or SPI bus for communication and are not architecture specific.
> Thus make the firmware drivers generally available, so it can be used on all
> architectures.
>
> Note that this moves the Kconfig "Firmware Drivers" entry from the top-level to
> the "Device Drivers" submenu for architectures which had it already available.

Acked-by: Mike Frysinger <vapier@gentoo.org>
-mike
