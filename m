From: Grant Grundler <grundler@dsl2.external.hp.com>
Date: Thu, 03 Jan 2002 17:35:51 +0000
Subject: [Linux-ia64] Re: is casting of function descriptor assignments for ia64 ONLY a good idea?
Message-Id: <marc-linux-ia64-105590698805737@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Piet/Pete Delaney wrote:
> SUMMARY:
> 
> 	Keith Owens just pointed out that ia64 function descriptor assignments 
>   MUST be cast:
> 
> 		 pointer = ((unsigned long *)(&my_printf))[0])
> 
> 	howerver it appears that other platforms MUST NOT be cast.

I'm pretty sure parisc64 (ELF) does something similar.

We had issues with 32<->64 bit syscall wrappers where a 32-bit user space
structure passed to the kernel contained a function pointer.  I thought it
was in either ioctl32.c or sys_wrapper32.c:
	http://cvs.parisc-linux.org/linux/arch/parisc/kernel/

but couldn't find the exact code.
IIRC, a function ptr has 4 elements and the 3rd contains the addr
to the actual code.

> I've used pointers to functions a lot in the past and I don't recall
> ever haveing a problem like this.

IIRC, the compiler/linker deal with this transperently.
It's only done with function pointers (and not other pointer types).
I only remember seeing this as an issue in 32-64 syscall wrapper conversion.

grant

