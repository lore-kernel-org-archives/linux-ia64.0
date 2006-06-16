From: Andi Kleen <ak@suse.de>
Date: Fri, 16 Jun 2006 14:54:15 +0000
Subject: Re: [discuss] Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <200606161654.15881.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606161317.19296.ak@suse.de> <44929CE6.4@sgi.com>
In-Reply-To: <44929CE6.4@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: discuss@x86-64.org
Cc: Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org


> I really don't see the benefit here. malloc already gets pages handed
> down from the kernel which are node local due to them being assigned at
> a first touch basis. I am not sure about glibc's malloc internals, but
> rather rely on a vgetcpu() call, all it really needs to do is to keep
> a thread local pool which will automatically get it's thing locally
> through first touch usage.

That would add too much overhead on small systems. It's better to be 
able to share the pools. vgetcpu allows that.
 
> > Basically it is just for extending the existing already used proven etc.
> > default local policy to sub pages. Also there might be other uses
> > of it too (like per CPU data), although I expect most use of that
> > in user space can be already done using TLS.
> 
> The thread libraries already have their own thread local area which
> should be allocated on the thread's own node if done right, which I
> assume it is.

- The heap for small allocations is shared (although this can be tuned) 
- When another thread does free() you need special handling to keep
the item in the correct free lists
This is one of the tricky bits in the new kernel NUMA slab allocator
too.

> > But cpusets already does this kind of, even though it has a quite
> > bad impact on fast paths.
> >  Also what happens if the affinity mask is modified later?
> > From the high semantics point it is also a little dubious to mesh
> > them together. My feeling is that as a heuristic it is probably
> > dubious.
> 
> If you migrate your app elsewhere, you should migrate the pages with it,
> or not expect things to run with the local effect.

That's too costly to do by default and you have no guarantee that it will amortize.
 
> I don't really see the point in solving something half way when it can
> be done better. Maybe the "serious" databases should open up and let us
> know what the problem is they are hitting.

I see no indication of anything better so far from you. You only offered
static configuration instead which while in some cases is better
doesn't work in the general case.
-Andi
