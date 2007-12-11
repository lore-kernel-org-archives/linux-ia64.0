From: Robin Holt <holt@sgi.com>
Date: Tue, 11 Dec 2007 12:21:14 +0000
Subject: Re: Linux on Intel "Big Sur"
Message-Id: <20071211122114.GA29786@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <475C2CF3.9010206@netbynet.ru>
In-Reply-To: <475C2CF3.9010206@netbynet.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 11, 2007 at 05:17:06PM +1100, Peter Chubb wrote:
> >>>>> "Alexei" = Alexei Gerasimov <alex@netbynet.ru> writes:
> 
> 
> Alexei> I have faced a problem of getting an operating system for
> Alexei> it. Namely, Linux. I have tried installing both Debian 3.0r6
> Alexei> Woody and Debian 4.0r1 Etch, however, the CD kernel doesn't
> Alexei> succeed to boot. Somewhere after probing for USB and SCSI
> Alexei> devices, the video signal is lost (monitor switches into a
> Alexei> stand-by mode), and nothing else happens. Since I'm using some
> Alexei> old Matrox graphics card, I thought it could be a problem with
> Alexei> framebuffer, but disabling the framebuffer didn't help.
> 
> 
> Hmmm.  I boot i2000s at least once a month to make sure Linux still
> works with the latest kernels.  But I use the BigSur defconfig, not
> the generic one the distros use (note to self:  try with a generic
> kernel).

Yeah, I booted a bigsur with the 2.6.22 kernel bigsur config a couple
months ago.  I ran into userland issues as the OS was ancient.

Good Luck,
Robin
