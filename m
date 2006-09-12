From: "H. J. Lu" <hjl@lucon.org>
Date: Tue, 12 Sep 2006 16:51:39 +0000
Subject: Re: Does 2.6.17.11 kernel work on HP zx6000?
Message-Id: <20060912165139.GA8313@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060908232224.GA27087@lucon.org>
In-Reply-To: <20060908232224.GA27087@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 12, 2006 at 10:10:02AM -0600, Bjorn Helgaas wrote:
> On Friday 08 September 2006 17:22, H. J. Lu wrote:
> > Does 2.6.17.11 kernel work on HP zx6000? After uncompressing
> > kernel and loading initrd, kernel stops.
> 
> 2.6.17.11 has an ia64 build problem.  After I fixed that with
> this patch:
>   http://www.gelato.unsw.edu.au/archives/linux-ia64/0608/18861.html

I used a similar patch.

> 
> I built a defconfig kernel and booted it on an rx2600 (basically
> the same box as a zx6000).  The log is below.
> 
> My guess is that there's something wrong with your console.  Maybe
> the kernel thinks you have a VGA console and you're looking at
> serial, or vice versa.  EFI can use multiple console devices, but
> the kernel generally only uses one.
> 

That could be my problem. 2.6.9 works fine. How can I get it to
work?

I can hook up a serial console. What is the serial setting?


H.J.
