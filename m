From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Mon, 22 Nov 2004 21:26:28 +0000
Subject: RE: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <65953E8166311641A685BDF71D865826058B5C@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041122162214.GE21861@wotan.suse.de>
In-Reply-To: <20041122162214.GE21861@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>, Andi Kleen <ak@suse.de>
Cc: Andreas Schwab <schwab@suse.de>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

Although I don't fully understand all the issues here,
I'm concerned about this proposal.  In particular, our
garbage collector (used by gcj, and Mono, among others)
uses signals to stop threads for each garbage collection.
With a small heap, and many threads, I would expect the
frequency of signal delivery to be similar to what you
get with performance tools.  But it does not, and should not,
use SIGPROF.

I think this is a more general issue.  Special casing one
piece of it is only going to make performance more surprising,
something I think should be avoided if at all possible.

Hans

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Ray Bryant
> Sent: Monday, November 22, 2004 11:23 AM
> To: Andi Kleen
> Cc: Andreas Schwab; Kernel Mailing List; linux-ia64@vger.kernel.org;
> lse-tech; holt@sgi.com; Dean Roe; Brian Sumner; John Hawkes
> Subject: Re: [Lse-tech] scalability of signal delivery for 
> Posix Threads
> 
> 
> OK, apparently SIGPROF is delivered in both the ITIMER_PROF and
> pmu interrupt cases, so if we special case that signal we should
> be fine.
> -- 
> Best Regards,
> Ray
> -----------------------------------------------
>                    Ray Bryant
> 512-453-9679 (work)         512-507-7807 (cell)
> raybry@sgi.com             raybry@austin.rr.com
> The box said: "Requires Windows 98 or better",
>             so I installed Linux.
> -----------------------------------------------
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
