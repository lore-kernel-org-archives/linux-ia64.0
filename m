From: Andreas Schwab <schwab@suse.de>
Date: Wed, 01 Nov 2006 13:33:41 +0000
Subject: Re: cross-compiling ia64 kernels?
Message-Id: <jeu01jcmve.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Len Brown <len.brown@intel.com> writes:

> built it, but it bombed out in the glibc:
>
> $ sh demo-ia64.sh
> ....
>
> /home/lenb/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-4.1.0-glibc-2.=
3.6/build-glibc/nscd/cache.o: In function `cache_add':
> cache.c:(.text+0xf22): undefined reference to `__sync_bool_compare_and_sw=
ap_si'
> cache.c:(.text+0xfe2): undefined reference to `__sync_fetch_and_add_si'
> collect2: ld returned 1 exit status

glibc 2.3.6 is about a year old and predates gcc 4.1.0 by 3 months. You
should really use a more recent glibc.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
