From: Andreas Schwab <schwab@suse.de>
Date: Wed, 02 Mar 2005 00:01:13 +0000
Subject: Re: efibootmgr fixes for EFI 1.10
Message-Id: <jey8d6ud9y.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1109719371.12409.81.camel@tdi>
In-Reply-To: <1109719371.12409.81.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Alex Williamson <alex.williamson@hp.com> writes:

>    Then you get something like this printed:
>
> ** Warning ** : BootFFFF-8be4df61-93ca-11d2-aa0d-00e098032b8c has same la=
bel Linux
>
> Seemed like too much information.  Thanks,

Then use %.8s.  Likewise for all other occurences of the same theme.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
