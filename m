From: Andreas Schwab <schwab@suse.de>
Date: Fri, 01 Jun 2001 08:03:31 +0000
Subject: Re: [Linux-ia64] Bug report: 4-threaded program gets seg. fault on malloc, on linu x R2.4.3.
Message-Id: <marc-linux-ia64-105590693005681@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005668@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005668@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Robboy, David G" <david.g.robboy@intel.com> writes:

|> I have reported this on bugzilla also, Bug #42354.  I don't know whether=
 it
|> is
|> a kernel bug, libc, or libpthread.
|> The attached program spawns 3 new threads, and each of the 4 threads doe=
s a
|> malloc.  Run it on a 4P Lion.
|> On Linux kernel R2.4.3 (Red Hat release 7.0.98), it aborts with a
|> segmentation fault.  The same binary executable runs correctly on a R2.4=
.1
|> kernel.

I have no problem running it with 2.4.4 on SuSE 7.2.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

