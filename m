From: Andreas Schwab <schwab@suse.de>
Date: Tue, 25 Sep 2001 12:17:42 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805248@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> Here is a long-awaited kernel update which brings us in sync with
|> 2.4.10.  As usual, it's available at
|> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:
|>=20
|> 	linux-2.4.10-ia64-010924.diff*

The kernel does not compile with CONFIG_SMP=3Dn and CONFIG_MODVERSIONS=3Dn:

dec_and_lock.c:29: parse error before `1'
dec_and_lock.c:29: parse error before `atomic'
dec_and_lock.c:29: warning: type defaults to `int' in declaration of `_v'
dec_and_lock.c:29: parse error before `atomic'
dec_and_lock.c:29: parse error before `switch'
dec_and_lock.c:32: `atomic' undeclared here (not in a function)
dec_and_lock.c:32: warning: type defaults to `int' in declaration of `_v'
dec_and_lock.c:32: redefinition of `_v'
dec_and_lock.c:29: `_v' previously defined here
dec_and_lock.c:32: `atomic' undeclared here (not in a function)
dec_and_lock.c:32: parse error before `switch'
dec_and_lock.c:38: `atomic_dec_and_lock' undeclared here (not in a function)
dec_and_lock.c:38: initializer element is not constant
dec_and_lock.c:38: (near initialization for `__ksymtab_atomic_dec_and_lock.=
value')

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

