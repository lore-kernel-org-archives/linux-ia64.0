From: Erich Focht <efocht@ess.nec.de>
Date: Tue, 29 Oct 2002 23:43:01 +0000
Subject: [Linux-ia64] Re: [PATCH] topology for ia64
Message-Id: <marc-linux-ia64-105590709805288@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805203@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805203@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 29 October 2002 23:19, Matthew Dobson wrote:
> Hi Erich!  Apologies for the long response delay...  I think our mail
> server must be a bit lagged.  ;)

Should I use another email address?

> It looks good to me.  As far as this comment:
> +/*
> + * Returns the number of the first CPU on Node 'node'.
> + * Slow in the current implementation.
> + * Who needs this?
> + */
> +/* #define __node_to_first_cpu(node) pool_cpus[pool_ptr[node]] */
> +static inline int __node_to_first_cpu(int node)
>
> No one is using it now.  I think that I will probably deprecate this
> function in the near future as it is pretty useless.  Anyone looking for
> that functionality can just do an __ffs(__node_to_cpu_mask(node))
> instead, and hope that there is a reasonably quick implementation of
> __node_to_cpu_mask.

Yes, I know of one usage meanwhile. The problem I see is: as far as I
understand the CPUs are not sorted by the node numbers. The NUMA API
doesn't require that, I think. So finding the first CPU in a node is
not really useful for looping over the CPUs of only one node.

When you think of further developments of the NUMA API, I'd suggest
two:

1: Add a sorted list of the nodes and a pointer array into that list
pointing to the first CPU in the node. Like

int node_cpus[NR_CPUS];
int node_first_ptr[MAX_NUMNODES+1];

(or macros, doesn't matter).

Example: 2 nodes:
         node_cpus : 0 1 4 5 2 3 6 7
              node : 0 0 0 0 1 1 1 1
           pointer : ^       ^       ^
=> node_first_ptr[]: 0       4       8

One can initialize this easilly by using the __cpu_to_node()
macro. And with this you can loop over the cpus of one node by doing:

       for (i=node_first_ptr[node]; i<node_first_ptr[node+1]; i++) {
           cpu = node_cpus[i];
           ... do stuff with cpu ...
       }


2: In ACPI there is a table describing the latency ratios between the
nodes. It is called SLIT (System Locality Information Table). On an 8
node system (NEC TX7) this is a matrix of dimension numnodes*numnodes:

int __node_distance[ 8 * 8]    = { 10, 15, 15, 15, 20, 20, 20, 20,
                                   15, 10, 15, 15, 20, 20, 20, 20,
                                   15, 15, 10, 15, 20, 20, 20, 20,
                                   15, 15, 15, 10, 20, 20, 20, 20,
                                   20, 20, 20, 20, 10, 15, 15, 15,
                                   20, 20, 20, 20, 15, 10, 15, 15,
                                   20, 20, 20, 20, 15, 15, 10, 15,
                                   20, 20, 20, 20, 15, 15, 15, 10 };

#define node_distance(i,j)  __node_distance[i*8+j]

This means:
   node_distance(i,i) = 10   (i==j: same node, lowest latency)
   node_distance(i,j) = 15   (i!=j: different node, same supernode)
   node_distance(i,j) = 20   (i!=j: different node, different
                              supernode)

This macro or function describes the NUMA topology of a multi-level
system very well. As the table comes for free with NUMA systems with
ACPI (sooner or later they'll all have this, especially if they want
to run Windows, too), it would be easy to take it into the topology.h.

Regards,
Erich



