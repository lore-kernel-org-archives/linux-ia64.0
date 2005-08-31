From: Andreas Schwab <schwab@suse.de>
Date: Wed, 31 Aug 2005 16:33:11 +0000
Subject: Re: 2.6.13 does not boot on Eiger
Message-Id: <jefysq9id4.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <jefysr9gc7.fsf@sykes.suse.de>
In-Reply-To: <jefysr9gc7.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

> If you can boot a working kernel, salinfod will also
> extract the logs and drop them in /var/log/salinfo.
> There's a decoded/ directory, which is basically the
> same output as "errdump",

They all say: "UNCORRECTED PROCESSOR ERROR: Cache Check".  I don't know
what is needed from the files to make this useful.

>> > P.S.  What is your firmware "acpiconfig" mode? My eiger is
>> > in "default" mode,
>>=20
>> Likewise.
>
> Type "acpiconfig" at the EFI shell prompt.

"Likewise" was actually referring to "default".

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
