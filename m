From: Andreas Schwab <schwab@suse.de>
Date: Tue, 26 Jun 2001 16:56:58 +0000
Subject: [Linux-ia64] Re: volatile unsigned long cpu_online_map vs unsigned long cpu_online_map
Message-Id: <marc-linux-ia64-105590693005773@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005772@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005772@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bill Nottingham <notting@redhat.com> writes:

|> David Mosberger (davidm@hpl.hp.com) said:=20
|> >   Andreas> include/asm-ia64/smp.h has 'extern unsigned long
|> >   Andreas> cpu_online_map', but arch/ia64/kernel/setup.c and
|> >   Andreas> arch/ia64/kernel/smpboot.c have 'volatile unsigned long
|> >   Andreas> cpu_online_map'.  Which one is correct?
|> >=20
|> > It should be volatile.
|>=20
|> Also, shoudn't it be extern in at least one of setup.c/smpboot.c?

No.  The definition in setup.c is guarded by CONFIG_SMP, and smpboot.c is
not use on non-SMP.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

