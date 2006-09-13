From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 13 Sep 2006 00:28:44 +0000
Subject: Re: Does 2.6.17.11 kernel work on HP zx6000?
Message-Id: <20060913002844.GA11298@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060908232224.GA27087@lucon.org>
In-Reply-To: <20060908232224.GA27087@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 12, 2006 at 02:10:13PM -0600, Bjorn Helgaas wrote:
> On Tuesday 12 September 2006 10:51, H. J. Lu wrote:
> > > My guess is that there's something wrong with your console.  Maybe
> > > the kernel thinks you have a VGA console and you're looking at
> > > serial, or vice versa.  EFI can use multiple console devices, but
> > > the kernel generally only uses one.
> > 
> > That could be my problem. 2.6.9 works fine. How can I get it to
> > work?
> 
> Serial port naming changed in 2.6.10.  Documentation/ia64/serial.txt
> has more details.
> 
> > I can hook up a serial console. What is the serial setting?
> 
> If you have VGA, that is generally used by default.
> 
> IIRC, the zx6000 has these serial ports:
> 
>     ttyS0  built-in, labelled serial A
>     ttyS1  built-in, labelled serial B
>     ttyS2  optional on MP card, UPS port
>     ttyS3  optional on MP card, console port
> 
> So use "console=ttyS0" or "console=ttyS3" depending on which
> port you choose.
> 

Hi Bjorn,

Before I do that, can I try your config file?

Thanks.


H.J.
