From: David Chinner <dgc@sgi.com>
Date: Thu, 31 May 2007 00:53:41 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <20070531005341.GF85884050@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070530044448.GK86004887@sgi.com> <617E1C2C70743745A92448908E030B2A019298C6@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A019298C6@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, May 30, 2007 at 01:11:17PM -0700, Luck, Tony wrote:
> > Hmmm - I wonder if my tree is screwed up in some weird way. I'm seeing link
> > warnings as well:
> >
> > WARNING: init/built-in.o - Section mismatch: reference to .init.data: from .sdata after 'root_mountflags' (at offset 0x38)
> 
> I thought that I'd got the section mis-match warnings down to
> just one (and that was in ACPI code, so I sent a patch to Len
> for it).
> 
> Are you building from defconfig, or one of the standard ones?

sn2defconfig + kernel debug option plus xfs options.

> But I've had other complaints that these Section mismatch warnings
> are still showing up in kernels built from the "standard" config
> files (arch/ia64/configs/*) ... which I'm not seeing.  So I'm more
> than a little confused about this.
> 
> These errors are unlikely to be related to the strace bug that
> you've reported.  I'll try to pound on this some more when I'm
> back on the same continent as my test machines.

Ok - no real hurry - they don't appear to be causing me any problems
except build noise....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group
