From: Andreas Schwab <schwab@suse.de>
Date: Wed, 03 Mar 2004 15:52:46 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <jellmihqr5.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Robin Holt <holt@sgi.com> writes:

> On Wed, Mar 03, 2004 at 03:20:46PM +0100, Andreas Schwab wrote:
>> Robin Holt <holt@sgi.com> writes:
>>=20
>> > Are you connected via usb or a DB-9 serial connector?
>>=20
>> DB-9, I think.
>
> The last time I connected to the DB-9 on the back of an Altix,
> I was using minicom (I think) and just changed it so it
> would interpret LF as CRLF.

This is plain wrong.  Just try running a fullscreen program like vi and
watch your screen being garbled.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
