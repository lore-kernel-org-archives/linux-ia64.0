From: Andreas Schwab <schwab@suse.de>
Date: Fri, 09 Feb 2001 19:17:20 +0000
Subject: Re: [Linux-ia64] Serial console during linux boot
Message-Id: <marc-linux-ia64-105590693005127@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005123@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005123@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Einar Saltnes <eisa@scali.no> writes:

|> When ELI starts to load the linux kernel, I am not able to get any
|> output on the serial console. I have tried with the line
|>=20
|> append=3D"console=3DttyS0,9600n8"
|>=20
|> in the beginning of /boot/efi/eli.cfg. (Console switch port speed also
|> set to 9600)

One of our machines is running with a serial console without problems (but
I'm using 115200 baud).

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg

