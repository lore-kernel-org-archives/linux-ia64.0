From: Andy Whitcroft <apw@shadowen.org>
Date: Thu, 25 Mar 2004 23:59:21 +0000
Subject: Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <1739144.1080259161@[192.168.0.89]>
List-Id: <linux-ia64.vger.kernel.org>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
 	<20040325130433.0a61d7ef.akpm@osdl.org>
 	<41997489.1080257240@42.150.104.212.access.eclipse.net.uk>
 <20040325155117.60dbc0e1.akpm@osdl.org>
In-Reply-To: <20040325155117.60dbc0e1.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@aracnet.com

--On 25 March 2004 15:51 -0800 Andrew Morton <akpm@osdl.org> wrote:

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

True currently.  Though the thread that prompted this was in response to 
the time taken for this prefault and for the wish to fault them.

I'll have a poke about at it and see how small I can make it.

-apw
