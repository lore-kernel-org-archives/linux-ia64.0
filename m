From: Andreas Schwab <schwab@suse.de>
Date: Thu, 19 Apr 2001 14:30:59 +0000
Subject: Re: [Linux-ia64] Re: Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005432@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005429@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005429@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Don Dugger <n0ano@valinux.com> writes:

|> Andreas-
|>=20
|> On my system the boot messages are copied into `/var/log/messages'
|> so you can always go there even if the boot log is cleared.

This is not reliable.  I need something that I can use without depending
on the kernel messages.  Is it possible to get at the ACPI tables in user
space?

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

