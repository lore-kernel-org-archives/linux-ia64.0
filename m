From: "Qiu HongBing" <qiuhb@necas.nec.co.jp>
Date: Tue, 13 Nov 2001 10:11:44 +0000
Subject: Re: [Linux-ia64] do me a favor
Message-Id: <marc-linux-ia64-105590698805490@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805482@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

But I test on ItaniumTM, It work normally only output unaligned access. I
think it maybe gcc compile options not to use strict-align option. My
environment is ASUZU Machine to NEC.

I only want to know how to avoid to write into syslog that messages.
most of our source finished porting and now we are testing it and found this
problem.
Please help me.

--Qiu HongBing
----- Original Message -----
From: "Andreas Schwab" <schwab@suse.de>
To: "Qiu HongBing" <qiuhb@necas.nec.co.jp>
Cc: "Tom King" <Tom.King@bullant.com>; "Dan Pop" <Dan.Pop@cern.ch>;
<linux-ia64@linuxia64.org>
Sent: Tuesday, November 13, 2001 6:04 PM
Subject: Re: [Linux-ia64] do me a favor


> "Qiu HongBing" <qiuhb@necas.nec.co.jp> writes:
>
> |> Excuse me,
> |> But I want to avoid this problem. How to do?
>
> Your code has never been portable.  You can't just do that.  FWIW, on a
> sparc it will just crash, because unaligned accesses are strictly
> forbidden.
>
> Andreas.
>
> --
> Andreas Schwab                                  "And now for something
> Andreas.Schwab@suse.de completely different."
> SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
> Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
>



