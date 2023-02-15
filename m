From: Mark Rutland <mark.rutland@arm.com>
Date: Wed, 15 Feb 2023 13:09:21 +0000
Subject: Re: [PATCH v2 04/24] arm64/cpu: Mark cpu_die() __noreturn
Message-Id: <Y+zZgZIP7RPIgyQf@FVFF77S0Q05N>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <e47fc487980d5330e6059ac6e16416bec88cda0e.1676358308.git.jpoimboe@kernel.org>
 <14274f04-2991-95bd-c29b-07e86e8755c1@linaro.org>
In-Reply-To: <14274f04-2991-95bd-c29b-07e86e8755c1@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Philippe =?utf-8?Q?Mathieu-Daud=C3=A9?= <philmd@linaro.org>
Cc: Josh Poimboeuf <jpoimboe@kernel.org>, linux-kernel@vger.kernel.org, jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

On Tue, Feb 14, 2023 at 09:13:08AM +0100, Philippe Mathieu-Daud=C3=A9 wrote:
> On 14/2/23 08:05, Josh Poimboeuf wrote:
> > cpu_die() doesn't return.  Annotate it as such.  By extension this also
> > makes arch_cpu_idle_dead() noreturn.
> >=20
> > Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
> > ---
> >   arch/arm64/include/asm/smp.h | 2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/arch/arm64/include/asm/smp.h b/arch/arm64/include/asm/smp.h
> > index fc55f5a57a06..5733a31bab08 100644
> > --- a/arch/arm64/include/asm/smp.h
> > +++ b/arch/arm64/include/asm/smp.h
> > @@ -100,7 +100,7 @@ static inline void arch_send_wakeup_ipi_mask(const =
struct cpumask *mask)
> >   extern int __cpu_disable(void);
> >   extern void __cpu_die(unsigned int cpu);
> > -extern void cpu_die(void);
> > +extern void __noreturn cpu_die(void);
> >   extern void cpu_die_early(void);
>=20
> Shouldn't cpu_operations::cpu_die() be declared noreturn first?

The cpu_die() function ends with a BUG(), and so does not return, even if a
cpu_operations::cpu_die() function that it calls erroneously returned.

We *could* mark cpu_operations::cpu_die() as noreturn, but I'd prefer that =
we
did not so that the compiler doesn't optimize away the BUG() which is there=
 to
catch such erroneous returns.

That said, could we please add __noreturn to the implementation of cpu_die(=
) in
arch/arm64/kernel/smp.c? i.e. the fixup below.

With that fixup:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Mark.

---->8----
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index ffc5d76cf695..a98a76f7c1c6 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -361,7 +361,7 @@ void __cpu_die(unsigned int cpu)
  * Called from the idle thread for the CPU which has been shutdown.
  *
  */
-void cpu_die(void)
+void __noreturn cpu_die(void)
 {
        unsigned int cpu =3D smp_processor_id();
        const struct cpu_operations *ops =3D get_cpu_ops(cpu);
