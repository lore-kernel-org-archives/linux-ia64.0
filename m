From: Andreas Schwab <schwab@suse.de>
Date: Thu, 26 Sep 2002 20:09:33 +0000
Subject: Re: [Linux-ia64] Syscall tracing bug
Message-Id: <marc-linux-ia64-105590701906073@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906071@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906071@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

|> >>>>> On Thu, 26 Sep 2002 21:19:31 +0200, Andreas Schwab <schwab@suse.de=
> said:
|>=20
|>   Andreas> Is this a bug in strace or in the kernel (maybe
|>   Andreas> <asm/rse.h>)?
|>=20
|> It's a bug in the strace you're using.  This was fixed a long time ago
|> in the CVS tree of strace.  I haven't updated my tree since Oct 2001,
|> but it has the right code: around line 1279 in syscall.c, it should
|> say something like this:
|>=20
|> 			sof =3D (cfm >> 0) & 0x7f;
|> 			sol =3D (cfm >> 7) & 0x7f;
|> 			out0 =3D ia64_rse_skip_regs(rbs_end, -sof + sol);

Thanks, it works now.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

