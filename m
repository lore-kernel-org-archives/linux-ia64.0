From: Waiman Long <longman@redhat.com>
Date: Thu, 14 Feb 2019 15:22:18 +0000
Subject: Re: [PATCH-tip 00/22] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <9860a0c2-1f24-a00f-fdea-89e55a07c571@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
 <CAHk-=wjfyrFBjifzmgMVrkrvEePEPaBTDq7D=f2i5kD2E=SqRQ@mail.gmail.com>
 <d7476dfb-1653-747b-b865-5597ba5fc1c1@redhat.com>
 <20190214132352.wm26r5g632swp34n@linux-r8p5>
In-Reply-To: <20190214132352.wm26r5g632swp34n@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

On 02/14/2019 08:23 AM, Davidlohr Bueso wrote:
> On Fri, 08 Feb 2019, Waiman Long wrote:
>> I am planning to run more performance test and post the data sometimes
>> next week. Davidlohr is also going to run some of his rwsem performance
>> test on this patchset.
>
> So I ran this series on a 40-core IB 2 socket with various worklods in
> mmtests. Below are some of the interesting ones; full numbers and curves
> at https://linux-scalability.org/rwsem-reader-spinner/
>
> All workloads are with increasing number of threads.
>
> -- pagefault timings: pft is an artificial pf benchmark (thus reader
> stress).
> metric is faults/cpu and faults/sec
>                                       v5.0-rc6                 v5.0-rc6
>                                                                    dirty
> Hmean     faults/cpu-1    624224.9815 (   0.00%)   618847.5201 *  -0.86%*
> Hmean     faults/cpu-4    539550.3509 (   0.00%)   547407.5738 *   1.46%*
> Hmean     faults/cpu-7    401470.3461 (   0.00%)   381157.9830 *  -5.06%*
> Hmean     faults/cpu-12   267617.0353 (   0.00%)   271098.5441 *   1.30%*
> Hmean     faults/cpu-21   176194.4641 (   0.00%)   175151.3256 *  -0.59%*
> Hmean     faults/cpu-30   119927.3862 (   0.00%)   120610.1348 *   0.57%*
> Hmean     faults/cpu-40    91203.6820 (   0.00%)    91832.7489 *   0.69%*
> Hmean     faults/sec-1    623292.3467 (   0.00%)   617992.0795 *  -0.85%*
> Hmean     faults/sec-4   2113364.6898 (   0.00%)  2140254.8238 *   1.27%*
> Hmean     faults/sec-7   2557378.4385 (   0.00%)  2450945.7060 *  -4.16%*
> Hmean     faults/sec-12  2696509.8975 (   0.00%)  2747968.9819 *   1.91%*
> Hmean     faults/sec-21  2902892.5639 (   0.00%)  2905923.3881 *   0.10%*
> Hmean     faults/sec-30  2956696.5793 (   0.00%)  2990583.5147 *   1.15%*
> Hmean     faults/sec-40  3422806.4806 (   0.00%)  3352970.3082 *  -2.04%*
> Stddev    faults/cpu-1      2949.5159 (   0.00%)     2802.2712 (   4.99%)
> Stddev    faults/cpu-4     24165.9454 (   0.00%)    15841.1232 (  34.45%)
> Stddev    faults/cpu-7     20914.8351 (   0.00%)    22744.3294 (  -8.75%)
> Stddev    faults/cpu-12    11274.3490 (   0.00%)    14733.3152 ( -30.68%)
> Stddev    faults/cpu-21     2500.1950 (   0.00%)     2200.9518 (  11.97%)
> Stddev    faults/cpu-30     1599.5346 (   0.00%)     1414.0339 (  11.60%)
> Stddev    faults/cpu-40     1473.0181 (   0.00%)     3004.1209 (-103.94%)
> Stddev    faults/sec-1      2655.2581 (   0.00%)     2405.1625 (   9.42%)
> Stddev    faults/sec-4     84042.7234 (   0.00%)    57996.7158 (  30.99%)
> Stddev    faults/sec-7    123656.7901 (   0.00%)   135591.1087 (  -9.65%)
> Stddev    faults/sec-12    97135.6091 (   0.00%)   127054.4926 ( -30.80%)
> Stddev    faults/sec-21    69564.6264 (   0.00%)    65922.6381 (   5.24%)
> Stddev    faults/sec-30    51524.4027 (   0.00%)    56109.4159 (  -8.90%)
> Stddev    faults/sec-40   101927.5280 (   0.00%)   160117.0093 ( -57.09%)
>
> With the exception of the hicup at 7 threads, things are pretty much in
> the noise region for both metrics.
>
> -- git checkout
>
> First metric is total runtime for runs with incremental threads.
>
>           v5.0-rc6    v5.0-rc6
>                          dirty
> User         218.95      219.07
> System       149.29      146.82
> Elapsed     1574.10     1427.08
>
> In this case there's a non trivial improvement (11%) in overall
> elapsed time.
>
> -- reaim (which is always succeptible to rwsem changes for both
> mmap_sem and
> i_mmap)
>                                     v5.0-rc6               v5.0-rc6
>                                                                dirty
> Hmean     compute-1         6674.01 (   0.00%)     6544.28 *  -1.94%*
> Hmean     compute-21       85294.91 (   0.00%)    85524.20 *   0.27%*
> Hmean     compute-41      149674.70 (   0.00%)   149494.58 *  -0.12%*
> Hmean     compute-61      177721.15 (   0.00%)   170507.38 *  -4.06%*
> Hmean     compute-81      181531.07 (   0.00%)   180463.24 *  -0.59%*
> Hmean     compute-101     189024.09 (   0.00%)   187288.86 *  -0.92%*
> Hmean     compute-121     200673.24 (   0.00%)   195327.65 *  -2.66%*
> Hmean     compute-141     213082.29 (   0.00%)   211290.80 *  -0.84%*
> Hmean     compute-161     207764.06 (   0.00%)   204626.68 *  -1.51%*
>
> The 'compute' workload overall takes a small hit.
>
> Hmean     new_dbase-1         60.48 (   0.00%)       60.63 *   0.25%*
> Hmean     new_dbase-21      6590.49 (   0.00%)     6671.81 *   1.23%*
> Hmean     new_dbase-41     14202.91 (   0.00%)    14470.59 *   1.88%*
> Hmean     new_dbase-61     21207.24 (   0.00%)    21067.40 *  -0.66%*
> Hmean     new_dbase-81     25542.40 (   0.00%)    25542.40 *   0.00%*
> Hmean     new_dbase-101    30165.28 (   0.00%)    30046.21 *  -0.39%*
> Hmean     new_dbase-121    33638.33 (   0.00%)    33219.90 *  -1.24%*
> Hmean     new_dbase-141    36723.70 (   0.00%)    37504.52 *   2.13%*
> Hmean     new_dbase-161    42242.51 (   0.00%)    42117.34 *  -0.30%*
> Hmean     shared-1            76.54 (   0.00%)       76.09 *  -0.59%*
> Hmean     shared-21         7535.51 (   0.00%)     5518.75 * -26.76%*
> Hmean     shared-41        17207.81 (   0.00%)    14651.94 * -14.85%*
> Hmean     shared-61        20716.98 (   0.00%)    18667.52 *  -9.89%*
> Hmean     shared-81        27603.83 (   0.00%)    23466.45 * -14.99%*
> Hmean     shared-101       26008.59 (   0.00%)    29536.96 *  13.57%*
> Hmean     shared-121       28354.76 (   0.00%)    43139.39 *  52.14%*
> Hmean     shared-141       38509.25 (   0.00%)    41619.35 *   8.08%*
> Hmean     shared-161       40496.07 (   0.00%)    44303.46 *   9.40%*
>
> Overall there is a small hit (in the noise level but consistent
> throughout
> many workloads), except git-checkout which does quite well.
>
> Thanks,
> Davidlohr

Thanks for running the patch through your performance tests.

Cheers,
Longman
