From: Andreas Schwab <schwab@suse.de>
Date: Fri, 14 Sep 2001 10:17:59 +0000
Subject: Re: [Linux-ia64] Issue with using execlp() from a 32 bit binary on IA64
Message-Id: <marc-linux-ia64-105590698805180@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Brian Sumner <bls@sgi.com> writes:

|> Venkatesh Ramamurthy wrote:
|> >=20
|> > Hi,
|> > The RAID group has a problem with using execlp function from a 32bit b=
inary.
|>=20
|> A quick glance at the source indicates a bug in glibc 2.2.3 execl
|> and execlp if you pass more than 1024 arguments.  Strangely, the
|> execle function is OK.

execle has already been fixed more than one year ago, but nobody looked at
execl and execlp so far :-/.  I have now checked in a fix.

Thanks, Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

