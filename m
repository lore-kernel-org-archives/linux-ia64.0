From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 Jan 2005 00:34:53 +0000
Subject: RE: fixing 2.6.10 UP builds
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02B82B1A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> arch/ia64/sn/kernel/sn2/sn_hwperf.c: In function `sn_hwperf_op_cpu':
>> arch/ia64/sn/kernel/sn2/sn_hwperf.c:360: warning: implicit declaration of function `smp_call_function_single'
>
>Looks like we need a !CONFIG_SMP version of smp_call_function_single.  
>include/linux/smp.h has a non-smp version of smp_call_function 
>that just returns 0, should smp_call_function_single do the same thing?

That would make the warning go away, but it isn't obvious to me
that you'd end up with code that did the right thing.  Looking
at the bigger picture, just what is sn_hwperf_op_cpu() supposed
to do in the UP case?

-Tony
