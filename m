From: Dean Nelson <dcn@sgi.com>
Date: Thu, 29 Jul 2004 18:36:23 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality
Message-Id: <20040729183623.GA5252@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 16, 2004 at 06:28:22PM +0100, Christoph Hellwig wrote:
> > +	XP_ASSERT(ch_number >= 0 && ch_number < XPC_NCHANNELS);
> > +	XP_ASSERT(payload_size != 0 && nentries != 0);
> > +	XP_ASSERT(func != NULL);
> > +	XP_ASSERT(assigned_limit != 0 && idle_limit <= assigned_limit);
> 
> Please use BUG_ON()

As you may have seen, on the lkml I asked for comments on the value of
creating a conditionally compiled version of BUG_ON(). I called it
DBUG_ON() and modeled it after dev_dbg(), which is conditionally
compiled based on #ifdef DEBUG. The subject of the lkml thread is:
[RFC] replace assorted ASSERT()s by something officially sanctioned

The feedback I got raised two issues:

	1. For a large number of ASSERT()s, WARN_ON() would be a better
	   fit than BUG_ON().

	2. The granularity of #ifdef DEBUG is too course. A finer
	   granularity on the driver level makes more sense. (This
	   also holds true for dev_dbg()).

To the first, I suggested that a conditionally compiled version of WARN_ON()
be added as well, i.e., DWARN_ON().

To the second, I didn't have much to say other than to agree. (I was hoping
the community would chime in with a community acceptable policy on this
matter.)

I still feel strongly that there is a need for a conditionally compiled
version of BUG_ON and WARN_ON() for the reason given in my RFC. (And I
really don't care what the name of the macro is.)

I haven't pushed any further on the matter because of the underwhelming
feedback to my RFC.

I'm bringing all of this to your attention because of the existing
XP_ASSERT()s in my proposed patches. I've dealt with the ones that
deserved to be BUG_ON()s. But I've got a lot of them that really (in
my opinion) should be conditionally compiled in. They really are only
necessary while in a debug mode.

So, I was wondering if you would accept my #define'ng a local DBUG_ON()
(or XP_ASSERT()) based on BUG_ON() and whether #ifdef DEBUG (or #ifdef
XP_DEBUG) is true?

Thanks,
Dean

