From: Mark Goodwin <markgw@sgi.com>
Date: Thu, 13 Jan 2005 01:42:44 +0000
Subject: Re: fixing 2.6.10 UP builds
Message-Id: <Pine.LNX.4.61.0501131236030.6506@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Wed, 12 Jan 2005, Jesse Barnes wrote:

> On Wednesday, January 12, 2005 4:34 pm, Luck, Tony wrote:
>>>> arch/ia64/sn/kernel/sn2/sn_hwperf.c: In function `sn_hwperf_op_cpu':
>>>> arch/ia64/sn/kernel/sn2/sn_hwperf.c:360: warning: implicit declaration
>>>> of function `smp_call_function_single'
>>>
>>> Looks like we need a !CONFIG_SMP version of smp_call_function_single.
>>> include/linux/smp.h has a non-smp version of smp_call_function
>>> that just returns 0, should smp_call_function_single do the same thing?
>>
>> That would make the warning go away, but it isn't obvious to me
>> that you'd end up with code that did the right thing.  Looking
>> at the bigger picture, just what is sn_hwperf_op_cpu() supposed
>> to do in the UP case?
>
> It's supposed to make a SAL call for the CPU specified in the op_arg.  Seems
> like smp_call_function_single should make the specified call unconditionally
> on CPU 0?

that's fine for the call to smp_call_function_single() in sn_hwperf_op_cpu(),
but may not be desirable elsewhere, I don't know. All the other calls to
smp_call_function_single seem to be already conditional on CONFIG_SMP,
so perhaps just do the same for sn_hwperf_op_cpu.

-- Mark
