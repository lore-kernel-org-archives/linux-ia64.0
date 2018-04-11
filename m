From: James Hogan <jhogan@kernel.org>
Date: Wed, 11 Apr 2018 09:54:00 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <20180411095359.GB21429@saruman>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="i9LlY+UWpKt15+FH"
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de>
 <20180410224805.GA21429@saruman>
 <CAK8P3a0-_u7_FCj-nH0izBv4ub6krm1uA32bwi2jtBzXJePcnQ@mail.gmail.com>
In-Reply-To: <CAK8P3a0-_u7_FCj-nH0izBv4ub6krm1uA32bwi2jtBzXJePcnQ@mail.gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, Paul Burton <paul.burton@mips.com>, Maciej Rozycki <macro@mips.com>, linux-arch <linux-arch@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Vineet Gupta <vgupta@synopsys.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, linux-sparse@vger.kernel.org


--i9LlY+UWpKt15+FH
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 11, 2018 at 09:30:56AM +0200, Arnd Bergmann wrote:
> On Wed, Apr 11, 2018 at 12:48 AM, James Hogan <jhogan@kernel.org> wrote:
> > Before I forward port those patches to add .insn for MIPS, is that sort
> > of approach (an arch specific asm/compiler-gcc.h to allow MIPS to
> > override barrier_before_unreachable()) an acceptable fix?
>=20
> That sounds fine to me. However, I would suggest making that
> asm/compiler.h instead of asm/compiler-gcc.h, so we can also
> use the same file to include workarounds for clang if needed.

Yes, though there are a few asm/compiler.h's already, and the alpha one
includes linux/compiler.h before undefining inline, so seems to have its
own specific purpose...

Cheers
James

--i9LlY+UWpKt15+FH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd80NauSabkiESfLYbAtpk944dnoFAlrN2zcACgkQbAtpk944
dnq4xQ//W/rBEEvKM2KXaxuW0aYIu5tRiVtFhDs8mABCrU7S1CieiW/jwb/hvMpi
y8FpHCqjEIAaLlZT/yv+05QHtPiT8I5+3EcJJmUMpXxXGAAZV1V9IZ3gCM3U9B0G
NoNYHD5kxjf+JX/+47P8hcG5dREp2TmUYrIZ8USYbXkc/jcCCrJfNra/I2OLY9lQ
sw5V67uUE+0CE83n2yGrFLmb2Nh9tIIPo7DTvS7ZmBV0mc2ltU8wwPbkKtpfqEOq
YSF3+2AvJrt9TWpudwuxIp7wnhNWAdOGPiSyDTSdYzK02US8cC1l3KHMswzIbhNK
YCrVHl7U0fa1wx2ka6cbNepnxRUd9lfX64Cs5SsjomgDiItcJJNqkSWijwETm/wh
ZWJids6oj6KYdNDwasNr096sv9S+3+IuVwLVcVtSyN9UHfkfJGAeLubT5JJYG9QH
OR4I0Gdcy2/aH9o+vvvmQFyrNa4yBPNHyl6EsToI8aa+gWqg1wcRROABBxcdElgn
mMBLQ9kruLIp8M6ucVTtowe9u7OzP92lCH1pQhh3yD6rgwUUAeNarxRg2Pim8OiL
B+4S/GODXOUXZyaku7wbaDf4IL3nhArScsspzepnyo//ZOhz69beRfDExDT2gTJk
k7YWsQxMpdhQJpi+XBhDPAHGx+lq4mIK01pMgtp0IGoh59aTTsE=
=OyoV
-----END PGP SIGNATURE-----

--i9LlY+UWpKt15+FH--
