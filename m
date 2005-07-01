From: Greg Edwards <edwardsg@sgi.com>
Date: Fri, 01 Jul 2005 17:39:59 +0000
Subject: Re: [PATCH] fix generic/up builds in 2.6.12
Message-Id: <20050701173959.GG12721@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1120073612.8358.44.camel@localhost>
In-Reply-To: <1120073612.8358.44.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 29, 2005 at 01:33:32PM -0600, dann frazier wrote:
| Resending with a fixed subject & correct cc addr :)
| 
| Here is a resubmittal of Jesse Barnes' fix for generic UP builds, ported
| to 2.6.12.  I've boot tested it on an rx2600.
| 
| Can someone test on an sn2 system?

Dann,

Yep, works fine on various sn2 configs except for one particular
hardware/prom configuation, which I believe is unrelated to this patch
(we're still looking at it).

It would probably be worthwhile to incorporate Jesse's comments to
the last post of this:

http://marc.theaimsgroup.com/?l=linux-ia64&m1077582813691&w=2

Greg
