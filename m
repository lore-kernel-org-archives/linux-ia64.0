From: Andreas Schwab <schwab@suse.de>
Date: Tue, 27 Jul 2004 20:10:55 +0000
Subject: Re: [PATCH] Altix console mod
Message-Id: <jesmbd8b3k.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407271953.i6RJrAma119179@fsgi900.americas.sgi.com>
In-Reply-To: <200407271953.i6RJrAma119179@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Pat Gefre <pfg@sgi.com> writes:

> @@ -978,19 +981,21 @@
>   * ia64_sn_console_putb (what sal_puts_raw below actually does).
>   *
>   */
> -static void puts_raw_fixed(const char *s, int count)
> +
> +static void puts_raw_fixed(int (*puts_raw) (const char *s, int len), con=
st char *s, int count)
>  {
>  	const char *s1;
> -	struct sn_cons_port *port =3D &sal_console_port;
> =20
>  	/* Output '\r' before each '\n' */
>  	while ((s1 =3D memchr(s, '\n', count)) !=3D NULL) {
> -		port->sc_ops->sal_puts_raw(s, s1 - s);
> -		port->sc_ops->sal_puts_raw("\r\n", 2);
> +		if ( (*(s1 - 1) !=3D '\r') && (*(s1 + 1) !=3D '\r') ) {
> +			puts_raw(s, s1 - s);
> +			puts_raw("\r\n", 2);
> +		}

You have now broken output when a CR actually appears in the string.
What's wrong with unconditionally writing a CR before each LF?  That's
what every other console print function is doing.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
