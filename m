From: Andreas Schwab <schwab@suse.de>
Date: Mon, 25 Jun 2001 15:35:07 +0000
Subject: [Linux-ia64] Interrupt redirection problem
Message-Id: <marc-linux-ia64-105590693005755@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This is the output of /proc/interrupts on a Lion that has been up for 9 day=
s:

           CPU0       CPU1       CPU2       CPU3      =20
 32:       2226         19          0          0   IO-SAPIC-edge  keyboard
 33:          2          2          0          0   IO-SAPIC-edge  ide1
 34:          4          2          0          0   IO-SAPIC-edge  ide0
 36:          0          0          0          0   IO-SAPIC-edge  PS/2 Mouse
 44:       1180        131          2         47   IO-SAPIC-edge  serial
 48:   22811357    1510005      31585     155591  IO-SAPIC-level  eth0
 54:          0          0          0          0  IO-SAPIC-level  usb-uhci
 61:    4485678     808931      11218      97495  IO-SAPIC-level  qla1280
238:          0          0          0          0           SAPIC  perfmon
239:  796793291  796794391  796795076  796794435           SAPIC  timer
254:    8256864   11570234   11685908   11611853           SAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

As you can see, cpu0 is processing the majority of interrupts (91%,
ignoring the SAPIC interrupts).  Why?

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

