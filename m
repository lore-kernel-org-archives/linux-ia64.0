From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 20 Nov 2003 02:47:05 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106929701031376@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At some point in the past, I wrote:
>> You'll have write your own to replace
>> the fix now in -mm if this is what you really want.

On Wed, Nov 19, 2003 at 06:17:03PM -0800, Paul Jackson wrote:
> I'm doing that now; and un-duplicating about a dozen instances of the
> binary->string conversion loops used when reading out masks, and almost
> as many string->binary parse_hex_value() routines used when reading in
> masks.  There will be a single routine for each, in a new lib file.

The format_cpumask() bits did that in the process of standardizing
and/or cleaning up the output. I stuffed it into the cpumask.h header,
but uninlining and/or grabbing a dedicated file is probably a decent
idea, since it may be too large for cpumask.h especially if the parsing
code gets into the picture.


On Wed, Nov 19, 2003 at 06:17:03PM -0800, Paul Jackson wrote:
> Can you tell me, Bill, how it is that having:
>   #define HEX_DIGITS (2*sizeof(cpumask_t))
> leaves room for the terminating nul-byte?  Seems to me that
> a lot of hexnum[] arrays might be one byte short.

I'm not convinced it does. If you could clean up correctness
issues you can find surrounding the parsing code, I'd be much obliged.
I got overextended trying to keep up with numerous things in and around
various architectures, and the irq affinity stuff didn't get heavily
reviewed, commented on, or tested.


On Wed, Nov 19, 2003 at 06:17:03PM -0800, Paul Jackson wrote:
> One incompatibility with existing code:
>     If I proceed along my current path, cpumasks, such as for
>     irq or smp_affinity, will no longer be displayed in /proc
>     with leading zero padding.
>     I expect that this could be a problem ...
> Complaints invited.

I don't see any problems with changing the format at this stage of
the game, even though it may be late in the release process. This is
relatively obscure stuff, and frankly, I suspect you (SGI) will be the
primary users of it (and the sole user for at least several months), so
whatever your favorite format is is pretty much how it should look.


-- wli
