From: Andreas Schwab <schwab@suse.de>
Date: Mon, 22 Nov 2004 16:51:59 +0000
Subject: Re: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <jept25yggg.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A20AF3.9030408@sgi.com> <20041122162214.GE21861@wotan.suse.de>
In-Reply-To: <20041122162214.GE21861@wotan.suse.de> (Andi Kleen's message of
 "Mon, 22 Nov 2004 17:22:14 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@sgi.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

Andi Kleen <ak@suse.de> writes:

> At least in traditional signal semantics you have to call sigaction
> or signal in each signal handler to reset the signal. So that=20
> assumption is not necessarily true.

If you use sigaction then you get POSIX semantics, which don't have this
problem.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
