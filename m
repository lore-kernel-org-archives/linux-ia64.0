From: William Lee Irwin III <wli@holomorphy.com>
Date: Mon, 14 Jul 2003 19:40:44 +0000
Subject: Re: HUGETLB pages on multiple nodes
Message-Id: <marc-linux-ia64-105821182819310@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105821072317881@msgid-missing>
In-Reply-To: <marc-linux-ia64-105821072317881@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 14, 2003 at 12:20:37PM -0700, Nick Pollitt wrote:
> Seth,  It looks like at boot time all the hugepages will get allocated 
> on the boot node.  We'd like to spread the pages across multiple nodes 
> on NUMA systems.  Here's a simple patch to round-robin the pages during 
> kernel init.  Comments?

I shipped some stuff for arch/i386/ that does node-local allocations at
runtime, too.


-- wli
