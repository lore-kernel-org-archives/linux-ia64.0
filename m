From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Fri, 26 Mar 2004 00:18:52 +0000
Subject: Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <33780000.1080260332@flay>
List-Id: <linux-ia64.vger.kernel.org>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk><20040325130433.0a61d7ef.akpm@osdl.org><41997489.1080257240@42.150.104.212.access.eclipse.net.uk> <20040325155117.60dbc0e1.akpm@osdl.org>
In-Reply-To: <20040325155117.60dbc0e1.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> I think it's simply:
> 
> - Make normal overcommit logic skip hugepages completely
> 
> - Teach the overcommit_memory=2 logic that hugepages are basically
>   "pinned", so subtract them from the arithmetic.
> 
> And that's it.  The hugepages are semantically quite different from normal
> memory (prefaulted, preallocated, unswappable) and we've deliberately
> avoided pretending otherwise.

It would be nice (to fix some of the posted problems) if hugepages didn't
have to be prefaulted ... if they had their own overcommit pool (that we
used whether normal overcommit was on or not), that'd be unnecessary.

Specifically:

1) SGI found that requesting oodles of large pages took forever.
2) NUMA allocation API wants to be able to specify policies, which
means not prefaulting them.

I'd agree that fixing stopping hugepages from using the main overcommit
pool is the first priority, but it'd be nice to go one stage further.

M.

