From: James Hogan <james.hogan@imgtec.com>
Date: Fri, 29 Apr 2016 22:04:37 +0000
Subject: Re: [PATCH] parisc,metag: Implement CONFIG_DEBUG_STACK_USAGE option
Message-Id: <20160429220437.GA15188@jhogan-linux.le.imgtec.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
List-Id: <linux-ia64.vger.kernel.org>
References: <20160319165410.GA31630@p100.box>
In-Reply-To: <20160319165410.GA31630@p100.box>
To: Helge Deller <deller@gmx.de>
Cc: linux-parisc@vger.kernel.org, James Bottomley <James.Bottomley@HansenPartnership.com>, John David Anglin <dave.anglin@bell.net>, linux-metag@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Helge,

On Sat, Mar 19, 2016 at 05:54:10PM +0100, Helge Deller wrote:
> On parisc and metag the stack grows upwards, so for those we need to
> scan the stack downwards in order to calculate how much stack a process
> has used.
>=20
> Tested on a 64bit parisc kernel.
>=20
> Signed-off-by: Helge Deller <deller@gmx.de>

Looks good, and works on metag too!

Tested-by: James Hogan <james.hogan@imgtec.com>
Acked-by: James Hogan <james.hogan@imgtec.com>

Cheers
James

>=20
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 084ed9f..71591f3 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2859,10 +2859,18 @@ static inline unsigned long stack_not_used(struct=
 task_struct *p)
>  	unsigned long *n =3D end_of_stack(p);
> =20
>  	do { 	/* Skip over canary */
> +# ifdef CONFIG_STACK_GROWSUP
> +		n--;
> +# else
>  		n++;
> +# endif
>  	} while (!*n);
> =20
> +# ifdef CONFIG_STACK_GROWSUP
> +	return (unsigned long)end_of_stack(p) - (unsigned long)n;
> +# else
>  	return (unsigned long)n - (unsigned long)end_of_stack(p);
> +# endif
>  }
>  #endif
>  extern void set_task_stack_end_magic(struct task_struct *tsk);
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index f28f7fa..901f96c 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -546,7 +546,7 @@ config DEBUG_KMEMLEAK_DEFAULT_OFF
> =20
>  config DEBUG_STACK_USAGE
>  	bool "Stack utilization instrumentation"
> -	depends on DEBUG_KERNEL && !IA64 && !PARISC && !METAG
> +	depends on DEBUG_KERNEL && !IA64
>  	help
>  	  Enables the display of the minimum amount of free stack which each
>  	  task has ever had available in the sysrq-T and sysrq-P debug output.

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXI9p1AAoJEGwLaZPeOHZ6uP8P/RAVw/RjjQYDy9ekRws4EbCd
XWDt8J8z6rhh7gHrgZBjwktamtp0TAYtX/j2Ipd0PIhmWPRjTl1QqPNxHEfiy7Wk
PPXmTedfjV9jh2uWqjWOV+8m9YeOn5J1kUcbtX4CWq0oIfYJHEBe3lVf7SVmV1PH
VTlPyQrcG++7J1T2H0aMW2+Rd/f7ssGtwync/aKawXAKki/XkKqfB6lnsttVZQuI
DixyywS8XCSKT0q9fCH2j1GDLAphca8rrk9svoxZhaw65aIhn9CH5f/phNBjymCe
/qXBSsvhiPxRYOjrH0Vktf2HINqDinyCrMpVx2sOCEfZSjXiYTnab9zqijBzbtmA
gZsicgI44rZAVrYinKCXSe71PJXvC7+zgo8QsH1597TNlbmHhBpha2Y1neYghO9i
NkTzbPQGnM+yY8KFb3Pazko7SxAsJXiAkWCTrbrqJiU4+p/4iSsPRBFf9sAbENcl
veHGrU0Zr4HMLarj3iircAiIZifVBNlsoktaw4BE8eypgZIjsG56SuBiUmTzAQ6n
6uPA+3wQAYcc53JnAP5gltyxb6b10EITwO+e7NguddfH3Uo2zbsRWa6TR3cArk0o
/xLjUuAprfASLr4zqEayvVcXrGNziRHklc+bw52ZzJStI82BIdSKgbTz0j+47yrl
ZxD3MIB/PgYiPrKjILlL
=FFAX
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
