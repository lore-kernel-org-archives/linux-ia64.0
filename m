From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 21 Dec 2004 16:23:59 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <Pine.SGI.4.61.0412211019150.48124@kzerza.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com>
 <50260000.1103061628@flay> <20041215045855.GH27225@wotan.suse.de>
 <20041215144730.GC24000@krispykreme.ozlabs.ibm.com> <20041216050248.GG32718@wotan.suse.de>
 <20041216051323.GI24000@krispykreme.ozlabs.ibm.com> <20041216141814.GA10292@rx8.austin.ibm.com>
 <20041220165629.GA21231@rx8.austin.ibm.com> <20041221114605.GB21710@krispykreme.ozlabs.ibm.com>
In-Reply-To: <20041221114605.GB21710@krispykreme.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anton Blanchard <anton@samba.org>
Cc: "Jose R. Santos" <jrsantos@austin.ibm.com>, Andi Kleen <ak@suse.de>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Tue, 21 Dec 2004, Anton Blanchard wrote:

> > The difference between the two runs was with in noise of the benchmark on
> > my small setup.  I wont be able to get a larger NUMA system until next year,
> > so I'll retest when that happens.  In the mean time, I don't see a reason
> > either to stall this patch, but that may change on I get numbers on a
> > larger system.
> 
> Thanks Jose!
> 
> Brent, looks like we are happy on the ppc64 front.

I didn't realize this was ppc64 testing.  What was the exact setup
for the testing?  The patch as posted (and I hope clearly explained)
only turns on the behavior by default when both CONFIG_NUMA and
CONFIG_IA64 were active.  It could be activated on non-IA64 by setting
hashdist=1 on the boot line, or by modifying the patch.

I would hate to find out that the testing didn't actually enable the
new behavior.

Thanks,
Brent

-- 
Brent Casavant                          If you had nothing to fear,
bcasavan@sgi.com                        how then could you be brave?
Silicon Graphics, Inc.                    -- Queen Dama, Source Wars
