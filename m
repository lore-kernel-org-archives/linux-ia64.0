From: Andreas Schwab <schwab@suse.de>
Date: Fri, 20 Apr 2001 08:24:47 +0000
Subject: Re: [Linux-ia64] Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005439@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005426@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005426@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Michael Madore <mmadore@turbolinux.com> writes:

|> Hi,
|>=20
|> Does this work?
|>=20
|> /usr/bin/getconf _NPROCESSORS_ONLN

This is just another instance of the `cat /proc/cpuinfo' class.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

