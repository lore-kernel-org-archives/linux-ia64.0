From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Jul 2004 22:01:41 +0000
Subject: Re: Timer patches (nsec support + fastcalls for gettod/clock_gettime for all clocks)
Message-Id: <16627.2629.763879.766318@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph,

Your putting out patches faster than I can comment on them, so I'll
just start commenting anyhow... ;-)

In general, I think your patches are heading in a good direction.
Very nice to have someone to get this fleshed out properly!

Minor stuff:

 - please avoid trailing whitespace (as usual)
 - please try to stay closer to Linux formatting conventions, e.g.,
   there should be blanks around assignment-operators; also the
   code in time_interpolator_get_offset() is formatted _really_
   strangely
 - the DEBUG-stuff should be dropped in the final version, I think

I haven't reviewed the assembly code yet--the fsys-handlers need great
care (and testing), obviously.  (Does your fsys_gettimeofday() save
"pr" before modifying p1 etc?  I didn't see it, but like I said, I
haven't yet fully reviewed the assembly code.  Also, please use ar.itc
instead of ar44.)

Is there any reason the CPU_TIMER macro couldn't be replaced in
get_cycles()?

Two other comments:

 * Perhaps rename TIME_SOURCE_MEM{32,64} to TIME_SOURCE_MMIO{32,64}
   for clarity?

 * I think the getnstimeofday() changes won't be accepted.  Instead,
   probably a better approach is to switch over to gettimeofday()
   returning a timespec.  IIRC, George Anziger had a patch to do that.
   Perhaps you can ask him to dust off that patch?

	--david
