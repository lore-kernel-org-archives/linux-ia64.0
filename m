From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Wed, 21 Nov 2018 19:00:10 +0000
Subject: Re: [PATCH v2 16/15] syscall_get_arch: add "struct task_struct *" argument
Message-Id: <20181121190009.GA10301@altlinux.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
List-Id: <linux-ia64.vger.kernel.org>
References: <20181107042751.3b519062@akathisia>
 <CALCETrV1v-DPRfDRwiH=xn29bxWxiHdZtAH1nw=dsmDtnT0YGQ@mail.gmail.com>
 <20181120001128.GA11300@altlinux.org>
 <20181121004422.GA29053@altlinux.org>
 <20181121184004.jro532jopnbmru2m@pburton-laptop>
In-Reply-To: <20181121184004.jro532jopnbmru2m@pburton-laptop>
To: Paul Burton <paul.burton@mips.com>
Cc: Andy Lutomirski <luto@kernel.org>, Eric Paris <eparis@redhat.com>, Paul Moore <paul@paul-moore.com>, Elvira Khabirova <lineprinter@altlinux.org>, Eugene Syromyatnikov <esyr@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-audit@redhat.com, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.o


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Paul,

On Wed, Nov 21, 2018 at 06:40:06PM +0000, Paul Burton wrote:
> Hi Dmitry,
>=20
> On Wed, Nov 21, 2018 at 03:44:22AM +0300, Dmitry V. Levin wrote:
> > This argument is required to extend the generic ptrace API
> > with PTRACE_GET_SYSCALL_INFO request: syscall_get_arch() is going to be
> > called from ptrace_request() along with other syscall_get_* functions
> > with a tracee as their argument.
> >=20
> > This change partially reverts commit 5e937a9ae913 ("syscall_get_arch:
> > remove useless function arguments").
> >=20
> >%
> >=20
> > diff --git a/arch/mips/include/asm/syscall.h b/arch/mips/include/asm/sy=
scall.h
> > index 0170602a1e4e..52b633f20abd 100644
> > --- a/arch/mips/include/asm/syscall.h
> > +++ b/arch/mips/include/asm/syscall.h
> > @@ -73,7 +73,7 @@ static inline unsigned long mips_get_syscall_arg(unsi=
gned long *arg,
> >  #ifdef CONFIG_64BIT
> >  	case 4: case 5: case 6: case 7:
> >  #ifdef CONFIG_MIPS32_O32
> > -		if (test_thread_flag(TIF_32BIT_REGS))
> > +		if (test_ti_thread_flag(task_thread_info(task), TIF_32BIT_REGS))
> >  			return get_user(*arg, (int *)usp + n);
> >  		else
> >  #endif
>=20
> This ought to be test_tsk_thread_flag(task, TIF_32BIT_REGS) instead of
> open-coding test_tsk_thread_flag.

This will be corrected, thanks for letting me know.

> More fundamentally though, this change doesn't seem to be (directly)
> related to the change you describe in the commit message - it's not
> syscall_get_arch being modified here. I suspect this should be a
> separate commit, or if not please explain in the commit message why this
> change is included.

Good point, this is a fix that should not have been included into this comm=
it.
The bug was found while preparing the syscall_get_arch change, and this
hunk just slipped in.  I'll send it as a separate commit.

> Compounding the lack of clarity is the fact that I only received this
> patch, not the whole series, so I can't view the change in the context
> of the rest of the series.
>=20
> > @@ -140,14 +140,14 @@ extern const unsigned long sys_call_table[];
> >  extern const unsigned long sys32_call_table[];
> >  extern const unsigned long sysn32_call_table[];
> > =20
> > -static inline int syscall_get_arch(void)
> > +static inline int syscall_get_arch(struct task_struct *task)
> >  {
> >  	int arch =3D AUDIT_ARCH_MIPS;
> >  #ifdef CONFIG_64BIT
> > -	if (!test_thread_flag(TIF_32BIT_REGS)) {
> > +	if (!test_ti_thread_flag(task_thread_info(task), TIF_32BIT_REGS)) {
> >  		arch |=3D __AUDIT_ARCH_64BIT;
> >  		/* N32 sets only TIF_32BIT_ADDR */
> > -		if (test_thread_flag(TIF_32BIT_ADDR))
> > +		if (test_ti_thread_flag(task_thread_info(task), TIF_32BIT_ADDR))
> >  			arch |=3D __AUDIT_ARCH_CONVENTION_MIPS64_N32;
> >  	}
> >  #endif
>=20
> This does seem like the described change, but there are 2 more instances
> of open-coding test_tsk_thread_flag which ought to be cleaned up.

This will be cleaned up, thanks for letting me know.


--=20
ldv

--BXVAT5kNtrzKuDFl
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJb9as5AAoJEAVFT+BVnCUIMwEQAK/kFQPbOlZh1qWyjUznc+u9
B2U2LJjbOkYfYnr9QwrWQpg/TjvxgUN35dpVOsv/im0GsqFEY2Rzc7tI70ENrEeU
q6QXC13R/sIvKRDMEzNyZRaXhHsc0KAhq7LolCTAxeK8t/Fv5Zz9j3TJFWQ9DwDz
NVDn67xoF2I1U1grwrJFrOrmPTr3B0jQKGekfMwoj+efsP09U8U6mOAbJ4WF3DW4
zJXbMREy/PNA4g/usZzp0ckgLrceTql83DdogIPaCytZrDNteKgXgGUW/MPCty1C
4hWReW1CumdXr9ULf2cbiwrvBnG+Sa9lN2QTeaIH892Ln9sToAfRX2D1YMH5mfcP
FDHeP0jpZgLqXmiiAVVXXV1Al2DnAR3ohZlmyRyT06thhiVWptG/KjrgcRM3G9hZ
vVzvRv8kBaj+6WzpW+hS97lHeqbg3s0AMBTy8rWaLyGJMUUAUQ0jOcN3faZbegI6
L7AsGZiHRxjLIwuXIRh93/rPrmyWbY9zli4BDaufbvYRiJK3TYyEBeQB95X6mmiA
DuUIR5hOaMafxWExgknG1NRuBnrhmpkokyvEAClQyg7zvWflHMOd9trQJXFfSKI8
A3e+hTMBRs9HXfqdXe9QUj6f7pQIpRh3xSXKyePA1kFj6DuJMe+dLKQGQEeCE1bf
pqgRdoGWKyibD9iR9c1/
=hLdr
-----END PGP SIGNATURE-----

--BXVAT5kNtrzKuDFl--
