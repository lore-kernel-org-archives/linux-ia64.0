From: Andreas Schwab <schwab@suse.de>
Date: Tue, 20 Jul 2004 08:23:32 +0000
Subject: Re: fix for unkillable zombie task
Message-Id: <jevfgjulx7.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <16632.21429.257483.650452@napali.hpl.hp.com>
	<jesmbr3pfl.fsf@sykes.suse.de>
	<16636.7969.396569.877226@napali.hpl.hp.com>
In-Reply-To: <16636.7969.396569.877226@napali.hpl.hp.com> (David Mosberger's
 message of "Mon, 19 Jul 2004 12:21:05 -0700")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: davidm@hpl.hp.com
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>>> On Sat, 17 Jul 2004 12:20:46 +0200, Andreas Schwab <schwab@suse.de> =
said:
>
>   Andreas> Could this be the same problem as discussed in the thread at
>   Andreas> <http://marc.theaimsgroup.com/?t=108857537300002&r=3D1&w=3D2>?
>
> It appears the "final" patch never made it into Linus' tree?

And it appears to be a different issue, your patch doesn't fix that.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
