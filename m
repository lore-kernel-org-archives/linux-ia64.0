From: Paul Jackson <pj@sgi.com>
Date: Thu, 20 Nov 2003 02:17:03 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106929475727936@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> It was to silence a warning.

ah - ok - thanks.


> You'll have write your own to replace
> the fix now in -mm if this is what you really want.

I'm doing that now; and un-duplicating about a dozen instances of the
binary->string conversion loops used when reading out masks, and almost
as many string->binary parse_hex_value() routines used when reading in
masks.  There will be a single routine for each, in a new lib file.

Can you tell me, Bill, how it is that having:

  #define HEX_DIGITS (2*sizeof(cpumask_t))

leaves room for the terminating nul-byte?  Seems to me that
a lot of hexnum[] arrays might be one byte short.

One incompatibility with existing code:

    If I proceed along my current path, cpumasks, such as for
    irq or smp_affinity, will no longer be displayed in /proc
    with leading zero padding.

    I expect that this could be a problem ...

Complaints invited.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
