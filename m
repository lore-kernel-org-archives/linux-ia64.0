From: Andreas Schwab <schwab@suse.de>
Date: Wed, 19 May 2004 22:30:34 +0000
Subject: Re: Error handling bug in fsys_rt_sigprocmask
Message-Id: <je7jv8yrqt.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeekplxvah.fsf@sykes.suse.de>
In-Reply-To: <jeekplxvah.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

> There already is a check for a bad HOW value, but it comes too late.
> Your patch should be safe, but I'd like to fix it in a way that avoids
> the second (now unnecessary check).  Let me see what I can come up with.

I did remove the second check.  But there is now an additional bundle and
I couldn't find any way to avoid that.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
