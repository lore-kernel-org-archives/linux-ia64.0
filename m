From: Andreas Schwab <schwab@suse.de>
Date: Wed, 24 Sep 2003 20:36:48 +0000
Subject: Re: PATCH: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106443592911239@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106438485815490@msgid-missing>
In-Reply-To: <marc-linux-ia64-106438485815490@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"H. J. Lu" <hjl@lucon.org> writes:

> On Wed, Sep 24, 2003 at 10:36:21AM +0200, Andreas Schwab wrote:
>> "H. J. Lu" <hjl@lucon.org> writes:
>>=20
>> > On Mon, Sep 22, 2003 at 04:21:23PM -0700, Richard Henderson wrote:
>> >> On Mon, Sep 22, 2003 at 12:39:18PM -0700, H. J. Lu wrote:
>> >> > Can I get char * from char [300]?
>> >>=20
>> >> x+0 would work in this case; I'd guess it'd work for most of the
>> >> cases that syscalls need to handle.
>> >>=20
>> >
>> > This patch works for me.
>> >
>> >
>> > H.J.
>> > ---
>> > 2003-09-22  H.J. Lu  <hongjiu.lu@intel.com>
>> >
>> > 	* sysdeps/unix/sysv/linux/ia64/sysdep.h (LOAD_ARGS_1): Use
>> > 	__typeof ((outX) + 0) instead of long.
>>=20
>> Hopefully we don't have any occurences of LOAD_ARGS_n(...,0,..) where the
>> kernel expects long.
>>=20
>
> I don't think it will be the problem. Compiler will do
>
> 	addl outN =3D constant, r0
>
> to pass a constant to the function, regardless what the type is. Am I
> correct?

It doesn't have to be a constant, it can be an arbitrary expression of the
wrong (narrower) type.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
