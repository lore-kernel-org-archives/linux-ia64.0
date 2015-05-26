From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 26 May 2015 20:45:04 +0000
Subject: Re: [PATCH 06/16] ia64: fix up obsolete cpu function usage.
Message-Id: <CA+8MBbJiQeP3SHoqM+D0v6q5oOvaDgwr7RnFNJZ=TS8oPpoa5A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425296150-4722-1-git-send-email-rusty@rustcorp.com.au>
	<1425296150-4722-6-git-send-email-rusty@rustcorp.com.au>
In-Reply-To: <1425296150-4722-6-git-send-email-rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Mon, Mar 2, 2015 at 3:35 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Thanks to spatch, then a sweep for for_each_cpu_mask => for_each_cpu.
>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

I'm seeing a bunch of warnings building the ia64 tree:

arch/ia64/kernel/smpboot.c:437: warning: passing argument 2 of
'cpumask_set_cpu' discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:478: warning: passing argument 2 of
'cpumask_test_cpu' discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:484: warning: passing argument 2 of
'cpumask_test_cpu' discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:544: warning: passing argument 2 of
'cpumask_set_cpu' discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:568: warning: passing argument 2 of
'cpumask_set_cpu' discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:676: warning: passing argument 2 of
'cpumask_clear_cpu' discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:747: warning: passing argument 2 of
'cpumask_test_cpu' discards qualifiers from pointer target type

which track back to these lines from this commit:

$ git show 5d2068da8d339e4dff8f9b9a1246e6a79e2949d8 | grep cpu_callin_map
- cpu_set(cpuid, cpu_callin_map);
+ cpumask_set_cpu(cpuid, &cpu_callin_map);
- if (cpu_isset(cpu, cpu_callin_map))
+ if (cpumask_test_cpu(cpu, &cpu_callin_map))
- if (!cpu_isset(cpu, cpu_callin_map)) {
+ if (!cpumask_test_cpu(cpu, &cpu_callin_map)) {
- cpu_set(0, cpu_callin_map);
+ cpumask_set_cpu(0, &cpu_callin_map);
- cpu_set(smp_processor_id(), cpu_callin_map);
+ cpumask_set_cpu(smp_processor_id(), &cpu_callin_map);
- cpu_clear(cpu, cpu_callin_map);
+ cpumask_clear_cpu(cpu, &cpu_callin_map);
- if (cpu_isset(cpu, cpu_callin_map))
+ if (cpumask_test_cpu(cpu, &cpu_callin_map))

The problem being that cpu_callin_map is declared volatile,
which matched the arg type in the declarations for
cpu_set() and cpu_clear() ... but doesn't match the new
fangled cpumask_set_cpu() etc.

Now the new functions do go on to call set_bit()
etc. ... which *do* expect a volatile second argument.

Should cpumask_set_cpu() and friends specify a volatile argument???

-Tony
