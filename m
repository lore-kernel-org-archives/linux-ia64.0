From: Andreas Schwab <schwab@suse.de>
Date: Fri, 20 Apr 2001 20:24:44 +0000
Subject: Re: [Linux-ia64] Re: Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005429@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005429@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Dunlap, Randy" <randy.dunlap@intel.com> writes:

|> Ah, without actually looking at the code, I believe that
|> you have proven that acpidmp doesn't understand ACPI 2.0
|> data structures.

I don't think this is a problem with ACPI 2.0.  The Lions have the ACPI
structures (both pre 2.0 and 2.0) located at adresses above 0x3f000000,
but acpidump only looks at the region 0xe0000 to 0x100000.  The structure
located at 0x000f57b0 doesn't contain a valid ACPI 2.0 structure either
(the xsdt pointer is garbage).

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

