From: Andreas Schwab <schwab@suse.de>
Date: Mon, 21 Nov 2005 16:48:31 +0000
Subject: Re: Fix asm constraint in put_user
Message-Id: <jey83ilzfk.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7jb2nigc.fsf@sykes.suse.de>
In-Reply-To: <je7jb2nigc.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger-Tang <David.Mosberger@acm.org> writes:

> If memory services, you should use the "o" constraint instead.=20

That doesn't work.

> Note that there is no "memory" clobber, so if you change from "m" to "r"
> constraint, GCC won't know that the location at "addr" is being stored
> to.

There is nothing worth clobbering here.  The memory written to is
completely separate to anything GCC knows about.  The old version didn't
clobber either.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
