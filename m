From: Andreas Schwab <schwab@suse.de>
Date: Thu, 08 Mar 2001 10:39:07 +0000
Subject: Re: [Linux-ia64] Pointer to function has a bad value
Message-Id: <marc-linux-ia64-105590693005266@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005265@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005265@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Robboy, David G" <david.g.robboy@intel.com> writes:

|> Is this a known bug or fixed in a later compiler?  Using gcc version
|> 2.9-ia64-000216-final, assigning the address of a function to a pointer
|> gives the wrong value.  In the following program, the address of twiddle=
 is
|> 0x40000000000003f0, but the value of the pointer i is 0x4000000000078300.

This is correct.  The conversion from pointer to integer is implementation
defined, the only requirement is that if the integer type is wide enough
you'll get the same pointer when casting back to the original pointer
type.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

