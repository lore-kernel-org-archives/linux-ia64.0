From: Andreas Schwab <schwab@suse.de>
Date: Fri, 26 Oct 2001 14:36:22 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805397@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> An updated ia64 patch for 2.4.13 is now available at
|> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:

The patch add a definition for bust_spinlocks in arch/ia64/kernel/traps.c
which is slightly different from the implementation in
lib/bust_spinlocks.c.  Does it make sense to merge them?

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

