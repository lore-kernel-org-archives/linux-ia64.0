From: Andreas Schwab <schwab@suse.de>
Date: Thu, 01 Mar 2001 10:27:02 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005230@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Andreas Schwab <schwab@suse.de> writes:

|> David Mosberger <davidm@hpl.hp.com> writes:
|>=20
|> |> The latest IA-64 patch is now available at:
|> |>=20
|> |>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
|> |>=20
|> |> in file linux-2.4.2-ia64-010228.diff*
|>=20
|> This doesn't compile:
|>=20
|> irq.c:458:28: too many arguments in invocation of macro "local_irq_count"
|> irq.c:474:27: too many arguments in invocation of macro "local_irq_count"
|> irq.c: In function `handle_IRQ_event':
|> irq.c:458: `local_irq_count' undeclared (first use in this function)
|> irq.c:458: (Each undeclared identifier is reported only once
|> irq.c:458: for each function it appears in.)

Another bug:

irq_ia64.c: In function `init_IRQ':
irq_ia64.c:158: `ipi_irqaction' undeclared (first use in this function)
irq_ia64.c:158: (Each undeclared identifier is reported only once
irq_ia64.c:158: for each function it appears in.)

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

