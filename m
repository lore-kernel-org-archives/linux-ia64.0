From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 04 Sep 2007 20:45:28 +0000
Subject: Re: [PATCH] slub - Use local_t protection
Message-Id: <Pine.LNX.4.64.0709041344040.6376@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827202203.GB5653@Krystal> <Pine.LNX.4.64.0708271324001.5884@schroedinger.engr.sgi.com>
 <20070827203913.GA7416@Krystal> <Pine.LNX.4.64.0708271401070.6435@schroedinger.engr.sgi.com>
 <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com>
 <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com>
 <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
 <20070904200429.GD8157@Krystal>
In-Reply-To: <20070904200429.GD8157@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

On Tue, 4 Sep 2007, Mathieu Desnoyers wrote:

> @@ -1566,12 +1565,13 @@ redo:
>  		object[c->offset]) != object))
>  			goto redo;
>  
> -	put_cpu();
> +	local_exit(flags);
>  	if (unlikely((gfpflags & __GFP_ZERO)))
>  		memset(object, 0, c->objsize);
>  
>  	return object;
>  slow:
> +	local_exit(flags);

Here we can be rescheduled to another processors.

>  	return __slab_alloc(s, gfpflags, node, addr, c)

c may point to the wrong processor.
