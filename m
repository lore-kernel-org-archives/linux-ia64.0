From: Andreas Schwab <schwab@suse.de>
Date: Wed, 03 Mar 2004 17:36:21 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <jeznaxhlyi.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

jbarnes@sgi.com (Jesse Barnes) writes:

> On Wed, Mar 03, 2004 at 11:57:21AM +0100, Andreas Schwab wrote:
>> The system controller should not change the output in any way.  It's the
>> job of the serial console write function (which is used for printk) to
>
> Right, but I think our L2 system controller *does* molest the output
> (and the 2.6 console driver relies on this behavior).

This is a bug.

> I've filed a bug with our system controller group to make the behavior
> of the L2 and L1 system controllers consistent (I believe you're using
> an L1), which I think is the proper fix.

No, it is the *wrong* thing to do.  If you do stty -onlcr you should get
just one NL, nothing else.  It's the job of the tty layer and the serial
console write function to translate NL to CRNL, nobody else should mangle
the output in any way.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
