From: Andreas Schwab <schwab@suse.de>
Date: Tue, 26 Jun 2001 18:54:46 +0000
Subject: [Linux-ia64] Re: volatile unsigned long cpu_online_map vs unsigned long cpu_online_map
Message-Id: <marc-linux-ia64-105590693005779@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005772@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005772@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> >>>>> On Tue, 26 Jun 2001 12:24:20 -0400, Bill Nottingham <notting@redha=
t.com> said:
|>=20
|>   Bill> Also, shoudn't it be extern in at least one of
|>   Bill> setup.c/smpboot.c?
|>=20
|> I already have taken care of that in the latest source tree.  I don't
|> think it causes any problems.

Only if you compile the kernel with -fno-common.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

