From: Richard Hirst <rhirst@linuxcare.com>
Date: Tue, 16 Apr 2002 20:36:14 +0000
Subject: Re: [Linux-ia64] gcc type promotion bug?
Message-Id: <marc-linux-ia64-105590701905460@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905457@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905457@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 16, 2002 at 10:31:02PM +0200, Andreas Schwab wrote:
> No.  There are no operands of type double or long double involved, so the
> ususal arithmetic conversions (6.3.1.8) choose float as the common type:
> 
>     Otherwise, if the corresponding real type of either operand is float,
>     the other operand is converted, without change of type domain, to a
>     type whose corresponding real type is float.

OK, thanks.  I looked at (out of date) K&R, which told me all floating
point arithmetic in C was done in double precision, and I tried my
program on i386, where it appeared to worked fine.

Cheers,
  Richard


