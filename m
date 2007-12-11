From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 11 Dec 2007 06:17:06 +0000
Subject: Re: Linux on Intel "Big Sur"
Message-Id: <87wsrl7o2l.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <475C2CF3.9010206@netbynet.ru>
In-Reply-To: <475C2CF3.9010206@netbynet.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Alexei" = Alexei Gerasimov <alex@netbynet.ru> writes:


Alexei> I have faced a problem of getting an operating system for
Alexei> it. Namely, Linux. I have tried installing both Debian 3.0r6
Alexei> Woody and Debian 4.0r1 Etch, however, the CD kernel doesn't
Alexei> succeed to boot. Somewhere after probing for USB and SCSI
Alexei> devices, the video signal is lost (monitor switches into a
Alexei> stand-by mode), and nothing else happens. Since I'm using some
Alexei> old Matrox graphics card, I thought it could be a problem with
Alexei> framebuffer, but disabling the framebuffer didn't help.


Hmmm.  I boot i2000s at least once a month to make sure Linux still
works with the latest kernels.  But I use the BigSur defconfig, not
the generic one the distros use (note to self:  try with a generic
kernel).

I strongly suggest trying to boot using a serial console.  The video
stuff has been pretty flakey at various times.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
