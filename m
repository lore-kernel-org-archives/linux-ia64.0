From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 14 Mar 2003 19:00:36 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806107@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 14, 2003 at 09:33:30AM -0800, Jesse Barnes wrote:
> On Fri, Mar 14, 2003 at 01:33:12PM +0100, Jan Schreckenbach wrote:
> > yep, I'm doing some benchmark stuff with SAP/SAPDB and the performance
> > is not as good as I expected. CONFIG_HUGETLB_PAGE=y is standard on a
> > SLES8 kernel (2.4.19-SMP). I changed the page size from 16K to 64K
> > and the performance increase was 2-3 percent. Changing  Huge TLB Page 
> > Size" seems not to have any effect.

richa pointed out that it would probably be a good idea to use perfmon
to count L2DTLB_MISSES events for your app to see whether TLB misses
are really causing a problem.  Another good thing to do might be to
run vmstat during your app run to see how much I/O wait time you're
seeing, and whether you're saturating your block device, etc.

Jesse

