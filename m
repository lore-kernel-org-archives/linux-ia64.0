From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 30 Nov 2006 10:47:09 +0000
Subject: Re: ia64 ORDERROUNDDOWN issue
Message-Id: <456EB6AD.6000406@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <456D9FD2.2070906@bull.net>
In-Reply-To: <456D9FD2.2070906@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Do we need a "max_order" variable that could be adjusted to some lower
>> value that MAX_ORDER if we find the memory topology doesn't fit inside
>> the lines?  
>
> (Your email talks about nodes, but I am asuming that we're actually dealing
> with per-zone concepts here)

...and ...

> But I wonder if a better approach would be to teach ia64 to just throw away
> the last 1 ..  MAX_ORDER-1 pages from the oddball zone?

Assume we've got a machine with a memory configuration:

Node 0:		0 ... 4 Gbyte - 1
Node 1:		4 Gbyte ... 16 Gbyte - 1

Assume MAX_ORDER is 8 Gbytes (a single binary, for all of our machines,
for maintenance reasons).

An allocation of 8 Gbytes should have its chance.
Therefore the global MAX_ORDER should not be diminished dynamically.
Surely we do not want to throw away 4 Gbytes of memory.

The kernel should support that both of the nodes have starting address at 0.
Therefore the "node_bootmem_map"-s of both of the nodes include the address
range 0 ... 4 Gbyte in the example above.
The "node_bootmem_map" of node 1 just happens to contain 0-s in the range
of 0 ... 4 Gbyte.

A not-in-use level of the buddy allocator
(the 8 Gbyte level on node 0 in the example above)
does not cost too much, I think there is no use to add complexity to the
allocator code.

Thanks,

Zoltan Menyhart

P.S. I guess it is not an ia64-only issue.

 
