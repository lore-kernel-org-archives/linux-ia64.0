From: Jack Steiner <steiner@sgi.com>
Date: Sat, 17 Aug 2002 00:26:42 +0000
Subject: Re: [Linux-ia64] Re: [Discontig-devel] CLUMPS, CHUNKS and GRANULES
Message-Id: <marc-linux-ia64-105590701905951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> >> >> The mem_map array is the same on each node, copied from the boot_node
> >> >> to all other nodes. It contains page_struct entries for ALL pages on
> >> >> ALL nodes (if I interpret discontig_paging_init() correctly). The
> >> >> first two sentences need to be reformulated.
> >> 
> >> Arrrghh! Why on earth would you want to do that? How are you going to 
> >> atomically update things? Replicating things that are heavily written to is
> >> a bad idea.
> > 
> > We dont do that!!!
> 
> Great. Though I'm not suprised it got misread .... the current code around mem_map
> is very confusing.
> 


I should have explained a little more though.

There are a couple of tables that are used for::
        - finding the mem_map arrays on each of the node
        - virt_to_page() macro
        - basic node manipulation macros (address to node, etc)

Theses table are relatively small and are read-only after boot is complete.
These tables are replicated on each node & are located via the cpu_data structure..

None of the macros virt_to_page(), address_to_node, etc make offnode
references to any data structures (other than the page_struct, of course, if it
is non-local).



-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


