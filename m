From: Andreas Schwab <schwab@suse.de>
Date: Wed, 03 Mar 2004 13:34:33 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <jefzcqjbpy.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Robin Holt <holt@sgi.com> writes:

> On Wed, Mar 03, 2004 at 11:57:21AM +0100, Andreas Schwab wrote:
>> jbarnes@sgi.com (Jesse Barnes) writes:
>>=20
>> > On Tue, Mar 02, 2004 at 06:56:55PM -0800, David Mosberger wrote:
>> >> >>>>> On Wed, 03 Mar 2004 00:49:20 +0100, Andreas Schwab <schwab@suse=
.de> said:
>> >>=20
>> >>   Andreas> Serial console output on Altix didn't convert NL to CRNL.
>> >>=20
>> >> Somebody from SGI will have to review/OK this.
>> >
>> > Andreas, on which platform and configuration did you see this problem?
>>=20
>> It's on the 8P Altix (can't remember the exact platform name).
>>=20
>
> Are you seeing the missing carriage return on output at the L1 or
> on a terminal connected to the serial port?

I don't know how to differenciate between these two things.  The serial
terminal is connected to the L1 system controller.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
