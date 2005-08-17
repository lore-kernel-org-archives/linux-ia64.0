From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 17 Aug 2005 19:52:10 +0000
Subject: Re: Multiple virtual address mapping for the same code on IA-64
Message-Id: <Pine.LNX.4.62.0508171246070.17863@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04294461@scsmsx401.amr.corp.intel.com>
 <3faf0568050816142715f14c2c@mail.gmail.com>
In-Reply-To: <3faf0568050816142715f14c2c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: vamsi krishna <vamsi.krishnak@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 17 Aug 2005, vamsi krishna wrote:

> Seems like most of core size(VmSize) on ipf (126MB) is coming from the
> code size(VmExe) i.e 97MB. While the code size is just 62MB on amd64.
> 
> Looks like IA-64 wastes a lot of VM due to big instruction sizes, so
> big instruction sizes will improve performance ? compared small
> instruction sizes? , but fetching big instructions surely takes time
> compared to small, this may be the reason why amd64 is the fasttest
> 64-bit process ?

IA64 arranges instructions in word size bundles in order to optimize 
instruction fetch. Current GCC versions cannot properly optimize for 
the parallelism capabilities of the Itanium processor and thus many 
slots are filled with nop. Hopefully that will become better in gcc 4.X.

Itanium processors are the fastest 64bit processors at any given clock 
frequency. The earlier generations of processors do not even have the 
instruction set that would enable the processor to do more parallel 
processing. =-)

Please do not make such inflammatory statements on the 
ia64 list.
