From: Andreas Schwab <schwab@suse.de>
Date: Tue, 29 Jan 2002 09:36:44 +0000
Subject: Re: [Linux-ia64] Offsets from C struct into assembler
Message-Id: <marc-linux-ia64-105590698805949@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805940@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805940@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> >>>>> On Tue, 29 Jan 2002 08:06:46 +0100, Christian Hildner <christian.h=
ildner@hob.de> said:
|>=20
|>   Christian> Although it would be a nice feature of the gcc if it
|>   Christian> could include C headers combined with an assembler
|>   Christian> directive for using the offsets the simple solution with
|>   Christian> print_offsets does it's job fine. The good thing here is
|>   Christian> that awk isn't needed.
|>=20
|> It's not difficult to fix print_offsets.c to avoid awk.  We could use
|> directives of the form:
|>=20
|>   asm volatile ("uc_rnat =3D %0"::"i"(offsetof (struct _Unwind_Context, =
rnat)));
|>=20
|> for this purpose (this is a cut & paste from gcc's unwind-ia64.c).

You still have to post-process the output to make it usefull for the
assembler.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

