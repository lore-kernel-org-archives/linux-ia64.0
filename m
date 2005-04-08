From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Apr 2005 23:49:11 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <16983.6263.400429.553064@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

With the attached test-program, I'm seeing these results on a 1.5GHz
Madison:

                measured time number of
                per call:     bundles:

                GCC v3.4                 GCC pre-v4.1
   generic:     8.696 ns      14          7.345 ns
    womack:     9.355 ns      10         10.017 ns
  popcount:     7.351 ns       8          6.676 ns
      arch:     9.357 ns       7          8.683 ns
  ia64_fls:     8.016 ns       4          8.011 ns
popcount64:     9.357 ns       8          9.349 ns

(GCC prior to v3.4 doesn't have the __builtin_popcount() so we'd need
 to fallback on asm in that case).

Given these results, I'm inclined to continue to use the
FP-normalization for 64-bit ia64_fls() and to use the (32-bit-only)
popcount-version for fls().

I should note that there are faster ways of doing fls() on ia64 but
they require lookup-tables and given that fls() isn't called all that
frequently, those table-lookups would likely result in cache misses.
Of course, if you know of a place in the kernel where fls() is used
very frequently, do let me know.

	--david

/*
 * Copyright (C) 2005 Grant Grundler (grundler at parisc-linux.org)
 *
 *  Copies code from:
 *  Copyright (C) 1998-2003 Hewlett-Packard Co
 *		David Mosberger-Tang <davidm@hpl.hp.com>
 *
 * testfls.c may be redistributed under GPL 2.0.
 */
#include <stdlib.h>
#include <stdio.h>

#include <sys/time.h>

#ifdef __INTEL_COMPILER
# include <ia64intrin.h>
# define ia64_getf_exp(x)	__getf_exp(x)
# define popcount(x)		_m64_popcnt(x)
# define popcount64(x)		_m64_popcnt(x)
#else
# define ia64_getf_exp(x)                                       \
({                                                              \
        long ia64_intri_res;                                    \
                                                                \
        asm ("getf.exp %0=%1" : "=r"(ia64_intri_res) : "f"(x)); \
                                                                \
        ia64_intri_res;                                         \
})
# define ia64_popcnt(x)						\
({								\
	unsigned long ia64_intri_res;				\
	asm ("popcnt %0=%1" : "=r" (ia64_intri_res) : "r" (x));	\
								\
	ia64_intri_res;						\
})
# define popcount(x)		__builtin_popcount(x)
# define popcount64(x)		ia64_popcnt(x)
#endif

static inline unsigned long
ia64_fls (unsigned long x)
{
        long double d = x;
        long exp;

        exp = ia64_getf_exp(d);
        return exp - 0xffff;
}

static inline int
arch_fls (int x)
{
	if (!x)
		return 0;
	return ia64_fls((unsigned int) x) + 1;
}

/*
 * fls: find last bit set.
 */
static __inline__ int generic_fls(int x)
{
	int r = 32;

	if (!x)
		return 0;
	if (!(x & 0xffff0000u)) {
		x <<= 16;
		r -= 16;
	}
	if (!(x & 0xff000000u)) {
		x <<= 8;
		r -= 8;
	}
	if (!(x & 0xf0000000u)) {
		x <<= 4;
		r -= 4;
	}
	if (!(x & 0xc0000000u)) {
		x <<= 2;
		r -= 2;
	}
	if (!(x & 0x80000000u)) {
		x <<= 1;
		r -= 1;
	}
	return r;
}

static __inline__ int womack_fls(int x)
{
	unsigned int t = x;
	int r = 1;

	if (!t)
		return 0;
	if (t & 0xffff0000u) {
		t >>= 16;
		r += 16;
	}
	if (t & 0xff00) {
		t >>= 8;
		r += 8;
	}
	if (t & 0xf0u) {
		t >>= 4;
		r += 4;
	}
	/*
	 * This is based on an article by Paul Womack posted to
	 * comp.arch on May 15, 2000.
	 *
	 * Last 4 bits are handled by a lookup table.  Each
	 * table-entry occupies only 2 bits, so we can encode the
	 * table in 16*2 = 32 bits.  The table value is constructed
	 * like this:
	 *
	 * 0000 = don't care (not possible)
	 * 0001 = 1
	 * 0010 = 2
	 * 0011 = 2
	 * 0100 = 3
	 * 0101 = 3
	 * 0110 = 3
	 * 0111 = 3
	 * 1000 = 4
	 * 1001 = 4
	 * 1010 = 4
	 * 1011 = 4
	 * 1100 = 4
	 * 1101 = 4
	 * 1110 = 4
	 * 1111 = 4
	 *
	 * to make it fit in 2 bits, we subtract 1 before encoding, so
	 * in binary:
	 *
	 *  = 0b11111111111111111010101001010000
	 *       3 3 3 3 3 3 3 3 2 2 2 2 1 1 0 0
	 * hex (thanks, bc!)
	 *  = 0xffffaa50
	 */
	return r + ((0xffffaa50u >> (2 * t)) & 0x3);
}

