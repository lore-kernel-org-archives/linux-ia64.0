From: chas williams <chas@cmf.nrl.navy.mil>
Date: Thu, 14 Jun 2001 19:15:09 +0000
Subject: [Linux-ia64] setjmp/longjmp redux
Message-Id: <marc-linux-ia64-105590693005732@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi, new to the list but i did a little reading of the archives and it seems
that setjmp/longjmp cant do what i need -- switch the stack.

why do i want to do this?  i am working on porting openafs which provides
its own thread library (called lwp) that is implemented with setjmp/longjmp.
what needs to be done in order to make this work?  based on my reading
it seems that ar.rnat (???) need to be saved between the context switches?
i dont know much about the ia64 architecture so if someone could give me
some pointers i would be grateful.

the following code works, but only under cc -g.  using cc -O fails.  i assume
that i am getting 'lucky' using -g.

#include <stdio.h>
#include <setjmp.h>
#include <stdlib.h>

static int rc;
static jmp_buf env;

dump_jmp_buf(jmp_buf a)
{
    int i;
    long *ptr = (long *)a;
    for ( i=0; i < 70; i++)
        if (ptr[i] != 0) printf("(%d) 0x%lx\n",i, ptr[i]);
}

main()
{
        char *altstack;
        unsigned long *patcher;
        int stacksize = 16*1024;

        altstack = malloc(192*1024);

        printf("altstack = %p\n", altstack);
        printf("&rc = %p\n", &rc);

        rc = setjmp(env);
        printf("rc = %d\n", rc);
        if (rc = 1)
        {
                printf("return from longjmp\n");
                exit(0);
        }

        ((unsigned long *)env)[0] = (unsigned long *)(altstack + stacksize - 32);

        dump_jmp_buf(env);

        printf("about to longjmp()...\n");
        longjmp(env, 1);
}


