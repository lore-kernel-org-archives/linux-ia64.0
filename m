From: Mario Smarduch <cms063@email.mot.com>
Date: Fri, 14 Mar 2003 18:00:36 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806104@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:

> On Fri, Mar 14, 2003 at 01:33:12PM +010-, Jan Schreckenbach wrote:
> > yep, I'm doing some benchmark stuff with SAP/SAPDB and the performance
> > is not as good as I expected. CONFIG_HUGETLB_PAGE=y is standard on a
> > SLES8 kernel (2.4.19-SMP). I changed the page size from 16K to 64K
> > and the performance increase was 2-3 percent. Changing  Huge TLB Page
> > Size" seems not to have any effect.
>
> Are you using the huge TLB support (it's not transparent to the app).
> If you're  seeing a few percent going from 16k to 64k, I'd expect that
> you'd see a bigger gain going from 16k to using the huge tlb api.  See
> Documentation/vm/hugetlbpage.txt in the kernel source for an idea of
> how to make use it (not sure if the doc is up to date, haven't used it
> myself).
>
> Jesse
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

On on Alpha EV6.8  4-MB page sizes improved Informix performance
(for 2.5GB shared in-core shared memory) by 7 to 10%. This was
mostly due to higher TLB retention, the cache gains were insignificant
since the caches are virtually indexed. It may be useful to use perfmon
on both configurations to determine what's making the difference since
these things are so load specific.  Based on the modest 2-3% boost
it doesn't appear that cache retention for this workload is making a
difference. We're kind of in the same boat and will be looking at
various page sizes too in the future.

- Mario.


