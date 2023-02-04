From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Sat, 04 Feb 2023 02:29:32 +0000
Subject: Re: [PATCH 05/22] csky/cpu: Make sure arch_cpu_idle_dead() doesn't return
Message-Id: <20230204022932.k24laszjs3v4bc3v@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1675461757.git.jpoimboe@kernel.org>
 <f860f3a1c1a53c437a99abc53e8f1a798aef6881.1675461757.git.jpoimboe@kernel.org>
 <CAJF2gTSKe3ve4_rsOYpmSBOyUSU5rpLHyijn9i2-i+WfLqxzYw@mail.gmail.com>
In-Reply-To: <CAJF2gTSKe3ve4_rsOYpmSBOyUSU5rpLHyijn9i2-i+WfLqxzYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guo Ren <guoren@kernel.org>
Cc: linux-kernel@vger.kernel.org, jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

On Sat, Feb 04, 2023 at 09:12:31AM +0800, Guo Ren wrote:
> On Sat, Feb 4, 2023 at 6:05 AM Josh Poimboeuf <jpoimboe@kernel.org> wrote:
> >
> > arch_cpu_idle_dead() doesn't return.  Make that more explicit with a
> > BUG().
> >
> > BUG() is preferable to unreachable() because BUG() is a more explicit
> > failure mode and avoids undefined behavior like falling off the edge of
> > the function into whatever code happens to be next.
> >
> > Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
> > ---
> >  arch/csky/kernel/smp.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/arch/csky/kernel/smp.c b/arch/csky/kernel/smp.c
> > index b45d1073307f..0ec20efaf5fd 100644
> > --- a/arch/csky/kernel/smp.c
> > +++ b/arch/csky/kernel/smp.c
> > @@ -317,5 +317,7 @@ void arch_cpu_idle_dead(void)
> >                 "jmpi   csky_start_secondary"
> >                 :
> >                 : "r" (secondary_stack));
> > +
> > +       BUG();
> Why not:
> diff --git a/kernel/sched/idle.c b/kernel/sched/idle.c
> index f26ab2675f7d..1d3bf903add2 100644
> --- a/kernel/sched/idle.c
> +++ b/kernel/sched/idle.c
> @@ -285,6 +285,7 @@ static void do_idle(void)
>                         tick_nohz_idle_stop_tick();
>                         cpuhp_report_idle_dead();
>                         arch_cpu_idle_dead();
> +                       BUG();

Without the BUG() in csky arch_cpu_idle_dead(), the compiler will warn
about arch_cpu_idle_dead() returning, because it's marked __noreturn but
doesn't clearly return (as far as the compiler knows).

And we want it marked __noreturn so we'll be more likely to catch such
bugs at build time.

And as a bonus we get better code generation and clearer code semantics
which helps both humans and tooling understand the intent of the code.

-- 
Josh
