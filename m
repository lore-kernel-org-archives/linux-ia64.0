From: Andreas Schwab <schwab@suse.de>
Date: Sun, 22 Feb 2004 16:52:58 +0000
Subject: Re: Oops in pdflush
Message-Id: <je1xonhx91.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> writes:

> +#define UNW_DEBUG 6
>  #ifdef UNW_DEBUG
>    static unsigned int unw_debug_level =3D UNW_DEBUG;
>  #  ifdef CONFIG_KDB
>  #    include <linux/kdb.h>
> -#    define UNW_DEBUG_ON(n)	(unw_debug_level >=3D n && !KDB_IS_RUNNING())
> +#    define UNW_DEBUG_ON(n)	(unw_debug_level >=3D n && KDB_IS_RUNNING())
>  #    define UNW_DPRINT(n, ...)	if (UNW_DEBUG_ON(n)) kdb_printf(__VA_ARGS=
__)
>  #  else	/* !CONFIG_KDB */
>  #    define UNW_DEBUG_ON(n)	unw_debug_level >=3D n

This does not fit to the current sources even with the kdb patch applied.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
