From: Russ Anderson <rja@sgi.com>
Date: Fri, 11 Feb 2005 14:53:03 +0000
Subject: Re: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <200502111453.j1BEr35524613518@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> 
> As davidm has pointed out, if the OS MCA handler saves the scratch and
> preserved registers before calling C and restores the values before
> returning to SAL then we have no problems.  By definition, the only
> registers that matter are those in struct pt_regs.  Think of an MCA as
> just another type of interrupt, with exactly the same requirements for
> saving registers.

That sounds like the right approach.

> I am completely dropping the proc_state_dump data area and 90% of the
> code in os_mca_dump/restore.  Instead of saving everything in sight, I
> create a struct pt_regs from the current registers plus some data from
> the min_state_save area.  That has three benefits - it gets rid of the
> special case RSE stack frame, it gives a real pt_regs for unwinding
> through the MCA handler and it guarantees that we save the required set
> of registers.

Thanks, Keith.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
