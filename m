From: Andreas Schwab <schwab@suse.de>
Date: Wed, 21 Mar 2001 10:02:16 +0000
Subject: Re: [Linux-ia64] sprofil() implementation
Message-Id: <marc-linux-ia64-105590693005315@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005308@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005308@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> +size_t taddr[] |> +  {
|> +    0x00001000,		/* elf32/hppa */
|> +    0x08048000,		/* elf32/x86 */
|> +    0x00400000,		/* elf32/mips */
|> +    0x01800000,		/* elf32/ppc */
|> +    0x00010000,		/* elf32/sparc */
|> +    0x4000000000000000,	/* elf64/ia64 */
|> +    0x0000000120000000,	/* elf64/alpha */
|> +    0x4000000000001000,	/* elf64/hppa */
|> +    0x0000000100000000	/* elf64/sparc */
|> +  };

This is missing the address for elf32/m68k, which is 0x80000000.  Note
that you will get a warning on 32 bit systems for the 64 bit constants.

|> +      prof[profcnt].pr_off =3D (size_t) taddr[i];

The cast is useless.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

