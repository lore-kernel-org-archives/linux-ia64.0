From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 15 Jun 2006 12:22:40 +0000
Subject: Re: light weight counters: race free through local_t?
Message-Id: <44915110.2050100@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0606092212200.4875@schroedinger.engr.sgi.com> <449033B0.1020206@bull.net> <Pine.LNX.4.64.0606140928500.4030@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606140928500.4030@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:

> Could you do a clock cycle comparision of an 
> 
> atomic_inc(__get_per_cpu(var))
> (the fallback of local_t on ia64)
> 
> vs.
> 
> local_irq_save(flags)
> __get_per_cpu(var)++
> local_irq_restore(flags)
> (ZVC like implementation)
> 
> vs.
> 
> get_per_cpu(var)++
> put_cpu()
> (current light weight counters)

The only thing I have at hand is a small test for the 1st case:


#include <stdio.h>
#include <asm/atomic.h>
#define GET_ITC()                                               \
({                                                              \
        unsigned long ia64_intri_res;                           \
                                                                \
        asm volatile ("mov %0=ar.itc" : "=r"(ia64_intri_res));  \
        ia64_intri_res;                                         \
})

#define N       (1000 * 1000 * 100L)

atomic_t data;

main(int c, char *v[])
{
        unsigned long cycles;
        int i;

        cycles = GET_ITC();
        for (i = 0; i < N; i++)
                ia64_fetchadd4_rel(&data, 1);
        cycles = GET_ITC() - cycles;
        printf("%ld %d\n", cycles / N, atomic_read(&data));
}


It gives 11 clock cycles.
(The loop organizing instructions are "absorbed".)

"atomic_inc(__get_per_cpu(var))" compiles into:

	mov	rx = 0xffffffffffffxxxx	// &__get_per_cpu(var)
	;;
	fetchadd4.rel ry = [rx], 1

It _should_ take 11 clock cycles, too. (Assuming it is in L2.)

For the 2nd case:
With a bit of modification, I can measure what
"__get_per_cpu(var)++" costs: 7 or 10 clock cycles, depending on
if the chance to find the counter in L1 is 100% or 0%:


int data;

static inline void store(int *addr, int data){
        asm volatile ("st4 [%1] = %0" :: "r"(data), "r"(addr) : "memory");
}

static inline int load_nt1(int *addr)
{
        int tmp;
        asm volatile ("ld4.nt1 %0=[%1]" : "=r"(tmp) : "r" (addr));
        return tmp;
}

main(int c, char *v[])
{
        unsigned long cycles;
        int i, d;

        cycles = GET_ITC();
        for (i = 0; i < N; i++)
                // Avoid optimizing out the "st4"
                store(&data, data + 1);
        cycles = GET_ITC() - cycles;
        printf("%ld %d\n", cycles / N, data);
        cycles = GET_ITC();
        for (i = 0; i < N; i++){
                // Do not use L1
                d = load_nt1(&data);
                store(&data, d + 1);
        }
        cycles = GET_ITC() - cycles;
        printf("%ld %d\n", cycles / N, data);
}


"local_irq_save(flags)" compiles into:

	mov rx = psr ;;		// 13 clock cycles
	rsm 0x4000 ;;		// 5 clock cycles

"local_irq_restore(flags)" compiles into (at least):

	ssm 0x4000		// 5 clock cycles

For the 3dr case:
If CONFIG_PREEMPT, then you need to add 2 * 7 clock cycles
for inc_preempt_count() / dec_preempt_count() + some more
for preempt_check_resched().

My conclusion: let's stick to atomic counters.

Regards,

Zoltan
