From: Alan Mayer <ajm@sgi.com>
Date: Wed, 08 Oct 2003 16:40:05 +0000
Subject: Re: [PATCH] kill two dead headers
Message-Id: <marc-linux-ia64-106563138312813@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451477025244@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451477025244@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Oct 2003, Christoph Hellwig wrote:

> > It is also complicated, too complicated.  We at SGI are addressing
> > the issues that Christoph raises and more.
> 
> You are not.  You're ignoring suggestions and calling me names
> after patches.  Jesse and Jes are doing nice work OTOH but you
> are in the way of fixing the total mess up.

Well, yes, we are.  The big issue seems to be the sluggish way we push
our code out to kernel.org, particularly the 2.6 tree.  We are addressing
that problem.  Aggressively.  Emphatically.  It's a huge problem and
one that we (SGI) have to fix quickly.

> 
> > 1.  It's already been done.  Many of the patches that Christoph submitted
> > have been taken care of here at SGI, but the code hasn't been pushed
> > out to 2.6.  Some of Christoph's patches in this category are incomplete.
> > Some of the code he deleted performs a necessary function and his
> > patches result in panic's.
> 
> That's why they are sent to a public list.  If one of the patches is
> wrong please follow up to the patch and explain why.

Whether or not there are problems with one or more of the patches isn't really
the issue.  Our issue is that the patches are addressing things that have been
or are going to be addressed by the maintainers of the SGI IO infrastructure.
We are trying to avoid a situation where patches get in the way of what we're
trying to accomplish.

> 
> > It would simplify our lives enormously if none of these patches were applied, with the possible
> > exception of the last two.  They're pretty much stomping all over work already in progress or
> > introducing bugs that we don't really have the time or resources to track down and fix.
> 
> So submit your patches.  Jesse ACKed most of these and said he's waiting
> for your group for more feedback.  This didn't happen for more than a
> month so I've send them to a public list.  Seems like this is the only
> way to get more feedback from you than insults.
> 

I received one of your patches from Jesse about a week ago.  I responded to
him.  That has been the extent of it.  I can't address this communication
failure beyond that.  

We have been conducting a series of discussions on this subject internally.
The suggestions we have gotten from Jes, et al, have been good ones and
have been incorporated into our plans.  Your name has rarely come up.  If
you have been expecting feedback from us (the IO infrastructure group), no
one mentioned it to us.


		--ajm

If I swallow anything evil,
Put your finger down my throat.
--
Alan J. Mayer
SGI
ajm@sgi.com
WORK: 651-683-3131
HOME: 651-407-0134
--

