From: GV <gv_kovai@yahoo.com>
Date: Mon, 05 May 2003 00:02:23 +0000
Subject: [Linux-ia64] Re: sys_epoll patch for ia64-linux
Message-Id: <marc-linux-ia64-105590723705634@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello All,

Advance thanks for whoever wants to respond to my
problem. Fortunately, I figured out the problem myself
today!!!. Looks like the number, I have set for the
system calls are NOT acceptable by the ia64 kernel.

Changed the number from 1280 to 1230 which worked very
well for me [ofcourse, I had to recompile the kernel
anyway!!!].

Is there any pointers [or] mailing list answers for
those kind of issues ?

Thanks again for this list.

Regards,
GV

--- GV <gv_kovai@yahoo.com> wrote:
> Hello All,
> 
> I am new to this list. Have a sys_epoll patched
> 2.4.20
> kernel. sys_epoll
> patch adds the following 3 system calls
> 
> epoll_create()
> epoll_ctl()
> epoll_wait().
> 
> As this patch actually targets i386, modified the
> two
> files for ia64 as
> follows for the kernel compilation.
> 
> /usr/src/linux-2.4.20.se1/include/asm-ia64/unistd.h
> /* Added by GV - sys_epoll support */
> #define __NR_epoll_create               1280
> #define __NR_epoll_ctl                  1281
> #define __NR_epoll_wait                 1282
> 
> /usr/src/linux-2.4.20.se1/arch/ia64/kernel/entry.S
>         data8 ia64_ni_syscall           // 1279
> reserved for sys_lookup_dcookie
>         data8 sys_epoll_create          // 1280
>         data8 sys_epoll_ctl
>         data8 sys_epoll_wait
> 
> To overcome glibc issue, wrote the simple code as
> follows...
> 
> 
> #include <unistd.h>
> #include <sys/syscall.h>
> #include <errno.h>
> 
> #define SYS_epoll_create 1280
> 
> int main() {
> 
>         int rc;
> 
>         rc = syscall(SYS_epoll_create, 10);
> 
>         if(rc = -1) {
>                 printf("syscall Failed, %s %d\n",
> strerror(errno), errno);
>                 return 1;
>         } else {
>                 printf("syscall passed\n");
>         }
> }
> 
> Note: Also tried with '__NR_' instead of 'SYS'
> 
> ----------------------------------------
> 
> This program returns with error code 38 - Function
> NOT
> implemented.
> 
> Here is the patch :
>
http://www.xmailserver.org/linux-patches/epoll-lt-2.4.20-0.5
> .diff
> 
> Any help/thoughts will be much appreciated.
> 
> Regards,
> GV
> 
> 
> __________________________________
> Do you Yahoo!?
> The New Yahoo! Search - Faster. Easier. Bingo.
> http://search.yahoo.com
> 


__________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo.
http://search.yahoo.com

