From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 31 Aug 2000 20:16:31 +0000
Subject: Re: [Linux-ia64] gcc warnings on truncations?
Message-Id: <marc-linux-ia64-105590678205433@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205426@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205426@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Is there a way to get gcc to warn (or ideally, error) on truncations to
	shorter types? ie:

No.

The ISO C standard says that all expressions undergo default promotions, and
default promotions require promoting char/short to int.  Thus even a simple
expression like
	   short s;
	   short t;
	   s = s + t;
results in truncation to a shorter type, because the result of s+t is an int
and this result must be truncated to fit in the short destination.  A naive
implementation of this warning would give so many false warnings that it
wouldn't be very useful.  An intelligent implementation could cut down on the
false warnings, but would take much longer to write, and hence it is unlikely
that anyone will bother.

Jim

