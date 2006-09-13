From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 13 Sep 2006 15:03:59 +0000
Subject: Re: Does 2.6.17.11 kernel work on HP zx6000?
Message-Id: <200609130904.00032.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060908232224.GA27087@lucon.org>
In-Reply-To: <20060908232224.GA27087@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 12 September 2006 18:28, H. J. Lu wrote:
> On Tue, Sep 12, 2006 at 02:10:13PM -0600, Bjorn Helgaas wrote:
> > On Tuesday 12 September 2006 10:51, H. J. Lu wrote:
> > > > My guess is that there's something wrong with your console.  Maybe
> > > > the kernel thinks you have a VGA console and you're looking at
> > > > serial, or vice versa.  EFI can use multiple console devices, but
> > > > the kernel generally only uses one.
> > > 
> > > That could be my problem. 2.6.9 works fine. How can I get it to
> > > work?
> > 
> > Serial port naming changed in 2.6.10.  Documentation/ia64/serial.txt
> > has more details.
> > 
> > > I can hook up a serial console. What is the serial setting?
> > 
> > If you have VGA, that is generally used by default.
> > 
> > IIRC, the zx6000 has these serial ports:
> > 
> >     ttyS0  built-in, labelled serial A
> >     ttyS1  built-in, labelled serial B
> >     ttyS2  optional on MP card, UPS port
> >     ttyS3  optional on MP card, console port
> > 
> > So use "console=ttyS0" or "console=ttyS3" depending on which
> > port you choose.

> Before I do that, can I try your config file?

Sure.  I just used "make defconfig" for the kernel.  My elilo config
(for netbooting) is below.  I use ttyS0 (serial A) as my console.
I pass "console=uart,mmio,0xff5e0000" so that the console starts
working very early.  "console=ttyS0" would work as well, but wouldn't
start working until after the serial driver finds its devices.

But it sounds like you're using VGA at the moment.  I rarely use
that, but I think "console=tty0" would be the way to explicitly
specify that.  I think you would need CONFIG_VT, CONFIG_VT_CONSOLE,
and CONFIG_VGA_CONSOLE set for this (they're all set in defconfig).

Here's my elilo config:

delay0
root=/dev/sda2
read-only
prompt

image=/helgaas/ia64/vmlinux.gz
	label=Linux
	append="console=uart,mmio,0xff5e0000 debug"
