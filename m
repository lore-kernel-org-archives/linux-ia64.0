From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 25 Apr 2002 00:11:19 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905518@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 24, 2002 at 04:53:31PM -0700, David S. Miller wrote:
>    From: Jesse Barnes <jbarnes@sgi.com>
>    Date: Wed, 24 Apr 2002 16:13:08 -0700
>    
>    So the penalty for using DAC comes down to ~.0375% for a 64k I/O, and
>    the benefit is that you don't have to use 32 bit mappings (which can
>    be scarce on some platforms).
> 
> No some, _your_ platform.   It is the only one with this problem.

Right, the platform that I'd like to see work well.

> You only need this 4GB memory for consistent memory, not
> for anything else!  %99 of the kernel is going to use memory
> for pages and data, not descriptors.
> 
> You can use zones and whatnot to make sure this isn't a problem at
> all.

I think you're confusing our platform with generic ia64 platforms.
I'm not worried about allocating in the low 4GB or whatever, I'm
concerned about using 32 bit mappings needlessly.  Of course, generic
ia64 boxes would also benefit...

So if performance isn't an obstacle to implementing a new call, and
I've shown that there are platforms where 64 bit consistent mappings
are better to use than 32 bit mappings when possible, why can't we add
it?  Or maybe just a seperate consistent_mask that drivers could set
to indicate they support the operation and let the platform take care
of it?

Thanks,
Jesse

