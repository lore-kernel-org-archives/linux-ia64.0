From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 17 Jun 2011 15:56:29 +0000
Subject: Re: [PATCH] firmware: Make firmware drivers generally available
Message-Id: <BANLkTimWfT_LSLX36oLcSSYNqi4buBiJUQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110617103218.GA29723@opensource.wolfsonmicro.com>
 <1308310831-27861-1-git-send-email-lars@metafoo.de> <4DFB53B3.8070806@ladisch.de>
In-Reply-To: <4DFB53B3.8070806@ladisch.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Clemens Ladisch <clemens@ladisch.de>
Cc: Lars-Peter Clausen <lars@metafoo.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Fri, Jun 17, 2011 at 09:16, Clemens Ladisch wrote:
> It looks as if sigma.c doesn't actually belong into drivers/firmware.
> That directory is for code that lets the kernel access the firmware
> of the platform that the kernel itself runs on.

-EMISSINGBETTERSUGGESTION

> The request_firmware() stuff is usually part of the actual driver that
> needs it.

except for when the firmware format is the same across many drivers
because it has a unified format (by design)
-mike
