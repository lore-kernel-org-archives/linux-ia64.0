From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 May 2007 20:11:17 +0000
Subject: RE: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <617E1C2C70743745A92448908E030B2A019298C6@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070530044448.GK86004887@sgi.com>
References: <20070522234314.54081817.akpm@linux-foundation.org>
In-Reply-To: <20070522234314.54081817.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Chinner <dgc@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> Hmmm - I wonder if my tree is screwed up in some weird way. I'm seeing link
> warnings as well:
>
> WARNING: init/built-in.o - Section mismatch: reference to .init.data: from .sdata after 'root_mountflags' (at offset 0x38)

I thought that I'd got the section mis-match warnings down to
just one (and that was in ACPI code, so I sent a patch to Len
for it).

Are you building from defconfig, or one of the standard ones? Changing
config options always has the possibility of unearthing new spots
where there are conflicts between __init, __cpuinit and __devinit.

But I've had other complaints that these Section mismatch warnings
are still showing up in kernels built from the "standard" config
files (arch/ia64/configs/*) ... which I'm not seeing.  So I'm more
than a little confused about this.

These errors are unlikely to be related to the strace bug that
you've reported.  I'll try to pound on this some more when I'm
back on the same continent as my test machines.


-Tony
