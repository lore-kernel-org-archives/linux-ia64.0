From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 29 Jul 2004 17:13:38 +0000
Subject: Re: [PATCH] minor cyclone cleanup
Message-Id: <200407291113.38609.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407291054.05720.bjorn.helgaas@hp.com>
In-Reply-To: <200407291054.05720.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 29 July 2004 11:02 am, john stultz wrote:
> Stay tuned! As soon as I finish reworking the NTP code bI'll be mailing
> out code. 

Ah, an NTP expert :-)  What do you think about adding an RTC driver
to NTP?  On our boxes (and I suspect many others), the system clock
is driven by  the interval timer.  But the RTC is much more accurate,
so it'd be nice if NTP knew how to use it.

The RTC is terribly slow and has low resolution, but in the absence of
anything better, it'd be nice if we could use it.

Is this possible?  Feasible?  I know the NTP guys would probably
laugh us out of the room, but not everybody has a fancy clock
attached to their box.
