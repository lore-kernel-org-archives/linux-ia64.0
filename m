From: Anton Blanchard <anton@samba.org>
Date: Tue, 21 Dec 2004 11:46:06 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <20041221114605.GB21710@krispykreme.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <50260000.1103061628@flay> <20041215045855.GH27225@wotan.suse.de> <20041215144730.GC24000@krispykreme.ozlabs.ibm.com> <20041216050248.GG32718@wotan.suse.de> <20041216051323.GI24000@krispykreme.ozlabs.ibm.com> <20041216141814.GA10292@rx8.austin.ibm.com> <20041220165629.GA21231@rx8.austin.ibm.com>
In-Reply-To: <20041220165629.GA21231@rx8.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Jose R. Santos" <jrsantos@austin.ibm.com>
Cc: Andi Kleen <ak@suse.de>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

 
> The difference between the two runs was with in noise of the benchmark on
> my small setup.  I wont be able to get a larger NUMA system until next year,
> so I'll retest when that happens.  In the mean time, I don't see a reason
> either to stall this patch, but that may change on I get numbers on a
> larger system.

Thanks Jose!

Brent, looks like we are happy on the ppc64 front.

Anton
