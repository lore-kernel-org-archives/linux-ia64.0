From: Andreas Schwab <schwab@suse.de>
Date: Sat, 19 May 2001 16:04:48 +0000
Subject: Re: [Linux-ia64] Buggy unwind tables in user space
Message-Id: <marc-linux-ia64-105590693005628@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005627@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005627@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@ocs.com.au> writes:

|> Most IA64 distributions contain a bad version of crtn.o.  Executables
|> or shared libraries built with this file have invalid unwind data.
|>=20
|> SuSe Linux 7.1a, TurboLinux 000828, TL 010307 (beta3) and Redhat 7.0.90
|> all have a buggy version of crtn.o.  Redhat 7.0.98 (Wolverine) has a
|> clean version of crtn.o, but if any Wolverine binaries were compiled
|> against the old crtn.o then they will be bad as well.

SuSE IA64 7.2-beta has this already fixed, and everything is recompiled,
so no invalid unwind data should be left.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

