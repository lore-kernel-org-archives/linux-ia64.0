From: Robin Holt <holt@sgi.com>
Date: Fri, 12 Nov 2004 12:50:35 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <20041112125035.GI6093@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 11, 2004 at 04:38:44PM -0800, Christoph Lameter wrote:
> On Wed, 10 Nov 2004, Magnus Damm wrote:
> 
> > A nice feature would be to be able to assign each process/mm a stat
> > gathering mode - choose between no statistics, statistics updated every
> > N jiffy and real time statistics. Yeah, dream on.
> 
> Hmm... Given the various problems with all these approaches this
> may be the right way to go. Working on the dream now.

Are you saying that there is no way to solve this in a scalable fashion?
Not by seperating the cachelines for the locks and counters?  Not by
putting in per-cpu counters?  Nothing else will work?  What is the
solution for the customers that do have statistics turned on?  What
multiplier does the admin give to the job when they need to turn on
statistics?  How do job-server type sites work with this when one
of their reasons to kill jobs is based on RSS?  They would need it
turned on for nearly every process and we are back in the same boat.

I am embarrased for SGI that this discussion has gone on as long
as it has.  There are hundreds of counters in the system which
have been affected by scaling issues.  Why could those be solved
and this one not?  Can we focus on the correct fix instead of
a kludge which will not be acceptable to our customers?

Sorry for the rant.  It has been a stressful week.

Robin
