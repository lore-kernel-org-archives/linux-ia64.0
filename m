From: Andreas Schwab <schwab@suse.de>
Date: Sat, 01 Dec 2001 18:36:51 +0000
Subject: Re: [Linux-ia64] pthread lib setting for ia64?
Message-Id: <marc-linux-ia64-105590698805567@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Pereira, D LailaX E" <d.lailax.e.pereira@intel.com> writes:

|> Hi=20
|> While running my program on a Linux machine (turbo linux) Itanium proces=
sor,
|> the program does a segmentation fault on a pthread_create(..) command. I
|> checked the arguments of the pthread_create(...) and there is no problem
|> with them. So I ran the program thru gdb , and got the following on seg
|> fault:
|>=20
|> Starting
|> program:
|> /fxsvrux001/home1/depereir/Tmk_SMP-26/apps/test_C/bin.ia64_linux2/stress=
.udp
|> -- -n2 -N1 -hcopilot{,} -p5001 -i1
|> Tmk_startup: SWAPDIR=3D(null), putting swap file in "/tmp".
|>=20
|> Program received signal SIG32, Real-time event 32.
|> 0x2000000000217ba2 in rt_sigsuspend () from /lib/libc.so.6.1
[...]
|> the program receives a SIG32 signal from rt_sigsuspend(..) .I am unable =
to
|> figure this out.=20

This is normal.  SIG32 is used for communication between the thread and
the thread manager.  Use "handle SIG32 nostop noprint pass" to let gdb
handle it transparently.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

