From: Andreas Schwab <schwab@suse.de>
Date: Fri, 20 Feb 2004 14:52:03 +0000
Subject: Re: Oops in pdflush
Message-Id: <jer7wp6bxo.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> writes:

> You should be getting a better backtrace than that.  ia64_leave_kernel
> is the start of the interrupt handler for the oops, the preceding trace
> points are the interesting ones but they are missing.
>
> Which compiler are you using?

gcc 3.3.3

>  It could be a compiler fault, not generating correct unwind data.

The unwind check says this:

ERROR: ia64_monarch_init_handler: 186 slots, total region length =3D 0
1 error detected in 8160 functions.

> Can you try running with the kdb patch to see if that gives a better
> backtrace for the oops?

I'll try.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
