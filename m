From: Andreas Schwab <schwab@suse.de>
Date: Fri, 17 Oct 2003 15:25:15 +0000
Subject: Re: [2.6 PATCH] Missing exported symbol
Message-Id: <marc-linux-ia64-106640434818851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106638921002098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106638921002098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

jbarnes@sgi.com (Jesse Barnes) writes:

> That said, shouldn't these symols be exported in the files that contain
> them?

Yes, that's true.  We should eventually remove all exports from
ia64_ksyms.c except those that are implemented in assembler.  But I think
we should postpone that after test8 since Linus only wants bug fixes at
this time.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
