From: Andreas Schwab <schwab@suse.de>
Date: Fri, 26 Jul 2002 13:50:03 +0000
Subject: Re: [Linux-ia64] [PATCH] arch/ia64/kernel/efi.c
Message-Id: <marc-linux-ia64-105590701905833@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905832@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905832@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

John Marvin <jsm@udlkern.fc.hp.com> writes:

|> In doing some testing, I discovered the the mem=3D kernel command line o=
ption
|> doesn't behave as expected for zx1 based machines. The current implement=
ation
|> assumes that memory starts at physical address zero and is physically
|> contiguous, i.e. the mem=3D value is used as a limit on the physical add=
ress,
|> rather than specifying the maximum physical memory to use.

IMHO the current behaviour is still useful.  For example to make sure you
have only memory below 4G you can say "mem=3D4G".

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

