From: Andreas Schwab <schwab@suse.de>
Date: Wed, 19 Mar 2003 09:53:30 +0000
Subject: Re: [Linux-ia64] Idenitfier clash in read_[un]lock
Message-Id: <marc-linux-ia64-105590723705270@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806152@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806152@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

|> >>>>> On Tue, 18 Mar 2003 15:33:42 +0100, Andreas Schwab <schwab@suse.de=
> said:
|>=20
|>   Andreas> The read_lock and read_unlock macros should not use such
|>   Andreas> innocent variable names like tmp because they have a high
|>   Andreas> probability to clash with (part of) the argument.
|>=20
|> Thanks, I applied this patch for 2.5.  In the future, it would be nice
|> if you could send patches that apply with "patch -p1" and if you could
|> specify what kernel the patch is relative to.

Sorry, I'll take more care the next time.

Thanks, Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

