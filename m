From: Mark Vojkovich <mvojkovich@valinux.com>
Date: Mon, 21 Aug 2000 22:40:23 +0000
Subject: [Linux-ia64] Re: IA-64 XFree86 (was: XFree 4.0.1 module loading)
Message-Id: <marc-linux-ia64-105590678205369@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205362@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205362@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 21 Aug 2000, Bill Nottingham wrote:

> Mark Vojkovich (mvojkovich@valinux.com) said: 
> > 1) Firmware issues that prevent the X-server from working reliably
> >    with SMP (even lspci locks up in the SAL code).
> 
> There is a kernel patch for this; there's a buffer overflow
> in the PCI code. (Unless you are running into something else,
> which is possible...)

   Does lspci work reliably on your SMP Big Sur?

> 
> > 3) The bios not assigning interrupts to cards that need them.
> >    My A3 machine will not boot with an NVIDIA card in it for
> >    this reason.
> 
> Is it sitting behind a PCI card with a bridge on it?
> 

  No.  I've not gotten any NVIDIA card to work in my A3 or
A0 machines.  The machine will not even get to the EFI prompt.
NVIDIA tells me this is because the bios is not giving the
card an interrupt, and they need one.


				Mark.


