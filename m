From: Andreas Schwab <schwab@suse.de>
Date: Sat, 17 Jul 2004 10:20:46 +0000
Subject: Re: fix for unkillable zombie task
Message-Id: <jesmbr3pfl.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <16632.21429.257483.650452@napali.hpl.hp.com>
In-Reply-To: <16632.21429.257483.650452@napali.hpl.hp.com> (David
 Mosberger's message of "Fri, 16 Jul 2004 15:16:21 -0700")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: davidm@hpl.hp.com
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

> I got a bugreport where a ptrace'd task would end up in an unkillable
> zombie state if the (real) parent of the task happened to ignore
> SIGCHLD.  The patch below should fix the problem.  I attached a
> self-contained test program.  If the bug is present, you should
> see:
>
>  FAILURE: child PID seems to be still around!
>
> at the end (and there will be an unkillable zombie).

Could this be the same problem as discussed in the thread at
<http://marc.theaimsgroup.com/?t=108857537300002&r=3D1&w=3D2>?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
