From: Andreas Schwab <schwab@suse.de>
Date: Mon, 01 Mar 2004 10:34:33 +0000
Subject: Re: Oops in pdflush
Message-Id: <jey8qkq2iu.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>>> On Fri, 27 Feb 2004 22:52:46 -0800, David Mosberger <davidm@linux.hp=
l.hp.com> said:
>
>   David> Hmmh, I think perhaps the right way to fix this is to use a sepa=
rate
>   David> continuation function, which will then take care of doing the
>   David> child-specific actions.  Let me see if I can come up with someth=
ing.
>
> OK, how about the attached patch?  Does it fix the problem for you,
> Andreas?

The system has been under moderate load for a couple of days without any
problems, so it seems to be fixed.

Thanks, Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
