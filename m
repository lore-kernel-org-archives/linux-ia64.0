From: Andreas Schwab <schwab@suse.de>
Date: Thu, 17 Oct 2002 14:36:59 +0000
Subject: Re: [Linux-ia64] system.h / pal.h / types.h
Message-Id: <marc-linux-ia64-105590709805182@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805181@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805181@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Joe Griffin <jjg@mscsoftware.com> writes:

|> Hello,
|>=20
|> The following program fails on my IA64 (tiger)
|> with the 2.4.18 kernel and 2.2.4 glibc.  There
|> is an error when system.h includes pal.h:
|>=20
|> #include <stdio.h>
|> #include <asm/system.h>
|> main ()
|> {
|> printf("Hello World \n");
|> }

What are you trying to do?  Kernel headers are just that, kernel headers,
and not for use in user programs.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

