From: Andreas Schwab <schwab@suse.de>
Date: Fri, 20 Apr 2001 18:44:39 +0000
Subject: Re: [Linux-ia64] Re: Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005441@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005429@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005429@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Dunlap, Randy" <randy.dunlap@intel.com> writes:

|> At the bottom of
|> http://developer.intel.com/technology/IAPC/acpi/downloads.htm

Thanks, this works fine for BigSur.  But on Lion I only get:

RSDP "MSLSAL" @ 0x000f57b0
  0000: 52 53 44 20 50 54 52 20 00 4d 53 4c 53 41 4c 00  RSD PTR .MSLSAL.
  0010: 00 00 00 00                                      ....

acpidmp: cannot map the RSDT

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

