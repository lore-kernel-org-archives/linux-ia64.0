From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 10 Sep 2004 07:42:07 +0000
Subject: Re: [PATCH] arch/ia64/sn: SGI Altix hardware performance monitoring API
Message-Id: <20040910084207.D21519@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0409101641020.17255-100000@woolami.melbourne.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0409101641020.17255-100000@woolami.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 10, 2004 at 05:05:31PM +1000, Mark Goodwin wrote:
> 
> The SGI Altix PROM supports a SAL call for performance monitoring and for
> exporting NUMA topology. We need this in community kernels for diagnostic
> and performance tools to use, especially on very large machines.
> 
> This patch registers a dynamic misc device "sn_hwperf" that supports an
> ioctl interface for reading/writing memory mapped registers on Altix
> nodes and routers via the new SAL call. It also creates a read-only
> procfs file "/proc/sgi_sn/sn_topology" to export NUMA topology and Altix
> hardware inventory.
> 
> Any review/comments most welcome ..  thanks

What tools are using this?  Might be worse to put an url to the source
package into the Kconfig entry.
