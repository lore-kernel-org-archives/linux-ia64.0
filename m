From: Don Dugger <n0ano@valinux.com>
Date: Thu, 18 Jan 2001 18:21:38 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_PAGE_SIZE
Message-Id: <marc-linux-ia64-105590693005079@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005077@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005077@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken-

I'm actually in the middle of studying the effects of varying page
sizes on IA64.  Preliminary results are that you suffer approximately
a 10% performance hit when you go from 16K pages to 4K pages (I haven't
looked at 8K pages yet).

If you are running IA32 apps on your IA64 system there are some other
concerns.  All IA32 apps implicitly assume a 4K page size.  To handle
this we've had to do some tricks in the kernel that, for the most part,
have negated paging for IA32 processes.  For technical reasons we wind
up reading in the entire text and data sections of IA32 processes rather
than paging them in during process execution.  This means IA32 processes
are slower to start.  Note that on a kernel with 4K pages IA32 processes
will exhibit normal paging behavior.  Also, there could be applications
that explicitly require 4K pages to work.  I haven't run across any yet
but for absolute compatibility you might need to run with 4K pages.

64K pages don't work right now.  There is code in the SCSI system that
effectively limits the page size to no more that 32K (an unsupported
page size on current IA64 CPU's) so the largest page size we can currently
specify is 16K.  I'm also in the process of fixing that SCSI code as I
want to benchmark the system with 64K pages also.

On Thu, Jan 18, 2001 at 09:55:32AM -0800, Broadfoot, KenX wrote:
> 
> Anyone in the know,
> 
> I am using a 16KB page size for my Lion systems.
> 
> Under the help section of make menuconfig is says:
> 
> 4KB   best for ia32
> 
> 8KB   best for ia64
> 
> 16KB  best for ia64
> 
> 64KB  Not for Itanium
> 
> 
> I just want to know what is the gain or loss if I used 8KB instead of 16KB
> page size.
> 
> Also why is the 64KB page size bad for Itanium?
> 
> Thanks.
> 
> --ken
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

