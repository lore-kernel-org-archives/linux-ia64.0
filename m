From: Andreas Schwab <schwab@suse.de>
Date: Fri, 16 Mar 2001 13:48:36 +0000
Subject: Re: [Linux-ia64] Fortran compiler for ia64?
Message-Id: <marc-linux-ia64-105590693005281@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005278@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005278@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Francis Galiegue <fg@mandrakesoft.com> writes:

|> All is in $subject... The existing toolchain doesn't seem to have any su=
pport
|> for Fortran right now.

Try --enable-fortran, and drop in a copy of the fortran RTL from CVS.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

