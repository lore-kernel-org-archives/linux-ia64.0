From: Jes Sorensen <jes@linuxcare.com>
Date: Mon, 09 Oct 2000 16:44:29 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205561@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Pete" = Pete Wyckoff <pw@osc.edu> writes:

Pete> Dan.Pop@cern.ch said:
>> On Mon, 9 Oct 2000, Pete Wyckoff wrote: > This little code snippet
>> causes floating-point underflow during the > multiplication.  Try
>> this code and see if it helps.  You don't have to explicitly call
>> the function, it will be automatically executed before main().

Pete> Excellent.  I can manage to get this linked in with the fortran
Pete> application from whence the problem sprung, which is what I
Pete> really wanted.

Pete> Gcc and glibc seem only to care about st0.  The "minimal" fix,
Pete> which relies on glibc and exercises its fe*env functions, is:

We discussed this recently and David strongly opted for glibc setting
s2/s3 the same way we set s0. I need to look closer at this in order
to figure out how to deal with the get-then-set case but I think it's
coming.

Some of this may be broken in glibc-2.1 which I believe is in the
Turbo distrib you are using, however glibc-2.1 is most likely not
going to get fixed.

Jes

