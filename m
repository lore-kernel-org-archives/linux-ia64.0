From: Andreas Schwab <schwab@suse.de>
Date: Thu, 26 Apr 2001 17:00:02 +0000
Subject: Re: [Linux-ia64] malloc problems
Message-Id: <marc-linux-ia64-105590693005479@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005473@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005473@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Donny Cooper" <dcooper@hstc.necsyl.com> writes:

|> dynamic_area =3D (unsigned char *) malloc ( membytes );
|> printf(" dyn_area =3D %x %lx, mem=3D %x \n",dynamic_area,dynamic_area,me=
mbytes);

You are passing a pointer where an unsigned int and an unsigned long,
resp., is expected.  That results in undefined behaviour.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

