From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Date: Mon, 12 Nov 2001 08:29:53 +0000
Subject: [Linux-ia64] Re: Pagesize is different between IA32 and IA64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Multipart_Mon_Nov_12_17:29:53_2001-1"
Message-Id: <marc-linux-ia64-105590698805466@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Multipart_Mon_Nov_12_17:29:53_2001-1
Content-Type: text/plain; charset=US-ASCII


 I am sorry I forgot to say my opinion and attach sample
 program.

 I think the solution of this problem is which
 following them
  - __getpagesize function should returns the real pagesize
  - It needs to prepare the another function that
    returns real pagesize for malloc instead.

 I have confirmed this problem, the Kernel version is
 2.4.7 and the libc version is 2.2.4.

 This is a sample program.


--Multipart_Mon_Nov_12_17:29:53_2001-1
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="d.c"
Content-Transfer-Encoding: 7bit

#include <unistd.h>

#define SIZE4K  (0x1000)
#define SIZE16K (0x4000)

//#define MORECORE (MORECORE)
#define MORECORE (sbrk)

main() {
    char *brk, *curbrk, *p, *adjust;
    int i, j;

    if((brk = (char *)MORECORE(0)) == (char *)-1) {
        printf("Morecore failed.\n");
        exit(1);
    }
    adjust = (char*)((((long)(char *)brk /SIZE16K)+1) *SIZE16K) ;
    if( (brk = (char *)MORECORE((char *)adjust - (char *)brk)) == (char *)-1 ) {
        printf("Morecore failed.\n");
        exit(1);
    }
        
    if( (curbrk = (char*)MORECORE(SIZE4K)) == (char*)-1 ) {
        printf("Morecore failed.\n");
        exit(1);
    }
    
    p = curbrk;
    printf("First MORECORE(It must be cleared) curbrk=0x%x\n", curbrk);
    for(i = 0; i < SIZE4K; i++ ) {
        if( *p != 0 ) { printf("It is dirty\n"); break; }
        *p++;
    }

    p = curbrk;
    for(i = 0; i < SIZE4K; i++ ) {
        *p = (char)0xff;
        p++;
    }

    if( (curbrk = (char*)MORECORE(SIZE4K)) == (char*)-1 ) {
        printf("Morecore failed.\n");
        exit(1);
    }
    
    p = curbrk;
    printf("Second MORECORE(It also must be cleared) curbrk=0x%x\n", curbrk);
    for(i = 0; i < SIZE4K; i++ ) {
        if( *p != 0 ) { printf("It is dirty\n"); break; }
        *p++;
    }
    p = curbrk;
    for(i = 0; i < SIZE4K; i++ ) {
        *p = (char)0xff;
        p++;
    }


    if( (curbrk = (char*)MORECORE(-SIZE4K)) == (char*)-1 ) {
        printf("Morecore failed.\n");
        exit(1);
    }
    
/*
    printf("Aftere MORECORE(-SIZE4K)\n");
    p = curbrk;
    for(i = 0; i < SIZE4K; i++ ) {
        if( *p != 0 ) { printf("It is dirty\n"); break; }
        p++;
    }
*/

    if( (curbrk = (char*)MORECORE(SIZE4K)) == (char*)-1 ) {
        printf("Morecore failed.\n");
        exit(1);
    }
    
    p = curbrk;
    printf("Third MORECORE curbrk = 0x%x\n", curbrk);
    for(i = 0; i < SIZE4K; i++ ) {
        if( *p != 0 ) { printf("It is dirty\n"); break; }
        p++;
    }

    if( (curbrk = (char*)MORECORE(-SIZE4K)) == (char*)-1 ) {
        printf("Morecore failed.\n");
        exit(1);
    }
    
}

--Multipart_Mon_Nov_12_17:29:53_2001-1
Content-Type: text/plain; charset=US-ASCII


> 
> 
>  Hello all.
> 
>  If this problem has already known, I am sorry.
> 
>  I am investigating the problem that calloc returns no
>  cleared area.
>  It was made on IA32 system and executes on IA64.
>  I think calloc expects to clear the memories sbrk
>  returned. But When the program made on IA32 is
>  executing on IA64 system, sbrk sometimes returns no
>  cleared area. 
>  Because the Kernel on IA64 alignes the memories 16K
>  bytes. However, when the progmam made on IA32 is
>  executing on IA64, the function __getpagesize returns
>  4Kbytes. At this case, if the memories that calloc
>  requests to return sbrk(-xxx) is smaller than
>  16Kbytes, the kernel do not unmap this memory.
>  (I think that the time that the memories clears 0 by
>  the kernel is when the kernel maps memories by the signal) 
> 
>  How do you think?
> 
> --
> Regards, 
> Hideki Yamamoto   (V).v.(V) # Empowered by Innovation
> 

--Multipart_Mon_Nov_12_17:29:53_2001-1--

