From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 05 Apr 2005 00:40:39 +0000
Subject: Re: per_cpu_pagesets degrades MPI performance
Message-Id: <4251DE87.10002@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050404192827.GA15142@sgi.com>
In-Reply-To: <20050404192827.GA15142@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: akpm@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org

Jack Steiner wrote:

[snip nice detective work]

> Has anyone else seen this problem? I am considering adding
> a config option to allow a site to control the batch size
> used for per_cpu_pagesets. Are there other ideas that should 
> be pursued? 
> 

What about using a non power of 2 for the batch? Like 5.
If that helps, then we can make a patch to clamp it to a
good value. At a guess I'd say a power of 2 +/- 1 might be
the way to go.

Nick

-- 
SUSE Labs, Novell Inc.

