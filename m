From: Andreas Schwab <schwab@suse.de>
Date: Wed, 28 Aug 2002 14:42:45 +0000
Subject: Re: [Linux-ia64] How do I enable direct IOs with ia64 ?
Message-Id: <marc-linux-ia64-105590701905992@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jacky Malcles <Jacky.Malcles@bull.net> writes:

|> If I run the following piece of code to an ia64 (azusa) I can see that
|> direct
|> io are not enabled, but please,
|> what do i have to do to have them running?=20

Use getpagesize.

|> compil:
|> cc -O  -D_GNU_SOURCE voyons.c   -o voyons#include <stdio.h>
|> #include <stdlib.h>
|> #include <unistd.h>
|> #include <signal.h>
|> #include <string.h>
|> #include <sys/fcntl.h>
|> #include <errno.h>
|>=20
|> #define BUFSIZE 8192

Page size is 16k by default on ia64, but can be as large as 64k.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

