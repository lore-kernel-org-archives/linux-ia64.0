From: Andi Kleen <ak@suse.de>
Date: Wed, 15 Dec 2004 09:14:09 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <20041215091409.GA20090@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com> <9250000.1103050790@flay> <20041214191348.GA27225@wotan.suse.de> <19030000.1103054924@flay> <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <20041215040854.GC27225@wotan.suse.de> <41BFEAA5.1090109@cosmosbay.com> <20041215074636.GR27225@wotan.suse.de>
In-Reply-To: <20041215074636.GR27225@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Brent Casavant <bcasavan@sgi.com>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

> > 2) What are the exact number of data TLB entries (for small pages and 
> > huge ones) for opterons ?
> 
> check the data sheets, but iirc 64 large DTLBs and 1024+ 4K DTLBS.
> That is the L2 TLB, there is also a L1 but it is likely inclusive (?)

After checking the data sheets it is actually 32 2MB DLTBs and 512 4K DTLBs
(L2). And the same for the ITLB. 

-Andi
