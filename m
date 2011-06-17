From: Clemens Ladisch <clemens@ladisch.de>
Date: Fri, 17 Jun 2011 13:16:35 +0000
Subject: Re: [PATCH] firmware: Make firmware drivers generally available
Message-Id: <4DFB53B3.8070806@ladisch.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110617103218.GA29723@opensource.wolfsonmicro.com> <1308310831-27861-1-git-send-email-lars@metafoo.de>
In-Reply-To: <1308310831-27861-1-git-send-email-lars@metafoo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lars-Peter Clausen <lars@metafoo.de>
Cc: Mike Frysinger <vapier@gentoo.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, Mark Brown <broonie@opensource.wolfsonmicro.com>

Lars-Peter Clausen wrote:
> Currently only x86, ia64 and blackfin architectures include
> drivers/firmware/Kconfig, as a result firmware drivers are only available on
> these platforms. This has not been a problem historically, because all of the
> firmware drivers were architecture specific.
> 
> But this has changed with the addition of the SigmaStudio firmware loader
> (commit e359dc24 "sigma-firmware: loader for Analog Devices' SigmaStudio"),
> which is used to parse and load firmware files for Analog Devices' SigmaDSP
> processors.

It looks as if sigma.c doesn't actually belong into drivers/firmware.
That directory is for code that lets the kernel access the firmware
of the platform that the kernel itself runs on.

The request_firmware() stuff is usually part of the actual driver that
needs it.


Regards,
Clemens
