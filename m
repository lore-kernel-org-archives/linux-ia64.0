From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Jul 2005 01:35:53 +0000
Subject: RE: [PATCH] fix generic/up builds in 2.6.12
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03D924C2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1120073612.8358.44.camel@localhost>
In-Reply-To: <1120073612.8358.44.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>On Wed, Jun 29, 2005 at 01:33:32PM -0600, dann frazier wrote:
>| Resending with a fixed subject & correct cc addr :)
>| 
>| Here is a resubmittal of Jesse Barnes' fix for generic UP 
>builds, ported
>| to 2.6.12.  I've boot tested it on an rx2600.
>| 
>| Can someone test on an sn2 system?
>
>Dann,
>
>Yep, works fine on various sn2 configs except for one particular
>hardware/prom configuation, which I believe is unrelated to this patch
>(we're still looking at it).

There was a conflict in discontig.c with Bob Picco's memory-less nodes
patch ... which I resolved, it would be helpful if someone looked at
it to see that I got it right.  Patch is in my GIT tree (or will be
when kernel.org mirroring makes it visible).

Generic kernels don't boot on Tiger ... they oops in tiocx_init().
Turning off CONFIG_SGI_TIOCX works around this for now, but this needs
to be fixed.

Oh ... apologies to Dann ... in the commit commentary I said that
Greg had dug this back up out of obscurity.

>It would probably be worthwhile to incorporate Jesse's comments to
>the last post of this:
>
>http://marc.theaimsgroup.com/?l=linux-ia64&m1077582813691&w=2

Yes, it would be nice to apply some more cleanup ... but I've let
this patch get too stale before, so I put it in as-is for now.

-Tony

