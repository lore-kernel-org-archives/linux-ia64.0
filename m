From: Andreas Schwab <schwab@suse.de>
Date: Tue, 16 Aug 2005 20:41:39 +0000
Subject: Re: Multiple virtual address mapping for the same code on IA-64 linux kernel.
Message-Id: <je1x4tbon0.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <3faf056805081613365f5237de@mail.gmail.com>
In-Reply-To: <3faf056805081613365f5237de@mail.gmail.com> (vamsi krishna's
	message of "Wed, 17 Aug 2005 02:06:26 +0530")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: vamsi krishna <vamsi.krishnak@gmail.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

vamsi krishna <vamsi.krishnak@gmail.com> writes:

> example /lib/libc-2.2.4.so size 6094859    got mapped 3 times with
> permissions 'r-xp' , '---p' and 'rw-p' from the bottom.

Note the file offset.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
