From: Jim Wilson <wilson@specifixinc.com>
Date: Wed, 24 Sep 2003 21:12:38 +0000
Subject: Re: PATCH: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106443858814288@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106438485815490@msgid-missing>
In-Reply-To: <marc-linux-ia64-106438485815490@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2003-09-24 at 11:56, H. J. Lu wrote:
> I don't think it will be the problem. Compiler will do
> 	addl outN = constant, r0
> to pass a constant to the function, regardless what the type is. Am I
> correct?

No.

The compiler will emit RTL like this
	(set (reg:SI outN) (const_int constant))
which will translate to a
	addl outN = constant, r0
instruction.

However, if you are optimizing, then all we are guaranteed is that a
value equivalent to an SImode constant will end up in the register.  If
you have something like
  if (i = 0)
     sub (0);
and i has type int, and i happens to be already in the right register
for the first argument to sub, then the compiler will optimize away the
load of zero as redundant.  The if statement uses cmp4 which only looks
at the low order 4 bytes of i, and hence any value could be in the upper
4 bytes.  This is OK per the ABI, which says that only the low 4 bytes
of an integer argument are valid.

I have seen reports of this happening for unnamed arguments to stdarg
functions.  There was even one report of this from David Mosberger a
long time ago.  If you are passing a constant zero to a function that
requires long, and you don't have a prototype that forces the conversion
to long, then you must specify 0L to get correct results.

I'm not subscribed to the glibc list, so I think my message will bounce
from there.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

