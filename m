From: Jesse Barnes <jbarnes@sgi.com>
Date: Sat, 15 Dec 2001 00:55:55 +0000
Subject: Re: [Linux-ia64] mmio barrier macro
Message-Id: <marc-linux-ia64-105590698805700@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805698@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805698@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 14, 2001 at 04:22:42PM -0800, David Mosberger wrote:
> This patch looks wrong to me.  It shouldn't replace __ia64_mf_a() with
> platform_mmiob() because this will force the use of mf.a even on
> platforms that don't need it for memory-mapped I/O.  Also, how about a

Oh yeah, good point.  I guess that means our platform specific
inX/outX routines should be retained then, and we can put the barriers
there.

> comment explaining exactly what is being ordered with respect to whom
> (yes, I know there are many examples in Linux where this hasn't been
> done, but I don't think that's a good reason to make the situation
> worse).

Ok, I'll update that too.

Thanks,
Jesse

