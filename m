From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Tue, 22 Aug 2000 21:22:15 +0000
Subject: Re: [Linux-ia64] Re: IA-64 XFree86 (was: XFree 4.0.1 module loading)
Message-Id: <marc-linux-ia64-105590678205380@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205362@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205362@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 21, 2000, Mark Vojkovich <mvojkovich@valinux.com> wrote:
> 
> On Mon, 21 Aug 2000, David Mosberger wrote:
> 
> > >>>>> On Mon, 21 Aug 2000 12:34:11 -0700 (PDT), Mark Vojkovich <mvojkovich@valinux.com> said:
> > 
> >   Mark> 1) Firmware issues that prevent the X-server from working
> >   Mark> reliably with SMP (even lspci locks up in the SAL code).
> > 
> > As Bill already pointed out, we have seen any problems since we fixed
> > /proc/bus/pci/devices not to overwrite kernel memory.  We have a
> > dual-CPU BigSur here which runs X fine and lspci doesn't crash the
> > machine.  The quick and dirty hack is to use 16KB page size.
> 
>    OK, that's good news.  I'll get somebody to update the kernel
> on my dual-CPU BigSur and give it a try.

Nope, this was not the problem. We have the same problem going directly
to the hardware as well, as XFree and scanpci (XFree tool) does. But, it
couldn't hurt to try the patch.

I'll try upgrading him to ver 59 of the workstations firmware to see if
it helps.

JE


