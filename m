From: Andreas Schwab <schwab@suse.de>
Date: Thu, 13 Jun 2002 08:59:24 +0000
Subject: Re: [Linux-ia64] pthread failure ???
Message-Id: <marc-linux-ia64-105590701905669@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905668@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905668@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jack Steiner <steiner@sgi.com> writes:

|> We have a pthread'ed application that ran fine on IA64 2.4.17.
|>=20
|> When we upgraded the kernel to 2.4.18, the application started to
|> fail. The failure occurs in glibc at:
|> 	chunk_free
|> 	__libc_free
|> 	...

Please define "failure".

|> Has anyone else seen this behavior or have any ideas??

Check your malloc/realloc/free calls, use a malloc debugger (see the
glibc manual for the glibc internal one).

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

