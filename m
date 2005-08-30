From: Andreas Schwab <schwab@suse.de>
Date: Tue, 30 Aug 2005 20:45:18 +0000
Subject: Re: execute sn2 early console setup only on sn2s
Message-Id: <jell2j9msh.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050830203446.GA7680@sgi.com>
In-Reply-To: <20050830203446.GA7680@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Greg Edwards <edwardsg@sgi.com> writes:

> Index: git-linus/arch/ia64/kernel/setup.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- git-linus.orig/arch/ia64/kernel/setup.c	20=
05-08-30 15:13:11.399460142 -0500
> +++ git-linus/arch/ia64/kernel/setup.c	2005-08-30 15:15:53.959188707 -0500
> @@ -288,7 +288,7 @@ early_console_setup (char *cmdline)
>  	int earlycons =3D 0;
> =20
>  #ifdef CONFIG_SERIAL_SGI_L1_CONSOLE
> -	{
> +	if (ia64_platform_is("sn2")) {
>  		extern int sn_serial_console_early_setup(void);
>  		if (!sn_serial_console_early_setup())
>  			earlycons++;

The first thing sn_serial_console_early_setup does is to check for sn2.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
