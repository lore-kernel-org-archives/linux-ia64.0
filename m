From: Andreas Schwab <schwab@suse.de>
Date: Wed, 07 Jun 2000 10:18:34 +0000
Subject: Re: [Linux-ia64] Cannot use div operator in shared libraries
Message-Id: <marc-linux-ia64-105590678205125@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205124@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205124@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christoph Rohland <cr@sap.com> writes:

|> Hi,
|>=20
|> Attached are to files to reproduce the error:
|>=20
|> 1) lib.c
|> 2) dl_test.c
|>=20
|> compile them with:
|>=20
|> $ gcc -c lib.c
|> $ ld -shared -o lib.so lib.o -lc

Don't call ld directly, use gcc instead.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg


