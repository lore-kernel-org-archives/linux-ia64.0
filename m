From: Andreas Schwab <schwab@suse.de>
Date: Wed, 23 Oct 2002 09:26:27 +0000
Subject: Re: [Linux-ia64] ia64 compressed makefile target
Message-Id: <marc-linux-ia64-105590709805212@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805211@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805211@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jesse Barnes <jbarnes@sgi.com> writes:

|> David and Bjorn,
|>=20
|> I noticed that the arch/ia64/Makefile 'compressed' target there's a
|> '--strip-all' arg getting passed to objcopy.  This has the effect of
|> removing relocation info from the vmlinux binary that we need for
|> systems w/o memory at the default link address, if I understand
|> correctly.  Would it be possible to change this option to
|> '--strip-debug' instead?

How about --strip-unneeded?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

