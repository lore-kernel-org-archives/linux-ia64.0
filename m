From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Date: Fri, 16 Aug 2002 22:13:35 +0000
Subject: Re: [Linux-ia64] Re: [Discontig-devel] CLUMPS, CHUNKS and GRANULES
Message-Id: <marc-linux-ia64-105590701905947@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> > - A contiguous group of memory chunks that reside on the same node
>> >   are referred to as a clump. Note that a clump may be partially present.
>> >   (Note, on some hardware implementations, a clump is the same as a memory
>> >   bank or a DIMM).
>> > 
>> > - a node consists of multiple clumps of memory. From a NUMA perspective
>> >   accesses to all clumps on the node have the same latency. Except for zone issues,
>> >   the clumps are treated as equivalent for allocation/performance purposes.
>> > 
>> > - each node has a single contiguous mem_map array. The array contains page struct
>> >   entries for every page on the node. There are no "holes" in the mem_map array.
>> >   The node data area (see below) has pointers to the start of the mem_map entries
>> >   for each clump on the node.
>> 
>> The mem_map array is the same on each node, copied from the boot_node
>> to all other nodes. It contains page_struct entries for ALL pages on
>> ALL nodes (if I interpret discontig_paging_init() correctly). The
>> first two sentences need to be reformulated.

Arrrghh! Why on earth would you want to do that? How are you going to 
atomically update things? Replicating things that are heavily written to is
a bad idea.
 
> 	- each node has a single contiguous page_struct array. This array contains page struct
> 	  entries for every page that is actually present on the node. There are no 
> 	  "holes" in the page_struct array for non-existent memory. Note that
> 	  adjacent entries in the array are NOT necessarily for contiguous physical
> 	  pages if there are multiple non-contiguous clumps on the node.

This sounds somewhat saner. I haven't read your code again recently (my head
exploded last time I tried), but most people just use the lmem_map array per node
to just have that node's struct pages.

M.

PS. If you wanted to change all the disgusting defns of PLAT_XXXXX to something
readable, that would make a lot of people happy ;-)


