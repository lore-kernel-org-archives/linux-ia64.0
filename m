From: Andreas Schwab <schwab@suse.de>
Date: Fri, 21 Jun 2002 07:55:25 +0000
Subject: Re: [Linux-ia64] Re: [Trivial Patch] : (2.5 latest) More
Message-Id: <marc-linux-ia64-105590701905698@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905695@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905695@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Manik Raina <manik@cisco.com> writes:

|> diff -u -r linux-2.5.22/include/asm-ia64/delay.h linux-likely-patch/incl=
ude/asm-ia64/delay.h
|> --- linux-2.5.22/include/asm-ia64/delay.h	Mon Jun 17 08:01:23 2002
|> +++ linux-likely-patch/include/asm-ia64/delay.h	Fri Jun 21 11:18:00 2002
|> @@ -15,6 +15,7 @@
|>  #include <linux/config.h>
|>  #include <linux/kernel.h>
|>  #include <linux/sched.h>
|> +#include <linux/compiler.h>
|> =20
|>  #include <asm/processor.h>
|> =20
|> @@ -52,7 +53,7 @@
|> =20
|>  	__asm__ __volatile__("mov %0=3Dar.itc" : "=3Dr"(result) :: "memory");
|>  #ifdef CONFIG_ITANIUM
|> -	while (__builtin_expect ((__s32) result =3D -1, 0))
|> +	while (unlikely((__s32) result =3D -1)

This doesn't compile, it lacks a paren.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

