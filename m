From: Andreas Schwab <schwab@suse.de>
Date: Thu, 26 Jul 2001 16:22:19 +0000
Subject: Re: [Linux-ia64] Re: Reiserfs (was: Re: __ia64_syscall ?)
Message-Id: <marc-linux-ia64-105590693005925@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005924@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005924@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bill Nottingham <notting@redhat.com> writes:

|> Martin Wilck (Martin.Wilck@fujitsu-siemens.com) said:=20
|> > This is the source of the endian-patch that makes ReiserFS work
|> > on IA64 (although originally developed for PPC).
|> >=20
|> > http://penguinppc.org/~jeffm/
|>=20
|> Why does an *endian* patch make reiserfs work on ia64, when
|> ia64 is little endian like x86?

The patch not only contains endian fixes, but the ia64 fixes were folded
into it.  It's just that the patch is now misnamed....

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

