From: Yury Norov <yury.norov@gmail.com>
Date: Tue, 01 Feb 2022 18:30:22 +0000
Subject: Re: [PATCH] kernel/cpu.c: fix init_cpu_online
Message-Id: <CAAH8bW_y4+edCY9viJayfmfvAFuJ1A7jqwDQCL++_Qv2Bo5Kew@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220131014648.941629-1-yury.norov@gmail.com> <YffF3e+uUIDVO7hm@FVFF7649Q05P>
In-Reply-To: <YffF3e+uUIDVO7hm@FVFF7649Q05P>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vincent Donnefort <vincent.donnefort@arm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Valentin Schneider <valentin.schneider@arm.com>, Ingo Molnar <mingo@kernel.org>, YueHaibing <yuehaibing@huawei.com>, Yuan ZhaoXiong <yuanzhaoxiong@baidu.com>, Randy Dunlap <rdunlap@infradead.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 31, 2022 at 3:20 AM Vincent Donnefort
<vincent.donnefort@arm.com> wrote:
>
> Hi Yury,
>
> On Sun, Jan 30, 2022 at 05:46:48PM -0800, Yury Norov wrote:
> > cpu_online_mask has an associate counter of online cpus, which must be
> > initialized in init_cpu_online().
> >
> > Fixes: 0c09ab96fc82010 (cpu/hotplug: Cache number of online CPUs)
>
> Aren't the increments/decrements from set_cpu_online() enough?

It will only count cpus onlined by this function . Those onlined before will
never be counted.

> I guess we could argue that this isn't a private function and the
> num_online_cpus should be updated here. But unless I missed something,
> init_cpu_online() is only called in ia64 arch, in the !SMP case.

Yes, this looks weird. In !SMP case this counter and function are not needed
at all, and this is  the only case when the function is used.

In SMP case, things work just because the cpu_online_mask and
num_online_cpus are both initialized to 0. If this is the intentional behavior,
and it would be like this forever, then the init_cpu_online() must be dropped,
otherwise it needs to be fixed. Isn't?

> Is this the problem you're trying to tackle?

It was initially a part of a bigger series that added 3 more counters like this:

https://lkml.org/lkml/2021/12/18/253

But now it's postponed.

> If not, I'm not sure that warrants a "Fixes:" tag

The patch 0c09ab96fc82010 adds the counter but does not initialize it properly.
For me it sounds like a fix.

> > Signed-off-by: Yury Norov <yury.norov@gmail.com>
> > ---
> >  kernel/cpu.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/kernel/cpu.c b/kernel/cpu.c
> > index 407a2568f35e..cd7605204d4d 100644
> > --- a/kernel/cpu.c
> > +++ b/kernel/cpu.c
> > @@ -2616,6 +2616,7 @@ void init_cpu_possible(const struct cpumask *src)
> >  void init_cpu_online(const struct cpumask *src)
> >  {
> >       cpumask_copy(&__cpu_online_mask, src);
> > +     atomic_set(&__num_online_cpus, cpumask_weight(cpu_online_mask));
> >  }
> >
> >  void set_cpu_online(unsigned int cpu, bool online)
> > --
> > 2.30.2
> >
