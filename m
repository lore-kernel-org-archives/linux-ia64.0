From: Grant Grundler <iod00d@hp.com>
Date: Wed, 11 Feb 2004 19:26:20 +0000
Subject: Re: u64 vs %llu format
Message-Id: <20040211192620.GE10901@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040211181730.GC10901@cup.hp.com>
In-Reply-To: <20040211181730.GC10901@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 11, 2004 at 10:47:42AM -0800, David Mosberger wrote:
> >>>>> On Wed, 11 Feb 2004 10:17:30 -0800, Grant Grundler <iod00d@hp.com> said:
> 
>   Grant> Why is __u64 defined as "unsigned long" and not "unsigned long long"?
> 
> Because that's the way it is for pretty much every other 64-bit
> UNIX-like platform.  64-bit UNIX/Linux platforms existed long before
> "long long" was widely supported.

ok. I initially read this as "64-bit unix source compat is more important
than ILP32-linux compat". But that's not a fair statement since it implies
alot more than this silly %llu vs u64 issue.

>   Grant> will generate this warning:
>   Grant> <file>:<line>: warning: long long unsigned int format, __u64 arg (arg 2)
> 
> Just cast "i" to (unsigned long long) and the code will be fine.

Yes, or use "unsigned long long" instead of u64 in the first place.
I'll try to convince the code owner to only use "u64" for stuff
representing HW or other "shared" data structures. The distinction
is artificial since both are the same size on LP64 platforms.
But it would reduce the number of warnings we need to fix.

thanks,
grant
