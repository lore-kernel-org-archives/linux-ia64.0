From: Max Filippov <jcmvbkbc@gmail.com>
Date: Tue, 14 Feb 2023 19:48:41 +0000
Subject: Re: [PATCH v2 19/24] xtensa/cpu: Make sure cpu_die() doesn't return
Message-Id: <CAMo8BfLzV0Oe_i-QrMzE-BE028s6GNvOd827N5+tteELidjpvA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org> <cca346b5c87693499e630291d78fb0bf12c24290.1676358308.git.jpoimboe@kernel.org>
 <1b4afd82-83cb-0060-7cab-8e16d2e69ff9@linaro.org> <20230214182322.r5tyeowxzloiuh72@treble>
In-Reply-To: <20230214182322.r5tyeowxzloiuh72@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Josh Poimboeuf <jpoimboe@kernel.org>
Cc: =?UTF-8?Q?Philippe_Mathieu=2DDaud=C3=A9?= <philmd@linaro.org>, linux-kernel@vger.kernel.org, jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

On Tue, Feb 14, 2023 at 10:23 AM Josh Poimboeuf <jpoimboe@kernel.org> wrote:
> On Tue, Feb 14, 2023 at 08:55:32AM +0100, Philippe Mathieu-Daud=C3=A9 wro=
te:
> > Can you update the documentation along? Currently we have:
> >
> >   /*
> >    * Called from the idle thread for the CPU which has been shutdown.
> >    *
> >    * Note that we disable IRQs here, but do not re-enable them
> >    * before returning to the caller. This is also the behaviour
> >    * of the other hotplug-cpu capable cores, so presumably coming
> >    * out of idle fixes this.
> >    */
>
> void __ref cpu_die(void)
> {
>         idle_task_exit();
>         local_irq_disable();
>         __asm__ __volatile__(
>                         "       movi    a2, cpu_restart\n"
>                         "       jx      a2\n");
>
>         BUG();
> }
>
> Hm, not only is the comment wrong, but it seems to be branching to
> cpu_restart?  That doesn't seem right at all.

Perhaps the name is a bit misleading. The CPU that enters 'cpu_restart'
loops there until a call to 'boot_secondary' releases it, after which it go=
es
to '_startup'. So it is a restart, but not immediate.

--=20
Thanks.
-- Max
