From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 23 May 2007 17:44:16 +0000
Subject: RE: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <617E1C2C70743745A92448908E030B2A01882BFD@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070522234314.54081817.akpm@linux-foundation.org>
References: <20070522234314.54081817.akpm@linux-foundation.org>
In-Reply-To: <20070522234314.54081817.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, David Chinner <dgc@sgi.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> > Saw this when running strace -f on a script on 2.6.21 on ia64:
> > 
> > BUG: sleeping function called from invalid context at kernel/fork.c:385
> > in_atomic():1, irqs_disabled():0
    ... snip ...
> > I could reproduce it via 'strace -f sleep 1'
> > 
>
> I'd say this is specific to ia64.   Someone would have spotted it on
> x86 by now.

I tried the "strace -f sleep 1" on 2.6.22-rc2, and I didn't see this "BUG"
there.  Can you try your other test cases on the latest kernel.  If it has
already been fixed we can see about identifying the patch for possible backport
to 2.6.21.stable

-Tony
