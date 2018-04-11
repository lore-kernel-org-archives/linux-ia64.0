From: James Hogan <jhogan@kernel.org>
Date: Wed, 11 Apr 2018 10:19:27 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <20180411101927.GA29949@saruman>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de>
 <20180410224805.GA21429@saruman>
 <CAK8P3a0-_u7_FCj-nH0izBv4ub6krm1uA32bwi2jtBzXJePcnQ@mail.gmail.com>
 <20180411095359.GB21429@saruman>
 <CAK8P3a2_ihWCuUvDz_SVA1TMomkO1d7pa6e2bOQkZcEVP+Ff-A@mail.gmail.com>
In-Reply-To: <CAK8P3a2_ihWCuUvDz_SVA1TMomkO1d7pa6e2bOQkZcEVP+Ff-A@mail.gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, Paul Burton <paul.burton@mips.com>, Maciej Rozycki <macro@mips.com>, linux-arch <linux-arch@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Vineet Gupta <vgupta@synopsys.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, linux-sparse@vger.kernel.org, linux-alpha@vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 11, 2018 at 12:08:51PM +0200, Arnd Bergmann wrote:
> On Wed, Apr 11, 2018 at 11:54 AM, James Hogan <jhogan@kernel.org> wrote:
> > On Wed, Apr 11, 2018 at 09:30:56AM +0200, Arnd Bergmann wrote:
> >> On Wed, Apr 11, 2018 at 12:48 AM, James Hogan <jhogan@kernel.org> wrot=
e:
> >> > Before I forward port those patches to add .insn for MIPS, is that s=
ort
> >> > of approach (an arch specific asm/compiler-gcc.h to allow MIPS to
> >> > override barrier_before_unreachable()) an acceptable fix?
> >>
> >> That sounds fine to me. However, I would suggest making that
> >> asm/compiler.h instead of asm/compiler-gcc.h, so we can also
> >> use the same file to include workarounds for clang if needed.
> >
> > Yes, though there are a few asm/compiler.h's already, and the alpha one
> > includes linux/compiler.h before undefining inline, so seems to have its
> > own specific purpose...
>=20
> Interesting. For the other ones, including asm/compiler.h from linux/comp=
iler.h
> seems appropriate though, so the question would be what to do with the
> alpha case. I think we can simply remove that header file and replace
> it with this patch:
>=20
> diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
> index b2022885ced8..5502404f54cd 100644
> --- a/arch/alpha/Kconfig
> +++ b/arch/alpha/Kconfig
> @@ -81,6 +81,9 @@ config PGTABLE_LEVELS
>         int
>         default 3
>=20
> +config OPTIMIZE_INLINING
> +       def_bool y
> +
>  source "init/Kconfig"
>  source "kernel/Kconfig.freezer"
>=20
> which should have the same effect.

Hmm yes, and I suppose alpha would need ARCH_SUPPORTS_OPTIMIZED_INLINING
too. I'll give it a try.

Cheers
James

--AhhlLboLdkugWU4S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd80NauSabkiESfLYbAtpk944dnoFAlrN4S4ACgkQbAtpk944
dnoXAxAAsHoTKQyZDTU/r/kGekG1pEfs0mc8yWLe9iRHbilM5u/YOGj6o0cqkkv8
7YEH7lfapOs5Fi3+t+kXezfDtIijHFiwlgWJXnqe8z1ZRoovmIw4BYZvZGRMUjrf
syPK/fOx2ZkQ+L3Zv02UdXfITV2rvWaK58olIs9Qnl7mwkUViA7cK3tzRtOhyKG1
mEi58L9dOR8SZIGLJjUvBHpMDKyXsTb1AD4chQ5I3TCs8eCOq5FCOb6b0sa9P2x5
UOpiJ1IMORXgML+FQ2o8lakjkk7b+jmj+NP4dgtydiMqlwZTcXydXW7POh7HMzko
G6R2+QQiDl8Wf8fqTokXskTT3v2/vM+TwufVJlxWTqirUmuDN2l8AICSXO0Y3PR4
aTJPIamIA/izYNBo0ukletJRH89TdHdzG5zSNypm6tYu5Vil69A20NnRHHQOYAk6
Wt1BZUZp9/hz1bcxMCT9jnB10xDO/cXOIODWiwWQQbgx/upbK6oFOHh8YKxgSnXQ
HFPAwV5tFNT7jVabbj43IQ2lIg+LlwLxL96VghSWxfmOrbUbZhBq7owHp3wwPYiF
2TAD34tz6oWpgismxcQMV3dnIILncctozEKBleRA63TxYh8gCSH/QsvTi+3zZI2M
8jnlOr4EkFefBAHhOAjZQE14qDig9/rW8FgnJTAhLteAF8f5wY0=
=HfmN
-----END PGP SIGNATURE-----

--AhhlLboLdkugWU4S--
