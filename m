From: Andreas Schwab <schwab@suse.de>
Date: Wed, 03 Mar 2004 10:57:21 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <jesmgqjizy.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

jbarnes@sgi.com (Jesse Barnes) writes:

> On Tue, Mar 02, 2004 at 06:56:55PM -0800, David Mosberger wrote:
>> >>>>> On Wed, 03 Mar 2004 00:49:20 +0100, Andreas Schwab <schwab@suse.de=
> said:
>>=20
>>   Andreas> Serial console output on Altix didn't convert NL to CRNL.
>>=20
>> Somebody from SGI will have to review/OK this.
>
> Andreas, on which platform and configuration did you see this problem?

It's on the 8P Altix (can't remember the exact platform name).

> It appears that depending on your console configuration, the system
> controller will eat/convert characters.  I'm trying to get it fixed
> properly there...

The system controller should not change the output in any way.  It's the
job of the serial console write function (which is used for printk) to
transform NL to CRNL, which is what I have implemented here.  Note that
normal serial output (which goes through the tty layer) does not exhibit
this problem.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
