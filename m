From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Wed, 15 Feb 2023 19:45:38 +0000
Subject: Re: [PATCH v2 04/24] arm64/cpu: Mark cpu_die() __noreturn
Message-Id: <20230215194538.aiiris3uabnuvkkg@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <e47fc487980d5330e6059ac6e16416bec88cda0e.1676358308.git.jpoimboe@kernel.org>
 <14274f04-2991-95bd-c29b-07e86e8755c1@linaro.org>
 <Y+zZgZIP7RPIgyQf@FVFF77S0Q05N>
In-Reply-To: <Y+zZgZIP7RPIgyQf@FVFF77S0Q05N>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Mark Rutland <mark.rutland@arm.com>
Cc: Philippe =?utf-8?Q?Mathieu-Daud=C3=A9?= <philmd@linaro.org>, juri.lelli@redhat.com, dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, peterz@infradead.org, catalin.marinas@arm.com, dave.hansen@linux.intel.com, x86@kernel.org, jiaxun.yang@flygoat.com, linux-mips@vger.kernel.org, bsegall@google.com, jcmvbkbc@gmail.com, guoren@kernel.org, hpa@zytor.com, sparclinux@vger.kernel.org, kernel@xen0n.name, will@kernel.org, vschneid@redhat.com, f.fainelli@gmail.com, vincent.guittot@linaro.org, ysato@users.sourceforge.jp, chenhuacai@kernel.org, linux@armlinux.org.uk, linux-csky@vger.kernel.org, dietmar.eggemann@arm.com, mingo@redhat.com, bcm-kernel-feedback-list@broadcom.com, mgorman@suse.de, mattst88@gmail.com, linux-xtensa@linux-xtensa.org, paulmck@kernel.org, richard.henderson@linaro.org, npiggin@gmail.com, ink@jurassic.park.msu.ru, rostedt@goodmis.org, loongarch@lists.linux.dev, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, jgross@suse.com, chris@zankel.net, tsbogend@alpha.franken.de, bristot@redhat.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, bp@alien8.de, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

On Wed, Feb 15, 2023 at 01:09:21PM +0000, Mark Rutland wrote:
> On Tue, Feb 14, 2023 at 09:13:08AM +0100, Philippe Mathieu-Daud=C3=A9 wro=
te:
> > On 14/2/23 08:05, Josh Poimboeuf wrote:
> > > cpu_die() doesn't return.  Annotate it as such.  By extension this al=
so
> > > makes arch_cpu_idle_dead() noreturn.
> > >=20
> > > Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
> > > ---
> > >   arch/arm64/include/asm/smp.h | 2 +-
> > >   1 file changed, 1 insertion(+), 1 deletion(-)
> > >=20
> > > diff --git a/arch/arm64/include/asm/smp.h b/arch/arm64/include/asm/sm=
p.h
> > > index fc55f5a57a06..5733a31bab08 100644
> > > --- a/arch/arm64/include/asm/smp.h
> > > +++ b/arch/arm64/include/asm/smp.h
> > > @@ -100,7 +100,7 @@ static inline void arch_send_wakeup_ipi_mask(cons=
t struct cpumask *mask)
> > >   extern int __cpu_disable(void);
> > >   extern void __cpu_die(unsigned int cpu);
> > > -extern void cpu_die(void);
> > > +extern void __noreturn cpu_die(void);
> > >   extern void cpu_die_early(void);
> >=20
> > Shouldn't cpu_operations::cpu_die() be declared noreturn first?
>=20
> The cpu_die() function ends with a BUG(), and so does not return, even if=
 a
> cpu_operations::cpu_die() function that it calls erroneously returned.
>=20
> We *could* mark cpu_operations::cpu_die() as noreturn, but I'd prefer tha=
t we
> did not so that the compiler doesn't optimize away the BUG() which is the=
re to
> catch such erroneous returns.
>=20
> That said, could we please add __noreturn to the implementation of cpu_di=
e() in
> arch/arm64/kernel/smp.c? i.e. the fixup below.

Done.

> With that fixup:
>=20
> Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks!

--=20
Josh
