From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Date: Thu, 23 Dec 2004 02:19:01 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <20041223021901.GA27746@rx8.austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <50260000.1103061628@flay> <20041215045855.GH27225@wotan.suse.de> <20041215144730.GC24000@krispykreme.ozlabs.ibm.com> <20041216050248.GG32718@wotan.suse.de> <20041216051323.GI24000@krispykreme.ozlabs.ibm.com> <20041216141814.GA10292@rx8.austin.ibm.com> <20041220165629.GA21231@rx8.austin.ibm.com> <20041221114605.GB21710@krispykreme.ozlabs.ibm.com> <Pine.SGI.4.61.0412211019150.48124@kzerza.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.61.0412211019150.48124@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>
Cc: Anton Blanchard <anton@samba.org>, "Jose R. Santos" <jrsantos@austin.ibm.com>, Andi Kleen <ak@suse.de>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

Brent Casavant <bcasavan@sgi.com> [041221]:
> I didn't realize this was ppc64 testing.  What was the exact setup
> for the testing?  The patch as posted (and I hope clearly explained)
> only turns on the behavior by default when both CONFIG_NUMA and
> CONFIG_IA64 were active.  It could be activated on non-IA64 by setting
> hashdist=1 on the boot line, or by modifying the patch.

I wasn't aware of the little detail.  I re-tested with hashdist=1 and
this time it shows a slowdown of about 3%-4% on a 4-Way Power5 system 
(2 NUMA nodes) with 64GB.  Don't see a big problem if the things is off
by default on non IA64 systems though.

> I would hate to find out that the testing didn't actually enable the
> new behavior.

Serves me right for not reading the entire thread. :)

-JRS
