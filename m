From: Don Dugger <n0ano@valinux.com>
Date: Mon, 10 Jul 2000 17:53:10 +0000
Subject: Re: [Linux-ia64] do_mmap_fake question
Message-Id: <marc-linux-ia64-105590678205193@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205192@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205192@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Manfred-

Thanks for looking over the code but I don't think there is a
problem.  `do_mmap_fake' is only called from `sys32_mmap' which
grabs the semaphore `current->mm->mmap_sem' (it also grabs the
kernel lock but we won't go into that).  Any other thread trying
to unmap memmory will block until `do_mmap_fake' completes.

The call to `llseek' is a hold over from my application programming
days, I'll change that in the next release.

Tnx.

On Sun, Jul 09, 2000 at 10:51:44AM +0200, Manfred Spraul wrote:
> do_mmap_fake seems to be buggy:
> 
> You use simple memset/memcpy to initialize user memory.
> AFAICS this can oops on SMP: one thread calls do_mmap_fake, and a second
> thread calls sys_munmap() for that memory range.
> memset/memcpy will fail, and you don't have an exception handler
> installed.
> 
> Btw, why do you use llseek?
> Is there a hidden problem with read(,,,&off)?
> 
> - llseek(,,off);
> - r = file->f_op->read(file,(char*)addr, len, &file->f_pos);
> + r = file->f_op->read(file,(char*)addr, len, &off);
> 
> --
> 	Manfred
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838


