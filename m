From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 14 Mar 2003 17:33:30 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806102@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 14, 2003 at 01:33:12PM +0100, Jan Schreckenbach wrote:
> yep, I'm doing some benchmark stuff with SAP/SAPDB and the performance
> is not as good as I expected. CONFIG_HUGETLB_PAGE=y is standard on a
> SLES8 kernel (2.4.19-SMP). I changed the page size from 16K to 64K
> and the performance increase was 2-3 percent. Changing  Huge TLB Page 
> Size" seems not to have any effect.

Are you using the huge TLB support (it's not transparent to the app).
If you're  seeing a few percent going from 16k to 64k, I'd expect that
you'd see a bigger gain going from 16k to using the huge tlb api.  See
Documentation/vm/hugetlbpage.txt in the kernel source for an idea of
how to make use it (not sure if the doc is up to date, haven't used it
myself).

Jesse

