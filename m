From: Andreas Schwab <schwab@suse.de>
Date: Sat, 19 Feb 2005 21:55:36 +0000
Subject: Re: [PATCH] Errenous use of memset and memcpy
Message-Id: <je4qg8b4fb.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1108848352.682.2.camel@boxen>
In-Reply-To: <1108848352.682.2.camel@boxen>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Alexander Nyberg <alexn@dsv.su.se> writes:

> I stumbled across this, looks weird. Presumable fix is:
>
> =3D=3D=3D arch/ia64/ia32/ia32_signal.c 1.35 vs edited =3D=3D> --- 1.35/ar=
ch/ia64/ia32/ia32_signal.c	2005-01-25 21:23:45 +01:00
> +++ edited/arch/ia64/ia32/ia32_signal.c	2005-02-12 13:12:25 +01:00
> @@ -460,10 +460,9 @@ __ia32_rt_sigsuspend (compat_sigset_t *s
>  	sigset_t oldset, set;
> =20
>  	scr->scratch_unat =3D 0;	/* avoid leaking kernel bits to user level */
> -	memset(&set, 0, sizeof(&set));
> +	memset(&set, 0, sizeof(sigset_t));
> =20
> -	if (memcpy(&set.sig, &sset->sig, sigsetsize))
> -		return -EFAULT;
> +	memcpy(&set.sig, &sset->sig, sigsetsize);

That should be copy_from_user, and the error checking needs to stay.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
