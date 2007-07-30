From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 30 Jul 2007 18:41:45 +0000
Subject: RE: [PATCH] ia64: fix a few section mismatch warnings
Message-Id: <617E1C2C70743745A92448908E030B2A0209C43A@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070728061551.GA21626@uranus.ravnborg.org>
References: <20070726210141.GA7266@uranus.ravnborg.org>
In-Reply-To: <20070726210141.GA7266@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> > Oops.  You moved the multiply by sizeof(struct ia64_mca_cpu) up into
> > the mca_bootmem() function to make it very specific to this use. But
> > mutiply has higher precedence than addition.
>
> Oh crap - good catch.
> Shall I resubmit a corrected patch?

Are there any other ways that we might tag the callsite to let
modpost know that this instance is safe?  Adding a call to a wrapper
function in __init_refok space feels kludgy, and whatever comments
you stick on that function, it is sitting there waiting for someone
who shouldn't to make a call.

If not ... then just make the mca_bootmem() function take
no args.  It can calculate the amount of memory, it can do
the next bit too and return a result KERNEL_STACK_SIZE aligned
too.

-Tony
