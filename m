From: Matthew Wilcox <willy@infradead.org>
Date: Thu, 18 Jan 2018 19:19:04 +0000
Subject: Re: [PATCH] ia64: Rewrite atomic_add and atomic_sub
Message-Id: <20180118191904.GC23800@bombadil.infradead.org>
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
> 
> Do all those "static" declarations resolve to separate
> memory locations per call site?

My understanding is that they get optimised away again by the front end
and so they never resolve into an actual memory location.  Here's my test
program that demonstrates:

1. Calling it with a complex "i" does indeed result in i only being
evaluated once.
2. It manages to successfully turn each call into the right version.

I compiled it on my laptop with gcc -W -Wall -O2 -c test.c -o test.o
and examined the results of objdump -Sr.

typedef struct { unsigned long counter; } atomic_t;
long ia64_fetch_and_add(long i, unsigned long *v);
long ia64_atomic_add(long i, atomic_t *a);

#define __ia64_atomic_const(i)  __builtin_constant_p(i) ?               \
                ((i) = 1 || (i) = 4 || (i) = 8 || (i) = 16 ||       \
                 (i) = -1 || (i) = -4 || (i) = -8 || (i) = -16) : 0

#define atomic_add_return(i, v)                                         \
({                                                                      \
        int __i = (i);                                                  \
        static const int __ia64_atomic_p = __ia64_atomic_const(i);      \
        __ia64_atomic_p ? ia64_fetch_and_add(__i, &(v)->counter) :      \
                                ia64_atomic_add(__i, v);                \
})

int main(int argc, char **argv)
{
	atomic_t a;
	atomic_add_return(1, &a);
	atomic_add_return(3, &a);
	atomic_add_return(argc++, &a);
	atomic_add_return(argc++, &a);
	atomic_add_return(4, &a);
}

