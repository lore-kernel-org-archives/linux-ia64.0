From: Christoph Lameter <clameter@engr.sgi.com>
Date: Sat, 16 Jul 2005 15:14:53 +0000
Subject: Re: [NUMA] Display and modify the memory policy of a process through
Message-Id: <Pine.LNX.4.62.0507160808570.21470@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050715214700.GJ15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
 <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
 <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
 <20050715234402.GN15783@wotan.suse.de> <Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
 <20050716020141.GO15783@wotan.suse.de>
In-Reply-To: <20050716020141.GO15783@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Sat, 16 Jul 2005, Andi Kleen wrote:

> There is no way to do sane locking from user space 
> for such external manipulation of arbitary mappings.  You need
> to do it in the kernel.

These operations do not have to be reliable but best effort. Locking is up 
to the user and the user can check by inspecting proc files if it worked.

> BTW all your talking about VMAs is useless here anyways because
> NUMA policies don't necessarily match VMAs and neither does
> allocated memory. 

Numa policies are per vma. See the definition of vma_area_struct.

> Without my NUMA policy code you wouldn't have any usable NUMA policy today,
> But my goal is definitely to keep the kernel interfaces for this
> clean. And what you're proposing is *not* clean. 

Then come up with an alternative that is cleaner. 

> I think the per VMA approach is fundamentally wrong because
> virtual addresses are nothing an external user can safely
> access.  Doing it on higher level objects allows better interfaces
> and better locking, and as far as I can see process/shm segment/file
> are the only useful objects for this. 

Then you need to remove the association between the VMA and memory 
policies. Otherwise statements like this do not make sense. 
/proc/<pid>/maps already exposes the virtual addresses to user space. The 
address is onlys used to identify the VMA there is no use of "virtual 
addresses" per se.

Plus the libnuma interfaces also rely on addresses.

We can number the vma's if that makes you feel better and refer to the 
number of the vma.
