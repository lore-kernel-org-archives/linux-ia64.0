From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 10 Jun 2004 23:40:00 +0000
Subject: RE: [PATCH] ia64_cleanup_topology_init
Message-Id: <1086910800.26658.58.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX409FRaqbC8wSA0000000c@orsmsx409.amr.corp.intel.com>
In-Reply-To: <ORSMSX409FRaqbC8wSA0000000c@orsmsx409.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-06-10 at 16:30, Anil wrote:
> >I wonder there should be a numa_topology_init() function to do 
> >this part, instead if ifdef'ing it here.  In fact, it might 
> >even be able to be a completely generic function.
> 
> Will you be okay if I define this numa_topology_init() in the same file?

It's certainly a lot better than it was.  To be consistent, you also
might want to call it register_nodes(), just like the ppc64 version.  

-- Dave

