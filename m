From: Andreas Schwab <schwab@suse.de>
Date: Thu, 10 Mar 2005 17:02:33 +0000
Subject: Re: [PATCH] Altix system controller event handling
Message-Id: <jefyz3qvrq.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Greg Howard <ghoward@sgi.com> writes:

> On Thu, 10 Mar 2005, Andreas Schwab wrote:
>
>>
>> Or even better: replace scdrv_buffer_to_int by be32_to_cpup.
>
> Sounds like a good idea.  Will be32_to_cpup work if the
> argument isn't word-aligned?

Probably not, ie. it will result in an unaligned access.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
