From: Andreas Schwab <schwab@suse.de>
Date: Mon, 31 May 2004 15:42:38 +0000
Subject: Re: IA64_GENERIC vs. NUMA/DISCONTIG/VIRTUAL_MEM_MAP
Message-Id: <jellj8d2mp.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040531044843.GA25705@dannf.org>
In-Reply-To: <20040531044843.GA25705@dannf.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

dann frazier <dannf@hp.com> writes:

> I suspected that initially, but this is what confused me:
> $ make oldconfig > /dev/null && grep IA64_GENERIC .config && grep CONFIG_=
NUMA .config
> CONFIG_IA64_GENERIC=3Dy
> # CONFIG_NUMA is not set

Can't reproduce here.  Whenever I select IA64_GENERIC I also get NUMA=3Dy,
even if I start with a .config that has NUMA=3Dn.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
