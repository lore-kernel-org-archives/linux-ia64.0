From: Andreas Schwab <schwab@suse.de>
Date: Sat, 20 Sep 2003 13:01:26 +0000
Subject: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106406290503909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106398916511816@msgid-missing>
In-Reply-To: <marc-linux-ia64-106398916511816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Jim Hull" <jim.hull@hp.com> writes:

> But my real issue with the performance of this code is not with
> sign-extend or the scheduling these instructions, it's with the break
> instruction.  I may be mistaken, but hasn't it been many months since
> David Mosberger implemented all the kernel infrastructure needed to
> support syscalls using the epc instruction?

It's only implemented in 2.6 so far.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
