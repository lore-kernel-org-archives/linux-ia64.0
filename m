From: Andreas Schwab <schwab@suse.de>
Date: Wed, 25 Jul 2001 13:21:41 +0000
Subject: Re: [Linux-ia64] Big problems with 2.4.7
Message-Id: <marc-linux-ia64-105590693005909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005908@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005908@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Martin Wilck <Martin.Wilck@fujitsu-siemens.com> writes:

|> The suspicious messages at boot are:
|> - "keyboard timeout - AT keyboard not present ?" (drivers/char/pc_keyb.c)
|> - "hda: IRQ probe failed (0xfffffffffffffdfe)" (drivers/ide/ide-probe.c)
|> The latter message repeats twice for IDE devices hda ... hdd.

Just for the record, I have the same problems, but only on Lions.  Booting
the SMP kernel on a BigSur works.

|> Since my keyboard isn't detected, I can do very little to
|> analyze the boot messages in more detail.

All other things, like network and serial console, are doing well (haven't
tried the devices on the IDE bus, though).

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

