From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 28 Mar 2006 19:34:30 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on
Message-Id: <1143574470.9731.40.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2006-03-28 at 14:23 -0500, Bob Picco wrote:
> This could work but you need to be cautious because struct page for ia64
> isn't a power of 2. Also this would have to be done conditionally because 
> SPARSEMEM doesn't require it but of course VIRTUAL_MEM_MAP does. 

If it is done correctly it at least wont _hurt_ sparsemem.  It should
save a bunch of (probably cached) references into the mem_section[]
array, along with a good number of arithmetic operations from each
pfn_valid().

-- Dave

