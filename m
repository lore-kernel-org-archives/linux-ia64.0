From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Nov 2004 19:45:44 +0000
Subject: RE: [PATCH] top level scheduler domain for ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F024B7EA6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Maybe, but that will get complex very quickly I think.  Right now we have 
>three domains on ia64, the cpu domain, the node domain, which contains 
>several nodes worth of CPUs, and the top level domain, which spans the whole 
>machine.
>
>So there are two questions, how big should the node domain be and should it 
>span the whole machine (avoiding the need for a top level domain)?  Obviously 
>the answer is pretty machine specific, and I'm not sure the SLIT helps us 
>much since its values are arbitrary distance values, not anything concrete.

I'd pose a broader question ... are the manufacturers of big machines happy
with three domains?  Perhaps it makes sense to allow for more levels that
match the physical parameters of the machine.  E.g. the NEC box has 4 cpus
per-node, and 4 nodes in a "super-node", and 2 "super-nodes" in a machine.
It would make sense to me if there was a scheduler domain level that would
handle balancing between the nodes in a super-node in addition to the top-level
domain to handle balancing between super-nodes.

While the values in SLIT can be somewhat abstract, they could be used to derive
the whole node, super-node, hyper-node, ultra-node, marketting-zeta-node
structure to build as many levels as make sense into the scheduler.

Or am I over-engineering?

-Tony
