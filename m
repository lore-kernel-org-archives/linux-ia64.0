From: Andreas Schwab <schwab@suse.de>
Date: Tue, 01 Mar 2005 23:51:45 +0000
Subject: Re: efibootmgr fixes for EFI 1.10
Message-Id: <je4qfuvsa6.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1109719371.12409.81.camel@tdi>
In-Reply-To: <1109719371.12409.81.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Alex Williamson <alex.williamson@hp.com> writes:

> @@ -215,8 +217,9 @@
>  			boot->var_data.Data;
>  		if (!efichar_char_strcmp(opts.label,
>  					 load_option->description)) {
> -			fprintf(stderr, "** Warning ** : Boot%04x has same label %s\n",
> -			       boot->num,
> +			snprintf(name, 9, "%s", boot->name->d_name);
> +			fprintf(stderr, "** Warning ** : %s has same label %s\n",
> +			       name,

What's wrong with using boot->name->d_name directly?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
