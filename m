From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 22 Apr 2002 23:40:14 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905496@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 22, 2002 at 04:07:33PM -0700, David Mosberger wrote:
> Oh man, what a mess!  Have you checked with Dave Miller?  I suspect
> he might not like this.  I'm not terribly fond of it either as it

He was the one that implemented it I thought.  His assertion was that
since most chipsets don't handle 64 bit coherent allocations well, the
consistent interface should be forced to return a 32 bit address (is
that right Dave?).  I don't mind that as long as we add a DAC
consistent call, otherwise I'd like to leave it up to the platform
(i.e. ia64/sn could return a 64 bit address and sparc64 could do 32).

> makes it even more confusing as to when to use the DAC interface.  I'd
> rather see a separate "alloc_consistent" routine, which doesn't isn't
> on <4GB addresses.

I agree, Cc'ing Dave Miller.

Thanks,
Jesse

