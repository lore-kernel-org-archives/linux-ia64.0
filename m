From: John Marvin <jsm@udlkern.fc.hp.com>
Date: Mon, 11 Nov 2002 12:07:05 +0000
Subject: Re: [Linux-ia64] [PATCH] Performance Patch for TLB misses
Message-Id: <marc-linux-ia64-105590709805381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805350@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805350@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Wouldn't removal of this possibly cause cached and uncahced mappings
> > to same page?
>
> Yes, but for the kernel it is allowed also without the patch and the the user c
> ould insert a
> duplicate mapping for the same physical page but this useless for him because o
> f the access
> rights and also the kernel would not use these pages (because the kernel has no
>  knowledge of
> this pages).
>
Christian, you must not have understood what Dave was referring to when
he talked about attribute aliasing. Having cached and uncached mappings
to the same page might be OK on a Pentium, but it is definitely not OK
on the ia64 architecture. It can lead to MCA's. Here's a quote from
the architecture manual that might make it a little clearer (from the
end of section 4.4.1):

    It is recommended that processor models report a Machine Check abort
    if any of the following attribute aliases are detected:

    * Coalescing buffer hit on a non-coalescing page.
    * Cache hit on an uncacheable page, other than as the target of a
      local or remote flush cache instruction.

Just because the user can't use the bad mapping that he may have inserted
doesn't mean that it is not a problem.  Once that translation has been
inserted, it is a potential problem.  Even if the kernel doesn't directly
use the translation, the processor may use it to prefetch.

John Marvin
jsm@fc.hp.com

