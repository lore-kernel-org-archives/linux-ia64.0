From: Andreas Schwab <schwab@suse.de>
Date: Mon, 31 Dec 2001 13:11:31 +0000
Subject: Re: [Linux-ia64] [PATCH][RFC][CFT] remove global errno from the kernel, make _syscallX kernel-only
Message-Id: <marc-linux-ia64-105590698805726@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805724@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805724@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Lennert Buytenhek <buytenh@gnu.org> writes:

|> What I would like to know from each architecture team:
|> - What is your arch's policy on userspace usage of asm/unistd.h, and
|>   consequently, what is your opinion on the goal these patches
|>   aim for?

I very much appreciate the removal of the _syscallX macros.  FWIW, the
ia64 version of these macros never worked in userspace anyway.

|> - Are the changes I made in [1] and [2] for your $arch technically
|>   correct?

The m68k changes look ok.

|> Please CC me on replies as I'm not on any of the lists posted to.
|>=20
|> My intention is to push these to Linus for 2.5 if everyone agrees.
|> They're probably too intrusive for 2.4 (although I'd love people
|> to convince me otherwise).

I wouldn't mind putting it into 2.4.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

