From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Date: Fri, 16 Aug 2002 23:46:09 +0000
Subject: Re: [Linux-ia64] Re: [Discontig-devel] CLUMPS, CHUNKS and GRANULES
Message-Id: <marc-linux-ia64-105590701905950@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> >> The mem_map array is the same on each node, copied from the boot_node
>> >> to all other nodes. It contains page_struct entries for ALL pages on
>> >> ALL nodes (if I interpret discontig_paging_init() correctly). The
>> >> first two sentences need to be reformulated.
>> 
>> Arrrghh! Why on earth would you want to do that? How are you going to 
>> atomically update things? Replicating things that are heavily written to is
>> a bad idea.
> 
> We dont do that!!!

Great. Though I'm not suprised it got misread .... the current code around mem_map
is very confusing.

>> PS. If you wanted to change all the disgusting defns of PLAT_XXXXX to something
>> readable, that would make a lot of people happy ;-)
> 
> No problem. What do you suggest.

Anything else! I know you're just following what was already in there, but that
really needs killing too ;-) Something that's readable, not all caps, does what the
name says, and looks like the rest of the kernel VM macros would be nice ;-)

And getting rid of plat_node_data and just shoving it into the pg_data_t with 
everything else might help. Or at least pretending from the macros you do that ;-)

M.


