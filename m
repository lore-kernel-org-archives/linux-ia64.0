From: nomura@hpc.bs1.fc.nec.co.jp
Date: Mon, 12 Nov 2001 08:59:48 +0000
Subject: Re: [Linux-ia64] Re: Pagesize is different between IA32 and IA64
Message-Id: <marc-linux-ia64-105590698805467@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805466@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805466@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As a supplement to his report,

it seems that sys_brk() in mm/mmap.c uses PAGE_ALIGN and brk syscall in
ia32 emulation uses the sys_brk as it is.
Does this result in the situation that ia32 brk() behaves as if the page
size is 16KB, though in reality 4KB?

From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Subject: [Linux-ia64] Re: Pagesize is different between IA32 and IA64
Date: Mon, 12 Nov 2001 17:29:53 +0900

>  I think the solution of this problem is which
>  following them
>   - __getpagesize function should returns the real pagesize
>   - It needs to prepare the another function that
>     returns real pagesize for malloc instead.
> 
>  I have confirmed this problem, the Kernel version is
>  2.4.7 and the libc version is 2.2.4.
> 
>  This is a sample program.

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.

