From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 27 Oct 2014 20:49:01 +0000
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
Message-Id: <alpine.DEB.2.11.1410272138540.5308@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos> <544DB873.1010207@intel.com>
In-Reply-To: <544DB873.1010207@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ren Qiaowei <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Mon, 27 Oct 2014, Ren Qiaowei wrote:
> If so, I guess that there are some questions needed to be considered:
> 
> 1) Almost all palces which call do_munmap() will need to add
> mpx_pre_unmap/post_unmap calls, like vm_munmap(), mremap(), shmdt(), etc..

What's the problem with that?
 
> 2) before mpx_post_unmap() call, it is possible for those bounds tables within
> mm->bd_remove_vmas to be re-used.
>
> In this case, userspace may do new mapping and access one address which will
> cover one of those bounds tables. During this period, HW will check if one
> bounds table exist, if yes one fault won't be produced.

Errm. Before user space can use the bounds table for the new mapping
it needs to add the entries, right? So:

CPU 0					CPU 1

down_write(mm->bd_sem);
mpx_pre_unmap();
   clear bounds directory entries	
unmap();
					map()
					write_bounds_entry()
					trap()
					  down_read(mm->bd_sem);
mpx_post_unmap(); 
up_write(mm->bd_sem);
					  allocate_bounds_table();

That's the whole point of bd_sem.

> 3) According to Dave, those bounds tables related to adjacent VMAs within the
> start and the end possibly don't have to be fully unmmaped, and we only need
> free the part of backing physical memory.

Care to explain why that's a problem?
 
Thanks,

	tglx
