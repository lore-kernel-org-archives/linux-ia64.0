From: n0ano@indstorage.com
Date: Tue, 13 Nov 2001 15:30:11 +0000
Subject: Re: [Linux-ia64] do me a favor
Message-Id: <marc-linux-ia64-105590698805493@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805482@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Qiu-

The fact that your code works does not mean that it is completely
correct, it's not.  Some architectures (IA32) silently allow unaligned
access (although there is a performance penality for doing this),
some architectures (IA64) verbosely allow unaligned accesses (with
a significant performance penality) and other architectures (Sparc)
don't allow unaligned accesses at all.

The way to avoid an unaligned access is actually very simple.  Don't
cast a pointer to one type into a pointer to another type.  For example,
this code:

	{
		int i, *ip;

		ip =3D &i;
		return(*ip);
	}

will not generate an unaligned access whereas this code:

	{
		short s;
		int *ip;

		ip =3D (int *)&s;
		return(*ip);
	}

will.  If you analyze your code carefully you'll discover that it's
doing something similar to the second example.

On Tue, Nov 13, 2001 at 06:11:44PM +0800, Qiu HongBing wrote:
> But I test on ItaniumTM, It work normally only output unaligned access. I
> think it maybe gcc compile options not to use strict-align option. My
> environment is ASUZU Machine to NEC.
>=20
> I only want to know how to avoid to write into syslog that messages.
> most of our source finished porting and now we are testing it and found t=
his
> problem.
> Please help me.
>=20
> --Qiu HongBing
> ----- Original Message -----
> From: "Andreas Schwab" <schwab@suse.de>
> To: "Qiu HongBing" <qiuhb@necas.nec.co.jp>
> Cc: "Tom King" <Tom.King@bullant.com>; "Dan Pop" <Dan.Pop@cern.ch>;
> <linux-ia64@linuxia64.org>
> Sent: Tuesday, November 13, 2001 6:04 PM
> Subject: Re: [Linux-ia64] do me a favor
>=20
>=20
> > "Qiu HongBing" <qiuhb@necas.nec.co.jp> writes:
> >
> > |> Excuse me,
> > |> But I want to avoid this problem. How to do?
> >
> > Your code has never been portable.  You can't just do that.  FWIW, on a
> > sparc it will just crash, because unaligned accesses are strictly
> > forbidden.
> >
> > Andreas.
> >
> > --
> > Andreas Schwab                                  "And now for something
> > Andreas.Schwab@suse.de completely different."
> > SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
> > Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
> >
>=20
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--=20
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

