From: Andreas Schwab <schwab@suse.de>
Date: Fri, 03 Mar 2000 17:41:51 +0000
Subject: Re: [Linux-ia64] ELI now on sourceforge
Message-Id: <marc-linux-ia64-105590678204975@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Johannes Erdfelt <jerdfelt@valinux.com> writes:

|> I've taken ELI and created a project on sourceforge.net for it.
|>=20
|> ELI is a boot loader for EFI based systems. It was developed for, and
|> currently only works for, Linux on ia64 systems.
|>=20
|> I've also made a new release which mostly cleans up the allocations
|> before exiting. It's not finished yet, for instance, ACPI data isn't
|> freed yet, but will come soon.

I couldn't get this to compile: FPSWA_PROTOCOL is undefined.  Where and
how is this supposed to be defined?

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg


