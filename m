From: Andreas Schwab <schwab@suse.de>
Date: Thu, 23 Jun 2005 22:11:25 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <je7jgkhgfm.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Russ Anderson <rja@sgi.com> writes:

> @@ -394,6 +395,8 @@
>  	pal_min_state_area_t *pmsa;
>  	struct ia64_psr *psr1, *psr2;
>  	ia64_fptr_t *mca_hdlr_bh =3D (ia64_fptr_t*)mca_handler_bhhook;
> +	extern char ia64_ivt[];
> +	extern void *interrupt_pnr;

Can this be moved to some header?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
