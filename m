From: Andreas Schwab <schwab@suse.de>
Date: Tue, 26 Jun 2001 15:34:52 +0000
Subject: [Linux-ia64] volatile unsigned long cpu_online_map vs unsigned long cpu_online_map
Message-Id: <marc-linux-ia64-105590693005770@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

include/asm-ia64/smp.h has 'extern unsigned long cpu_online_map', but
arch/ia64/kernel/setup.c and arch/ia64/kernel/smpboot.c have 'volatile
unsigned long cpu_online_map'.  Which one is correct?

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

