From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 12 Sep 2006 20:10:13 +0000
Subject: Re: Does 2.6.17.11 kernel work on HP zx6000?
Message-Id: <200609121410.13657.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060908232224.GA27087@lucon.org>
In-Reply-To: <20060908232224.GA27087@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 12 September 2006 10:51, H. J. Lu wrote:
> > My guess is that there's something wrong with your console.  Maybe
> > the kernel thinks you have a VGA console and you're looking at
> > serial, or vice versa.  EFI can use multiple console devices, but
> > the kernel generally only uses one.
> 
> That could be my problem. 2.6.9 works fine. How can I get it to
> work?

Serial port naming changed in 2.6.10.  Documentation/ia64/serial.txt
has more details.

> I can hook up a serial console. What is the serial setting?

If you have VGA, that is generally used by default.

IIRC, the zx6000 has these serial ports:

    ttyS0  built-in, labelled serial A
    ttyS1  built-in, labelled serial B
    ttyS2  optional on MP card, UPS port
    ttyS3  optional on MP card, console port

So use "console=ttyS0" or "console=ttyS3" depending on which
port you choose.

If you're using a LAN connection to the MP, you still need
to use "console=ttyS3" to select the MP console UART, which
the MP splices into the LAN connection.
