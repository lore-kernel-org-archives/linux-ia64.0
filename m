From: "Anil" <anil.s.keshavamurthy@intel.com>
Date: Thu, 10 Jun 2004 23:30:47 +0000
Subject: RE: [PATCH] ia64_cleanup_topology_init
Message-Id: <ORSMSX409FRaqbC8wSA0000000d@orsmsx409.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX409FRaqbC8wSA0000000c@orsmsx409.amr.corp.intel.com>
In-Reply-To: <ORSMSX409FRaqbC8wSA0000000c@orsmsx409.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
>I personally like this a lot better than the current ppc64 
>scheme where all possible cpus are brought online.  It's just 
>confusing.  
>
Thanks you.

>
>I wonder there should be a numa_topology_init() function to do 
>this part, instead if ifdef'ing it here.  In fact, it might 
>even be able to be a completely generic function.

Will you be okay if I define this numa_topology_init() in the same file?


-Anil

