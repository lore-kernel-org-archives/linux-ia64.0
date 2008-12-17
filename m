From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Wed, 17 Dec 2008 00:01:55 +0000
Subject: Re: local_add_return
Message-Id: <20081217000155.GA28174@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.1.10.0812150823370.18692@gandalf.stny.rr.com> <200812161703.00697.rusty@rustcorp.com.au> <20081215.231314.92267481.davem@davemloft.net> <200812170908.05423.rusty@rustcorp.com.au>
In-Reply-To: <200812170908.05423.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, Christoph Lameter <christoph@lameter.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Martin Bligh <mbligh@google.com>

* Rusty Russell (rusty@rustcorp.com.au) wrote:
> On Tuesday 16 December 2008 17:43:14 David Miller wrote:
> > Here ya go:
> 
> Very interesting.  There's a little noise there (that first local_inc of 243
> is wrong), but the picture is clear: trivalue is the best implementation for
> sparc64.
> 
> Note: trivalue uses 3 values, so instead of hitting random values across 8MB
> it's across 24MB, and despite the resulting cache damage it's 15% faster.  The
> cpu_local_inc test is a single value, so no cache effects: it shows trivalue
> to be 3 to 3.5 times faster in the cache-hot case.
> 
> This sucks, because it really does mean that there's no one-size-fits-all
> implementation of local_t.  There's also no platform yet where atomic_long_t
> is the right choice; and that's the default!
> 

This problem could be fixed by introducing a local_count_t, which maps
to either local_t or to a trivalue, along with read accessors which sums
the trivalues.

I think we have two different use-cases here :

- local_t is useful as-is for things such as a tracer, which need to
  modify an element of data atomically wrt local interrupts. The
  atomic_long_t, in this case, is the correct fallback.
- local_count_t could be used for fast counters. It could be a
  requirement to only use it from thread/softirq/irq context (never NMI
  or exception) so we are sure the trivalue approach will not lead to
  corruption. local_count_t could use either local_t or trivalue
  depending on which is the fastest on a given architecture.

Mathieu


