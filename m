From: Andreas Schwab <schwab@suse.de>
Date: Mon, 17 Sep 2001 15:27:01 +0000
Subject: Re: [Linux-ia64] sigaltstack not working
Message-Id: <marc-linux-ia64-105590698805191@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805189@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805189@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> >>>>> On 17 Sep 2001 16:12:34 +0200, Andreas Schwab <schwab@suse.de> sai=
d:
|>=20
|>   Andreas> The appended program isn't working as expected.  As soon as
|>   Andreas> the stack limit is reached it hangs without actually
|>   Andreas> executing the signal handler.
|>=20
|> I'm aware of this problem and it's on my todo list, but I'm not sure
|> exactly when I'll find time to fix it.  Did you encounter this in a
|> real program or just with a test program?

It is derived from a test program in clisp 2.26 that verifies that
catching stack overflow works.  That test is even worse, you can only kill
it with SIGKILL.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

