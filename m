From: Andreas Schwab <schwab@suse.de>
Date: Thu, 17 Oct 2002 15:58:34 +0000
Subject: Re: [Linux-ia64] system.h / pal.h / types.h
Message-Id: <marc-linux-ia64-105590709805184@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805181@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805181@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Joe Griffin <jjg@mscsoftware.com> writes:

|> Andreas,
|>=20
|> I am making a few RPMS from source.  The
|> source has an include of asm/system.h.
|> If "asm/system.h" is in a "c" program
|> I do not think a person should have an error.
|>=20
|> Are you saying that programs should
|> not have asm/system.h in them?

Yes, if it's not part of the kernel.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

