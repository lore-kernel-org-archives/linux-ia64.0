From: Paul Jackson <pj@sgi.com>
Date: Thu, 20 Nov 2003 02:59:02 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106929747231964@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Can you tell me, Bill, how it is that having:
> 
>   #define HEX_DIGITS (2*sizeof(cpumask_t))
> 
> leaves room for the terminating nul-byte?  Seems to me that
> a lot of hexnum[] arrays might be one byte short.

To answer my own question - on the output side (reads from /proc), the
code verifies that the user provided HEX_DIGITS+1 count bytes - good.

On the input side (writes into /proc), the code doesn't rely on a
nul-terminator, and ensures that only at most HEX_DIGITS worth are
copied into hexnum[].

It works.  Now let me fire up my time machine and undo one of my posts
from earlier today ...

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
