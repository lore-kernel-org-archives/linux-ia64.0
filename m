From: Andreas Schwab <schwab@suse.de>
Date: Wed, 05 Dec 2007 23:43:50 +0000
Subject: Re: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <je63zcogg9.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 06 Dec 2007 00:06:14 +0100
> Andreas Schwab <schwab@suse.de> wrote:
>
>> akpm@linux-foundation.org writes:
>>=20
>> > diff -puN arch/ia64/Makefile~ia64-dont-assume-that-unwcheckpy-is-execu=
table arch/ia64/Makefile
>> > --- a/arch/ia64/Makefile~ia64-dont-assume-that-unwcheckpy-is-executable
>> > +++ a/arch/ia64/Makefile
>> > @@ -77,7 +77,7 @@ vmlinux.gz: vmlinux
>> >  	$(Q)$(MAKE) $(build)=3D$(boot) $@
>> > =20
>> >  unwcheck: vmlinux
>> > -	-$(Q)READELF=3D$(READELF) $(srctree)/arch/ia64/scripts/unwcheck.py $<
>> > +	-$(Q)READELF=3D$(READELF) $(CONFIG_SHELL) $(srctree)/arch/ia64/scrip=
ts/unwcheck.py $<
>>=20
>> unwcheck.py is not a shell script.
>>=20
>
> Oh well, whatever.  Please treat this as a bug report.
>
> ie: someone please fix it.

s/$(CONFIG_SHELL)/python/

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
