From: "Zhu, Yi" <yi.zhu@intel.com>
Date: Wed, 02 Jul 2003 00:45:49 +0000
Subject: RE: [Linux-ia64] RTC support on ia64
Message-Id: <marc-linux-ia64-105710698522482@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805600@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805600@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Thanks both! I got realfeel4 work!

-yi

> -----Original Message-----
> From: Eric Piel [mailto:Eric.Piel@Bull.Net]
> Sent: Tuesday, July 01, 2003 8:15 PM
> To: Zhu, Yi
> Cc: Joel GUILLET; linux-ia64@vger.kernel.org
> Subject: Re: [Linux-ia64] RTC support on ia64
> 
> 
> "Zhu, Yi" wrote:
> > 
> > Hi Joel,
> > 
> > Do you have the ia64 rtc patch for 2.4 kernel? I need the rtc
> > driver to test the latency with realfeel.
> 
> Hello Yi,
> Joel was a trainee, so he's not here anymore and I'm the new one.
> 
> We do not have any 2.4 version but the backport shouldn't be 
> hard. When
> Joel did this patch it was also in order to get realfeel working.
> The point is that it seems on ia64 measuring latencies using 
> the perfmon
> capabilities of the processor is a much better idea.
> 
> Peter Chubb even developed a small realfeel equivalent that 
> does exactly
> that! It should work both on 2.4 and 2.5 kernels. You can 
> find it on the
> perfmon homepage and at this address:
> http://www.gelato.unsw.edu.au/patches/realfeel4.c
> 
> Cheers
> Eric
> 
