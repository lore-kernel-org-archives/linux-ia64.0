From: Andreas Schwab <schwab@suse.de>
Date: Wed, 17 Jan 2007 21:36:19 +0000
Subject: Re: atomic_cmpxchg and 64-bit values
Message-Id: <je4pqps5d8.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070117144850.U8085@pkunk.americas.sgi.com>
In-Reply-To: <20070117144850.U8085@pkunk.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Brent Casavant <bcasavan@sgi.com> writes:

> Is there some particular reason we need the cast to int on the
> return path for atomic_cmpxchg()?  It looks to me as if this
> macro would work equally well with an atomic_t or an atomic64_t.

No, this is won't work, atomic_cmpxchg is strictly only defined for
atomic_t.  See commit 4a6dae6d382e9edf3ff440b819e554ed706359bc.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
