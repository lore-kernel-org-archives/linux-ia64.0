From: Jakub Jelinek <jakub@redhat.com>
Date: Thu, 18 Jan 2018 19:19:39 +0000
Subject: Re: [PATCH] ia64: Rewrite atomic_add and atomic_sub
Message-Id: <20180118191939.GH2063@tucnak>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180118183953.29257-1-willy@infradead.org>
In-Reply-To: <20180118183953.29257-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 18, 2018 at 11:02:43AM -0800, Luck, Tony wrote:
> On Thu, Jan 18, 2018 at 10:39:53AM -0800, Matthew Wilcox wrote:
> > +	int __i = (i);							\
> > +	static const int __ia64_atomic_p = __ia64_atomic_const(i);	\
> > +	__ia64_atomic_p ? ia64_fetch_and_add(__i, &(v)->counter) :	\
> > +				ia64_atomic_add(__i, v);		\
> 
> "static"?  Is that safe? What if we are executing
> atomic_add on multiple cpus at the same time?

In C static vars must be initialized only at compile time, each expansion
of the macro has a different scope and different static variable.
If they wouldn't be optimized away, each of them would waste 4 bytes
in .rodata section, but the point of the patch is do this only when
optimizing and let the compiler optimize away those variables.
As the static variables need the initializers to be evaluated early in
the compiler FE, it means __builtin_constant_p is resolved away right after
folding the argument, compared to automatic variables where when optimizing
__builtin_constant_p folding is deferred until inlining and lots of other
optimizations are performed.

What this means is if you do:
atomic_add_return (4, something);
it will be optimized into ia64_fetch_and_add, but if you e.g. do:
int x = 4;
atomic_add_return (x, something);
it will not, similarly:
static inline void
foo (int x, ...)
{
  atomic_add_return (x, something);
}
and call
foo (4, ...);
then it will be again just ia64_atomic_add.

	Jakub
