From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 19:43:15 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <16435.49235.480070.729149@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bob,

Thanks for your explanation.  I'm not very familiar with SRAT, PXM etc
(and don't see much reason at this point why I should read it,
especially considering that it's covered by one of those long
Microsoft licenses), so my preference is for this issue to be worked
out among those folks that care about NUMA (you, Jesse, etc.).  In the
unexpected event of not being able to find a solution that's
acceptable to everybody, I'm willing to try to mediate (and learn
about all the RATty stuff.. ;-), but again, I doubt that'll be
necessary.

	--david

>>>>> On Wed, 18 Feb 2004 14:19:23 -0500, Robert Picco <Robert.Picco@hp.com> said:

  Robert> Our HP default boot configuration has all memory interleaved
  Robert> and reported in NUMA SRAT PXM 255.  The other cell nodes
  Robert> (PXMs) don't have any memory.  This was totally unexpected
  Robert> by the current NUMA code. There will be N-1 nids with CPUs
  Robert> and no memory and 1 NID with all the memory.  Initialization
  Robert> crashes very early.  The current code expects each node to
  Robert> have local memory.  Well this isn't the case for HP
  Robert> machines.  It could be configured with some IPMI interface
  Robert> for every cell to have Cell Local Memory (CLM) but such an
  Robert> interface doesn't exist for Linux.  Should such an interface
  Robert> become available, the firmware would still steal 0.5Gb of
  Robert> interleaved memory from the root cell.

  Robert> So, if we had a tool to configure CLM for all cells, there
  Robert> would be N-1 nids with CPU and local memory and 1 nid with
  Robert> just interleaved memory.  The current kernel code would work
  Robert> fine but the SLIT information would be wrong because PXM 255
  Robert> isn't reported by the firmware in the SLIT table.  numa_slit
  Robert> isn't used by non-machine dependent code for memory
  Robert> allocation policy but could be in the future for memory
  Robert> allocations when the current node's memory is
  Robert> exhausted. numa_slit would be used as a measure of the best
  Robert> locality to make the allocation from (shortest path).

