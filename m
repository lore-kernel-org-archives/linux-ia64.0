From: Andreas Schwab <schwab@suse.de>
Date: Mon, 22 Jul 2002 11:54:36 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

|> The latest ia64 kernel patch is at
|> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:
|>=20
|>         linux-2.4.18-ia64-020719.diff.gz

Why are you explicitly disabling CONFIG_BLK_DEV_LOOP, CONFIG_BLK_DEV_NBD
and CONFIG_BLK_DEV_RAM?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

