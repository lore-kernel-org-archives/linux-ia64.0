From: Andreas Schwab <schwab@suse.de>
Date: Fri, 11 Jul 2003 09:57:30 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105791745708175@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Peter Chubb <peter@chubb.wattle.id.au> writes:

|> >>>>> "David" =3D David Mosberger <davidm@napali.hpl.hp.com> writes:
|>=20
|> >>>>> On Thu, 10 Jul 2003 11:18:38 -0500, Nathan Straz <nstraz@sgi.com> =
said:
|> >>> /* int __clone2(int (*fn) (void *arg), void *child_stack_base, */
|> >>> /* size_t child_stack_size, int flags, void *arg, */ /* pid_t
|> >>> *parent_tid, void *tls, pid_t *child_tid) */
|>=20
|> I'm not finding that clone2() works -- We get a segfault in the cloned
|> process when it returns.
|>=20
|> This is the program:
|>=20
|> #include <stdio.h>
|> #include <sys/wait.h>
|> #include <unistd.h>
|> #include <sys/types.h>
|> #include <stdlib.h>
|>=20
|> int func(void *arg) {=20
|>     fprintf(stderr, "In child\n");=20
|>     return 0;
|> }=20

You can't return from the function, only exit() or _exit() works.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
