From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 29 Jul 2004 18:46:30 +0000
Subject: Re: [PATCH] minor cyclone cleanup
Message-Id: <200407291246.30314.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407291054.05720.bjorn.helgaas@hp.com>
In-Reply-To: <200407291054.05720.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 29 July 2004 12:37 pm, john stultz wrote:
> With my re-work, the system clock is driven from a time-source, not the
> interval timer. That time-source is the only semi-arch-specific bit in
> the code, so it can be the ITC, the cyclone counter, HPET, or even the
> RTC. Its not all that different then ia64's time_interpolator
> infrastructure, just cleaned up and simplified a bit. 

This might have possibilities.  Is there a way to compare the accuracy
of the ITC, HPET, and RTC, so we can pick the best one?  I know that
SAL_FREQ_BASE can tell us about the ITC and RTC, but I dunno about
the HPET.

> Another idea would be to make a userspace daemon who would read the RTC
> and use the kernel's adjtimex() syscall to manipulate time. This would
> be just like the userspace NTP daemon, only using the RTC instead of a
> timeserver. Not having sub-second resolution would mean it would have to
> be conservative and take quite some time to sync up, but it would be
> possible. 

This is what I had in mind, except that I was thinking about adding
RTC support to NTP rather than writing something from scratch.  NTP
has a lot of scary code that I don't want to replicate.
