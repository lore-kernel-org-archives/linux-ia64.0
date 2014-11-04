From: Dave Hansen <dave.hansen@intel.com>
Date: Tue, 04 Nov 2014 16:00:25 +0000
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
Message-Id: <5458F819.2010503@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos> <544DB873.1010207@intel.com> <alpine.DEB.2.11.1410272138540.5308@nanos> <5457EB67.70904@intel.com> <alpine.DEB.2.11.1411032205320.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1411032205320.5308@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ren Qiaowei <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On 11/03/2014 01:29 PM, Thomas Gleixner wrote:
> On Mon, 3 Nov 2014, Dave Hansen wrote:

> That's not really true. You can evaluate that information with
> mmap_sem held for read as well. Nothing can change the mappings until
> you drop it. So you could do:
> 
>    down_write(mm->bd_sem);
>    down_read(mm->mmap_sem;
>    evaluate_size_of_shm_to_unmap();
>    clear_bounds_directory_entries();
>    up_read(mm->mmap_sem);
>    do_the_real_shm_unmap();
>    up_write(mm->bd_sem);
> 
> That should still be covered by the above scheme.

Yep, that'll work.  It just means rewriting the shmdt()/mremap() code to
do a "dry run" of sorts.

Do you have any concerns about adding another mutex to these paths?
munmap() isn't as hot of a path as the allocation side, but it does
worry me a bit that we're going to perturb some workloads.  We might
need to find a way to optimize out the bd_sem activity on processes that
never used MPX.