> Any chance of an IA64 or s390 run?  You can normalize if you like, since
> it's only to compare the different approaches.
> 
> Cheers,
> Rusty.
> 
> Benchmarks for local_t variants
> 
> (This patch also fixes the x86 cpu_local_* macros, which are obviously
> unused).
> 
> I chose a large array (1M longs) for the inc/add/add_return tests so
> the trivalue case would show some cache pressure.
> 
> The cpu_local_inc case is always cache-hot, so it's not comparable to
> the others.
> 
> Time in ns per iteration (brackets is with CONFIG_PREEMPT=y):
> 
> 		inc	add	add_return	cpu_local_inc	read
> x86-32: 2.13 Ghz Core Duo 2
> atomic_long	118	118	115		17		17
> irqsave/rest	77	78	77		23		16
> trivalue	45	45	127		3(6)		21
> local_t		36	36	36		1(5)		17
> 
> x86-64: 2.6 GHz Dual-Core AMD Opteron 2218
> atomic_long	55	60	-		6		19
> irqsave/rest	54	54	-		11		19
> trivalue	47	47	-		5		28
> local_t		47	46	-		1		19
> 
> PPC64: 2.7 GHz PPC970MP [normalized]
> atomic_long	18	18	20		3(4)		8
> irqsave/rest	10(4)	5(4)	4		8(9)		10(9)
> trivalue	9	9	2		1(3)		10
> local_t		18	18	18		3(4)		8
> 
> Sparc64: UltraSPARC-IIIi
> atomic_long	243	222	-		37		169
> irqsave/rest	205	205	-		25		169
> trivalue	193	193	-		11		221
> local_t		221	221	-		37		169
> 
> Sparc64: Niagara-2
> atomic_long	207	206	-		72		160
> irqsave/rest	228	228	-		78		160
> trivalue:	172	172	-		20		222
> local_t		206	207	-		73		160
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  arch/x86/include/asm/local.h |   20 +--
>  init/main.c                  |  223 +++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 233 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/x86/include/asm/local.h b/arch/x86/include/asm/local.h
> --- a/arch/x86/include/asm/local.h
> +++ b/arch/x86/include/asm/local.h
> @@ -220,16 +220,16 @@ static inline long local_sub_return(long
>  	preempt_enable();		\
>  })					\
>  
> -#define cpu_local_read(l)    cpu_local_wrap_v(local_read(&__get_cpu_var((l))))
> -#define cpu_local_set(l, i)  cpu_local_wrap(local_set(&__get_cpu_var((l)), (i)))
> -#define cpu_local_inc(l)     cpu_local_wrap(local_inc(&__get_cpu_var((l))))
> -#define cpu_local_dec(l)     cpu_local_wrap(local_dec(&__get_cpu_var((l))))
> -#define cpu_local_add(i, l)  cpu_local_wrap(local_add((i), &__get_cpu_var((l))))
> -#define cpu_local_sub(i, l)  cpu_local_wrap(local_sub((i), &__get_cpu_var((l))))
> +#define cpu_local_read(l)    cpu_local_wrap_v(local_read(&__get_cpu_var(l)))
> +#define cpu_local_set(l, i)  cpu_local_wrap(local_set(&__get_cpu_var(l), (i)))
> +#define cpu_local_inc(l)     cpu_local_wrap(local_inc(&__get_cpu_var(l)))
> +#define cpu_local_dec(l)     cpu_local_wrap(local_dec(&__get_cpu_var(l)))
> +#define cpu_local_add(i, l)  cpu_local_wrap(local_add((i), &__get_cpu_var(l)))
> +#define cpu_local_sub(i, l)  cpu_local_wrap(local_sub((i), &__get_cpu_var(l)))
>  
> -#define __cpu_local_inc(l)	cpu_local_inc((l))
> -#define __cpu_local_dec(l)	cpu_local_dec((l))
> -#define __cpu_local_add(i, l)	cpu_local_add((i), (l))
> -#define __cpu_local_sub(i, l)	cpu_local_sub((i), (l))
> +#define __cpu_local_inc(l)	cpu_local_inc(l)
> +#define __cpu_local_dec(l)	cpu_local_dec(l)
> +#define __cpu_local_add(i, l)	cpu_local_add((i), l)
> +#define __cpu_local_sub(i, l)	cpu_local_sub((i), l)
>  
>  #endif /* _ASM_X86_LOCAL_H */
> diff --git a/init/main.c b/init/main.c
> --- a/init/main.c
> +++ b/init/main.c
> @@ -534,6 +534,225 @@ void __init __weak thread_info_cache_ini
>  {
>  }
>  
> +/* There are three obvious ways to implement local_t on an arch which
> + * can't do single-instruction inc/dec etc.
> + * 1) atomic_long
> + * 2) irq_save/irq_restore
> + * 3) multiple counters.
> + *
> + * This does a very rough benchmark on each one.
> + */
> +struct local1 {
> +	atomic_long_t v;
> +};
> +struct local2 {
> +	unsigned long v;
> +};
> +struct local3 {
> +	unsigned long v[3];
> +};
> +
> +/* Enough to put some pressure on the caches. */
> +#define NUM_LOCAL_TEST (1024*1024)
> +#define NUM_LOCAL_RUNS (NUM_LOCAL_TEST*32)
> +/* This will make it jump around looking random */
> +#define STRIDE 514001
> +
> +static void *test_local_variants_mem;
> +
> +static void init_test_local_variants(void)
> +{
> +	unsigned long size;
> +	size = max(sizeof(struct local1),
> +		   max(sizeof(struct local2),
> +		       max(sizeof(struct local3), sizeof(local_t))))
> +		* NUM_LOCAL_TEST;
> +	/* Assume this works in early boot. */
> +	test_local_variants_mem = alloc_bootmem_nopanic(size);
> +
> +	if (!test_local_variants_mem) {
> +		printk("test_local_variants: failed to allocate %lu bytes\n",
> +		       size);
> +		return;
> +	}
> +}
> +
> +static void print_result(const char *str,
> +			 struct timespec start, struct timespec end)
> +{
> +	s64 diff;
> +
> +	diff = ktime_to_ns(ktime_sub(timespec_to_ktime(end), timespec_to_ktime(start)));
> +	printk("%s=%lli/%lli ",
> +	       str, diff, diff/NUM_LOCAL_RUNS);
> +}
> +
> +static unsigned int warm_local_test_cache(const void *mem, size_t len)
> +{
> +	unsigned int i, total = 0;
> +	for (i = 0; i < len; i++)
> +		total += ((char *)mem)[i];
> +	return total;
> +}
> +
> +#define TEST_LOOP(expr)				\
> +	n = 0;					\
> +	getnstimeofday(&start);			\
> +	for (i = 0; i < NUM_LOCAL_RUNS; i++) {	\
> +		expr;				\
> +		n += STRIDE;			\
> +		n %= NUM_LOCAL_TEST;		\
> +	}					\
> +	getnstimeofday(&end);
> +
> +/* This doesn't test cache effects at all */
> +#define NUM_PERCPU_VARS		16
> +DEFINE_PER_CPU(struct local1[NUM_PERCPU_VARS], local1_test);
> +DEFINE_PER_CPU(struct local2[NUM_PERCPU_VARS], local2_test);
> +DEFINE_PER_CPU(struct local3[NUM_PERCPU_VARS], local3_test);
> +DEFINE_PER_CPU(local_t[NUM_PERCPU_VARS], local4_test);
> +
> +static void test_local_variants(void)
> +{
> +	struct timespec start, end;
> +	unsigned int i, n;
> +	unsigned long total, warm_total = 0;
> +	struct local1 *l1;
> +	struct local2 *l2;
> +	struct local3 *l3;
> +	local_t *l4;
> +
> +	if (!test_local_variants_mem)
> +		return;
> +
> +	printk("Running local_t variant benchmarks\n");
> +	l1 = test_local_variants_mem;
> +	l2 = test_local_variants_mem;
> +	l3 = test_local_variants_mem;
> +	l4 = test_local_variants_mem;
> +
> +	printk("atomic_long: ");
> +	memset(l1, 0, sizeof(*l1)*NUM_LOCAL_TEST);
> +	TEST_LOOP(atomic_long_inc(&l1[n].v));
> +	print_result("local_inc", start, end);
> +
> +	warm_total += warm_local_test_cache(l1, sizeof(*l1)*NUM_LOCAL_TEST);
> +	TEST_LOOP(atomic_long_add(1234, &l1[n].v));
> +	print_result("local_add", start, end);
> +
> +	warm_total += warm_local_test_cache(l1, sizeof(*l1)*NUM_LOCAL_TEST);
> +	TEST_LOOP(atomic_long_inc(&__get_cpu_var(local1_test)[n%NUM_PERCPU_VARS].v));
> +	print_result("cpu_local_inc", start, end);
> +
> +	warm_total += warm_local_test_cache(l1, sizeof(*l1)*NUM_LOCAL_TEST);
> +	total = 0;
> +	TEST_LOOP(total += atomic_long_read(&l1[n].v));
> +	print_result("local_read", start, end);
> +
> +	warm_total += warm_local_test_cache(l1, sizeof(*l1)*NUM_LOCAL_TEST);
> +	TEST_LOOP(total += atomic_long_add_return(7, &l1[n].v));
> +	print_result("local_add_return", start, end);
> +
> +	printk("(total was %lu)\n", total);
> +
> +	printk("irqsave/restore: ");
> +	memset(l2, 0, sizeof(*l2)*NUM_LOCAL_TEST);
> +	TEST_LOOP(unsigned long flags;
> +		  local_irq_save(flags);
> +		  l2[n].v++;
> +		  local_irq_restore(flags));
> +	print_result("local_inc", start, end);
> +
> +	warm_total += warm_local_test_cache(l2, sizeof(*l2)*NUM_LOCAL_TEST);
> +	TEST_LOOP(unsigned long flags;
> +		  local_irq_save(flags);
> +		  l2[n].v += 1234;
> +		  local_irq_restore(flags));
> +	print_result("local_add", start, end);
> +
> +	warm_total += warm_local_test_cache(l2, sizeof(*l2)*NUM_LOCAL_TEST);
> +	TEST_LOOP(unsigned long flags;
> +		  local_irq_save(flags);
> +		  __get_cpu_var(local2_test)[n%NUM_PERCPU_VARS].v++;
> +		  local_irq_restore(flags));
> +	print_result("cpu_local_inc", start, end);
> +
> +	warm_total += warm_local_test_cache(l2, sizeof(*l2)*NUM_LOCAL_TEST);
> +	total = 0;
> +	TEST_LOOP(total += l2[n].v);
> +	print_result("local_read", start, end);
> +
> +	warm_total += warm_local_test_cache(l1, sizeof(*l1)*NUM_LOCAL_TEST);
> +	TEST_LOOP(unsigned long flags;
> +		  local_irq_save(flags);
> +		  l2[n].v += 7;
> +		  total += l2[n].v;
> +		  local_irq_restore(flags));
> +	print_result("local_add_return", start, end);
> +	printk("(total was %lu)\n", total);
> +
> +	printk("trivalue: ");
> +	memset(l3, 0, sizeof(*l3)*NUM_LOCAL_TEST);
> +	TEST_LOOP(unsigned int idx
> +			= !(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK)) +
> +			!(preempt_count() & HARDIRQ_MASK);
> +		  l3[n].v[idx]++);
> +	print_result("local_inc", start, end);
> +
> +	warm_total += warm_local_test_cache(l3, sizeof(*l3)*NUM_LOCAL_TEST);
> +	TEST_LOOP(unsigned int idx
> +			= !(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK)) +
> +			!(preempt_count() & HARDIRQ_MASK);
> +		  l3[n].v[idx] += 1234);
> +	print_result("local_add", start, end);
> +
> +	warm_total += warm_local_test_cache(l3, sizeof(*l3)*NUM_LOCAL_TEST);
> +	TEST_LOOP(unsigned int idx
> +			= !(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK)) +
> +			!(preempt_count() & HARDIRQ_MASK);
> +		  get_cpu_var(local3_test)[n%NUM_PERCPU_VARS].v[idx]++;
> +		  put_cpu_var());
> +	print_result("cpu_local_inc", start, end);
> +
> +	warm_total += warm_local_test_cache(l3, sizeof(*l3)*NUM_LOCAL_TEST);
> +	total = 0;
> +	TEST_LOOP(total += l3[n].v[0] + l3[n].v[1] + l3[n].v[2]);
> +	print_result("local_read", start, end);
> +
> +	warm_total += warm_local_test_cache(l1, sizeof(*l1)*NUM_LOCAL_TEST);
> +	TEST_LOOP(unsigned long flags;
> +		  local_irq_save(flags);
> +		  l3[n].v[0] += 7;
> +		  total += l3[n].v[0] + l3[n].v[1] + l3[n].v[2];
> +		  local_irq_restore(flags));
> +	print_result("local_add_return", start, end);
> +
> +	printk("(total was %lu)\n", total);
> +
> +	printk("local_t: ");
> +	memset(l4, 0, sizeof(*l4)*NUM_LOCAL_TEST);
> +	TEST_LOOP(local_inc(&l4[n]));
> +	print_result("local_inc", start, end);
> +
> +	warm_total += warm_local_test_cache(l4, sizeof(*l4)*NUM_LOCAL_TEST);
> +	TEST_LOOP(local_add(1234, &l4[n]));
> +	print_result("local_add", start, end);
> +
> +	warm_total += warm_local_test_cache(l4, sizeof(*l4)*NUM_LOCAL_TEST);
> +	TEST_LOOP(cpu_local_inc(local4_test[n%NUM_PERCPU_VARS]));
> +	print_result("cpu_local_inc", start, end);
> +
> +	warm_total += warm_local_test_cache(l4, sizeof(*l4)*NUM_LOCAL_TEST);
> +	total = 0;
> +	TEST_LOOP(total += local_read(&l4[n]));
> +	print_result("local_read", start, end);
> +
> +	warm_total += warm_local_test_cache(l1, sizeof(*l1)*NUM_LOCAL_TEST);
> +	TEST_LOOP(total += local_add_return(7, &l1[n].v));
> +	print_result("local_add_return", start, end);
> +	printk("(total was %lu, warm_total %lu)\n", total, warm_total);
> +}
> +
>  asmlinkage void __init start_kernel(void)
>  {
>  	char * command_line;
> @@ -630,6 +849,8 @@ asmlinkage void __init start_kernel(void
>  	 */
>  	locking_selftest();
>  
> +	init_test_local_variants();
> +
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (initrd_start && !initrd_below_start_ok &&
>  	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
> @@ -687,6 +908,8 @@ asmlinkage void __init start_kernel(void
>  	acpi_early_init(); /* before LAPIC and SMP init */
>  
>  	ftrace_init();
> +
> +	test_local_variants();
>  
>  	/* Do the rest non-__init'ed, we're now alive */
>  	rest_init();

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
