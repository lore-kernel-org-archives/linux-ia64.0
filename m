From: Andreas Schwab <schwab@suse.de>
Date: Sat, 13 Apr 2002 01:38:40 +0000
Subject: Re: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905443@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@ocs.com.au> writes:

|> On Fri, 12 Apr 2002 17:05:37 +0200,=20
|> Andreas Schwab <schwab@suse.de> wrote:
|> >GCC 3 may generate calls to memset, so we need to export it to modules.
|>=20
|> If gcc does that the code does not use the arch tuned memset.  Also the
|> memset function is only generated if __HAVE_ARCH_MEMSET is undefined,
|> but include/asm-ia64/string.h defines __HAVE_ARCH_MEMSET.  We would be
|> better off teaching gcc not to generate calls to memset where we do not
|> want them so the kernel gets the code that we want, not what gcc thinks
|> might be a good idea.

There is no way for gcc to see the memset macro when it generates the call
to the memset function.  And there isn't much lost anyway, since the macro
is just there to call __bzero vs. __memset_generic (aka memset), the
difference is just one parameter more or less.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

