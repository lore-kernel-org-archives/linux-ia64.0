From: Robert Picco <Robert.Picco@hp.com>
Date: Wed, 18 Feb 2004 19:19:23 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <4033BABB.9080604@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>>>>>>On Wed, 18 Feb 2004 17:08:58 +0000, Christoph Hellwig <hch@infradead.org> said:
>>>>>>            
>>>>>>
>
>  Christoph> On Wed, Feb 18, 2004 at 10:33:29AM -0500, Robert Picco wrote:
>  >> This PXM value (255) isn't a SLIT or PXM defined quantity.  It is really
>  >> specific to HP cell machines.  For example, a machine configured with
>  >> two cells will report three PXMs.  Two for the CPUs and one for the
>  >> interleaved memory at magic PXM 255.  The firmware doesn't report SLIT
>  >> information for PXM 255. The patch approximates the SLIT value for PXM
>  >> 255. I have attempted to arrive at code which doesn't break non-HP
>  >> hardware configurations. I have assumed the way the initialization code
>  >> was written that all NIDs require memory.  Otherwise
>  >> reserve_pernode_space will fail.
>
>  Christoph> I know HP basically owns the IA64 ports
>
>This comment concerns me.  I certainly have always tried to judge
>patches based on their technical merits for Linux.  Is there anything
>in particular that I did (or didn't) do that you found objectionable?
>If so, please let me know.
>
>  Christoph> but honestly can't you fix the firmware to return sane
>  Christoph> information instead?  i.e. move the above fix to firmware
>  Christoph> instead of letting linux fixup the reported data.
>
>Hmmh, I'm no NUMA-expert and it isn't clear to me whether the patch is
>working around a firmware-bug or a limitation in the Linux NUMA code.
>I don't see off-hand why it should be illegal to have a memory config
>with only one node with memory.  The whole PXM_MAGIC business looks
>strange to me though.  Can someone explain?
>
>	--david
>
>  
>
Our HP default boot configuration has all memory  interleaved and 
reported in NUMA SRAT PXM 255.  The
other cell nodes (PXMs) don't have any memory.  This was totally 
unexpected by the current NUMA code. There will be N-1 nids with CPUs 
and no memory and 1 NID with all the memory.  Initialization crashes 
very early.  The current code expects each node to have local memory.  
Well this isn't the case for HP machines.  It could be configured with 
some IPMI interface for every cell to have Cell Local Memory (CLM) but 
such an interface doesn't exist for Linux.  Should such an interface 
become available, the firmware would still steal 0.5Gb of interleaved 
memory from the root cell. 

So, if we had a tool to configure CLM for all cells, there would be N-1 
nids with CPU and local memory and 1 nid with just interleaved memory.  
The current kernel code would work fine but the SLIT information would be
wrong because PXM 255 isn't reported by the firmware in the SLIT table.  
numa_slit isn't used  by non-machine dependent code for memory 
allocation policy  but could be in the future for memory  allocations 
when the current node's memory is exhausted. numa_slit would be used as 
a measure of the best locality to make the allocation from (shortest path).

Bob

