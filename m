From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Wed, 19 Nov 2003 23:13:34 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106928416217610@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Please read my sentence: it's incredibly useful when _debugging_ a
> problem.

I guess I agree that it is very useful for debugging. But maybe
a different mechanism could be used. Instead of sending this to
the general SYSLOG, why not use a signal (default being off).
This would help interested users to catch the exception in the
execution context.

If a user is debugging a problem, he can simply install a signal
handler

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