static __inline__ int
popcount_fls(int t)
{
	unsigned long x = t & 0xffffffffu;

	if (!x)
		return 0;
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	return popcount(x);
}

static __inline__ unsigned long
popcount_fls64(unsigned long x)
{
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	x |= x >> 32;
	return popcount64(x) - 1;
}

int testval[] = { -2, -1, 0, 6, 10 };

static inline void
check (int val)
{
	if (arch_fls(val) != generic_fls(val))
		printf ("arch_fls(%08x) %6d generic_fls(%08x) %6d\n",
			val, arch_fls(val), val, generic_fls(val));
	if (womack_fls(val) != generic_fls(val))
		printf ("arch_fls(%08x) %6d generic_fls(%08x) %6d\n",
			val, womack_fls(val), val, generic_fls(val));
	if (popcount_fls(val) != generic_fls(val))
		printf ("popcount_fls(%08x) %6d generic_fls(%08x) %6d\n",
			val, popcount_fls(val), val, generic_fls(val));
}

static inline void
check64 (unsigned long val)
{
	if (!val)
		return;

	if (popcount_fls64(val) != ia64_fls(val))
		printf ("popcount_fls64(%016lx) %6ld ia64_fls(%016lx) %6ld\n",
			val, popcount_fls64(val), val, ia64_fls(val));
}

static int
empty (int x)
{
	return 0;
}

static double
measure (const char *label, int (*func)(int), double offset)
{
	struct timeval start, stop;
	long i, count = 1000000;
	double t;

	while (1) {
		gettimeofday(&start, NULL);
		for (i = 0; i < count; ++i)
			(*func)(i | (i << 16));
		gettimeofday(&stop, NULL);

		t = ((stop.tv_sec + 1e-6*stop.tv_usec)
		     - (start.tv_sec + 1e-6*start.tv_usec));

		if (t >= 1.0)
			break;

		if (t <= 0.0)
			t = 1e-3;

		count = (1.1 / t) * count;
	}
	t = (t / count) * 1e9 - offset;

	printf ("%10s: %9.3f ns\n", label, t);
	return t;
}

static double
measure64 (const char *label, unsigned long (*func)(unsigned long),
	   double offset)
{
	struct timeval start, stop;
	long i, count = 1000000;
	double t;

	while (1) {
		gettimeofday(&start, NULL);
		for (i = 0; i < count; ++i)
			(*func)(i | (i << 16));
		gettimeofday(&stop, NULL);

		t = ((stop.tv_sec + 1e-6*stop.tv_usec)
		     - (start.tv_sec + 1e-6*start.tv_usec));

		if (t >= 1.0)
			break;

		if (t <= 0.0)
			t = 1e-3;

		count = (1.1 / t) * count;
	}
	t = (t / count) * 1e9 - offset;

	printf ("%10s: %9.3f ns\n", label, t);
	return t;
}

int
main (int argc, char **argv)
{
	double overhead;
	int j;

	for (j = 0; j < sizeof(testval)/sizeof(int); j++) {
		check(testval[j]);
		check64(testval[j]);
	}
	for (j = 0; j < 32; ++j) {
		check(1 << j);
		check((1 << j) - 1);
		check((1 << j) + 1);
	}
	for (j = 0; j < 64; ++j) {
		check(1UL << j);
		check((1UL << j) - 1);
		check((1UL << j) + 1);
	}

	printf ("done with correctness test\n");

	overhead = measure("overhead", empty, 0.0);
	measure("generic", generic_fls, overhead);
	measure("womack", womack_fls, overhead);
	measure("popcount", popcount_fls, overhead);
	measure("arch", arch_fls, overhead);
	measure64("ia64_fls", ia64_fls, overhead);
	measure64("popcount64", popcount_fls64, overhead);
	return 0;
}
