From: n0ano@indstorage.com
Date: Wed, 14 Nov 2001 16:42:56 +0000
Subject: Re: [Linux-ia64] correct seg fault address on ia-64??
Message-Id: <marc-linux-ia64-105590698805507@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805506@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805506@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

D'Laila-

Remember that longs and pointers are 64 bits.  The `%x' format
to `printf' says to print out a 32-bit integer so you wind up
truncating the upper 32-bits of the address.  Just change your
format to `%lx' and you should print out the right address.

On Wed, Nov 14, 2001 at 08:03:57AM -0800, Pereira, D LailaX E wrote:
> 
> Hi ,
> 
> In the following program, I was trying to obtain the address where a
> segmentation fault is caused. 
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <signal.h>
> #include <sys/mman.h>
> 
> int *x;
> int page_size;
> 
> void segv_handler( int sig, siginfo_t *sip,struct sigcontext *scp){
> 
>   void *vadr=sip->si_addr;
>   unsigned long *pc;
>   unsigned long instr;
>   int  readwrite;
> 
>   if (sig=SIGSEGV){
>     printf("\nSegv handler ..\n");
>   }
>   printf("vaddr : %x \n",vadr);
>    
>   readwrite=(((*(unsigned long*)scp->sc_ip)>>21)&1);
>   printf("Read or write %d\n",readwrite);
>   exit(1);
> }
> 
> 
> int main(){
>   int s;
>   struct sigaction sa;
>   int temp;
> 
>   page_size=getpagesize();
>   printf("Pagesize : %d ,PID=%d\n",page_size,(int)getpid());
>   fflush(stdout);
> 
>   /*SEGV handler setup*/
>   sa.sa_handler=(void*)&segv_handler;
>   sigemptyset(&sa.sa_mask);
>   sigaddset(&sa.sa_mask,SIGIO);
>   sigaddset(&sa.sa_mask,SIGALRM);
> 
>   sa.sa_flags=SA_SIGINFO;
> 
>   if (sigaction(SIGSEGV,&sa,NULL)){
>     printf(" Error assigning signal!\n");
>   }
> 
>   x=(int*)malloc(2*page_size);
> 
>  /* Align to a multiple of page_size, assumed to be a power of two */
>   x = (int *)((long)(((int) (long)x + page_size-1) & ~(page_size-1)));
>   printf("Address:  %x\n",x );
>   //x[0]E6;
> 
>   s=mprotect(x,page_size,PROT_NONE);  //make it none access
>   printf("Page protection : NONE : try reading the page\n ");
>   printf("segv should arise now ...\n");
>   //read the page ... segv?
>   temp=x[0];
>   return 0;
> }
> 
> 
> When I run the program on a ia-64 machine (linux OS) , then I get the
> following output: 
> Pagesize : 16384 ,PID(513
> Address:  4000
> Page protection : NONE : try reading the page
>  segv should arise now ...
> 
> Segv handler ..
> vaddr : 4000 
> Read or write 0
> 
> .............
> However , when I ran the program thru gdb, I got the following:
> Reading symbols from a.out...done.
> (gdb) run ex3.c
> ......
> Pagesize : 16384 ,PID(471
> Address:  4000
> Page protection : NONE : try reading the page
>  segv should arise now ...
> 
> Program received signal SIGSEGV, Segmentation fault.
> 0x40000000000010e0 in main ()
> (gdb) where 
> #0  0x40000000000010e0 in main ()
> #1  0x20000000000906b0 in __libc_start_main (
>     main=0x40000000000013e8 <_fini+408>, argc=2, 
> ubp_av=0x80000fffffffb848, 
>     init=0x40000000000013b8 <_fini+360>, 
>     fini=0x200000000003db30 <_dl_debug_mask>, 
>     rtld_fini=0x20000000002581c8 <_dl_get_origin+632>, 
>     stack_end=0x80000fffffffb840) at ../sysdeps/generic/libc-start.c:129
> #2  0x40000000000010b0 in main ()
> (gdb)....
> 
> 
> So thru, gdb the seg fault address is "0x40000000000010e0" , is my
> interpretation right ?? 
> Why is that when I run the program on itanium , I get the address as "4000"
> and thru gdb as " 0x40000000000010e0". What is wrong?? Please let me know.
> 
> d'laila
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

