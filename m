From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 14 Mar 2003 15:51:53 +0000
Subject: RE: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806097@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> yep, I'm doing some benchmark stuff with SAP/SAPDB and the performance
> is not as good as I expected. CONFIG_HUGETLB_PAGE=y is standard on a
> SLES8 kernel (2.4.19-SMP). I changed the page size from 16K to 64K
> and the performance increase was 2-3 percent. Changing  Huge TLB Page 
> Size" seems not to have any effect.

> 2110715 cpu_idle                                 5996.3494

Get rid of this idle would give you much sizeable gain. Doesn't look like the benchmark is saturating the CPU. What is your CPU utilization rate?

