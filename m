From: Robin Holt <holt@sgi.com>
Date: Sat, 31 Jul 2004 12:46:23 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040731124623.GB5160@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 30, 2004 at 03:15:35PM -0700, Luck, Tony wrote:
> Dean> The question is whether we export ia64_sal and sal_lock? Or change these
> Dean> inline functions to no longer be inline, move them to a new file (sn_sal.c),
> Dean> and export the individual function names?
> 
> Dean> From my point of view the first solution is better from the standpoint of
> Dean> the diagnostics folks who write tests that need to make SAL calls. It doesn't
> Dean> seem appropriate that the linux kernel be the repository of a bunch of ad hoc
> Dean> and miscellaneous SAL wrapper functions that no one but the diagnostics folks
> Dean> use.
> 
> Dean> I would like to know your opinions on the direction to go with this.
> 
> This looks like a lesser of two evils decision.  On balance I think
> that I'd prefer not to open up the floodgates for modules to make
> arbitrary SAL calls ... so I'd prefer to see you un-inline and
> export the functions that you need. "sn_sal.c" sounds a plausible
> name for a file to house these functions.
> 

This leaves our diags people with a fairly difficult position.
They have some online diags which need to excercise parts of the shub.
Those activities are currently coded in the PROM (make online and offline
diags a lot more consistent) executed via SAL calls.

Would you be alright with changing the inlines into real functions,
but still exporting the ia64_sal symbol as well?

Will you accept the online diags people sending sal call additions that
no kernel component will ever use?  Will that policy remain consistent
into the future?  This makes our job much more difficult as we move
toward not having our own kernel at all, but using standard distribution
kernels as they will always lag the community in merging back changes
made to the ia64 tree.  Again, that argues for having the ia64_sal
exported.  Please consider those needs when making your decision.

Thanks,
Robin
