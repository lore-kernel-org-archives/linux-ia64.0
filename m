From: Robin Holt <holt@sgi.com>
Date: Fri, 04 Mar 2005 08:46:27 +0000
Subject: Re: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <20050304084627.GA9503@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 03, 2005 at 01:57:49PM -0800, Luck, Tony wrote:
> >Here are the changes again.  I have not received a response from you
> >about the restructered shrink routine.  I have incorporated David
> >Mosberger's recommendations.
> 
> Your new shrink routine looks ok, but you didn't address the
> double role played by NODE_FREE_PAGES_SHIFT ... you just dropped the
> comment that explained one of its uses - which isn't what I'd hoped
> for :-)

The comment was left from the earlier set of patches where it
had a single role.  In that patch, we picked a number of pages to
free, freed that many, and went on with life expecting the next
pass to free a group.  Since the changes gave it a more complex
role and the code was not that complex, I figured I would remove
the comment and let anybody planning on changing it in the future
read the code to figure out the two roles.

> 
> I'm also a bit uncomfortable with:
> 
> +		preempt_enable();
> +		preempt_disable();
> 
> For a kernel with CONFIG_PREEMPT=n, this is a no-op ... so if there
> is a ton of extra pages on the quicklist, we'll loop freeing 16 at
> a time and re-computing how many to free, with no pause to take a
> breath (or a clock tick).

What do you want me to do.  I don't see anywhere else in the kernel
that these two lines are directly adjacent.  Most places that do
the disable/enable are in a function which does one thing.  That is
occasionally contained inside a larger loop.  We can not do that since
part of our outer loop control is based on the per_cpu variable we are
expecting to not change.  I suppose I could elminitate the disable/enable
entirely.  I haven't thought all the way through the possibilities,
but I would guess we could free a couple extra pages, but who cares.
You tell me what to do.

Robin
