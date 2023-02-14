From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Tue, 14 Feb 2023 18:28:31 +0000
Subject: Re: [PATCH v2 13/24] sh/cpu: Make sure play_dead() doesn't return
Message-Id: <20230214182831.7l73rzoeqjowbyly@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <d0c3ff5349adfe8fd227acc236ae2c278a05eb4c.1676358308.git.jpoimboe@kernel.org>
 <2575e5f7-b11a-020f-06ef-ba42301d7415@linaro.org>
In-Reply-To: <2575e5f7-b11a-020f-06ef-ba42301d7415@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Philippe =?utf-8?Q?Mathieu-Daud=C3=A9?= <philmd@linaro.org>
Cc: linux-kernel@vger.kernel.org, jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

On Tue, Feb 14, 2023 at 08:57:39AM +0100, Philippe Mathieu-Daud=C3=A9 wrote:
> On 14/2/23 08:05, Josh Poimboeuf wrote:
> > play_dead() doesn't return.  Make that more explicit with a BUG().
> >=20
> > BUG() is preferable to unreachable() because BUG() is a more explicit
> > failure mode and avoids undefined behavior like falling off the edge of
> > the function into whatever code happens to be next.
> >=20
> > Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
> > ---
> >   arch/sh/include/asm/smp-ops.h | 1 +
> >   1 file changed, 1 insertion(+)
> >=20
> > diff --git a/arch/sh/include/asm/smp-ops.h b/arch/sh/include/asm/smp-op=
s.h
> > index e27702130eb6..63866b1595a0 100644
> > --- a/arch/sh/include/asm/smp-ops.h
> > +++ b/arch/sh/include/asm/smp-ops.h
> > @@ -27,6 +27,7 @@ static inline void plat_smp_setup(void)
> >   static inline void play_dead(void)
> >   {
> >   	mp_ops->play_dead();
> > +	BUG();
> >   }
>=20
> Shouldn't we decorate plat_smp_ops::play_dead() as noreturn first?

I guess it really depends on how far we want to go down the __noreturn
rabbit hole.  To keep the patch set constrained yet still useful I
stopped when I got to a function pointer, as I think it still needs a
BUG() afterwards either way.

That said, there would still be benefits of adding __noreturn to
function pointers, I just wanted to keep the patch set down to a
manageable size ;-)

--=20
Josh
