From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Wed, 05 Sep 2007 13:03:44 +0000
Subject: Re: [PATCH] slub - Use local_t protection
Message-Id: <20070905130344.GA11880@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827203913.GA7416@Krystal> <Pine.LNX.4.64.0708271401070.6435@schroedinger.engr.sgi.com> <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com> <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com> <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com> <20070904200429.GD8157@Krystal> <Pine.LNX.4.64.0709041344040.6376@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0709041344040.6376@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

* Christoph Lameter (clameter@sgi.com) wrote:
> On Tue, 4 Sep 2007, Mathieu Desnoyers wrote:
> 
> > @@ -1566,12 +1565,13 @@ redo:
> >  		object[c->offset]) != object))
> >  			goto redo;
> >  
> > -	put_cpu();
> > +	local_exit(flags);
> >  	if (unlikely((gfpflags & __GFP_ZERO)))
> >  		memset(object, 0, c->objsize);
> >  
> >  	return object;
> >  slow:
> > +	local_exit(flags);
> 
> Here we can be rescheduled to another processors.
> 
> >  	return __slab_alloc(s, gfpflags, node, addr, c)
> 
> c may point to the wrong processor.

Good point. the current CPU is not updated at the beginning of the
slow path.

I'll post the updated patchset. Comments are welcome, especially about
the naming scheme which is currently awkward.

Mathieu

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
