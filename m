From: Andreas Schwab <schwab@suse.de>
Date: Tue, 25 Sep 2001 15:14:36 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805249@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> [Argh, the linux-ia64 mailer didn't like the original mail because
|>  the patch was too big.  Here follows the same without patch...]
|>=20
|> Here is a long-awaited kernel update which brings us in sync with
|> 2.4.10.  As usual, it's available at
|> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:
|>=20
|> 	linux-2.4.10-ia64-010924.diff*

CONFIG_DISABLE_VHPT=3Dy seems to be broken (does not boot).  How about
removing it, since we don't support anything below B3 anyway?

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

