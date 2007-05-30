From: David Chinner <dgc@sgi.com>
Date: Wed, 30 May 2007 03:30:41 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <20070530033041.GH86004887@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070522234314.54081817.akpm@linux-foundation.org> <617E1C2C70743745A92448908E030B2A01882BFD@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A01882BFD@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, May 23, 2007 at 10:44:16AM -0700, Luck, Tony wrote:
> > > Saw this when running strace -f on a script on 2.6.21 on ia64:
> > > 
> > > BUG: sleeping function called from invalid context at kernel/fork.c:385
> > > in_atomic():1, irqs_disabled():0
>     ... snip ...
> > > I could reproduce it via 'strace -f sleep 1'
> > > 
> >
> > I'd say this is specific to ia64.   Someone would have spotted it on
> > x86 by now.
> 
> I tried the "strace -f sleep 1" on 2.6.22-rc2, and I didn't see this "BUG"
> there.  Can you try your other test cases on the latest kernel.  If it has
> already been fixed we can see about identifying the patch for possible backport
> to 2.6.21.stable

Sorry for taking so long to get back to this - I still see this in
2.6.22-rc2.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group
