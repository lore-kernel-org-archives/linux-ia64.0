From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 10 Jul 2003 23:22:42 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105787938313209@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Thu, 10 Jul 2003 11:18:38 -0500, Nathan Straz <nstraz@sgi.com> said:
>>> /* int __clone2(int (*fn) (void *arg), void *child_stack_base, */
>>> /* size_t child_stack_size, int flags, void *arg, */ /* pid_t
>>> *parent_tid, void *tls, pid_t *child_tid) */

I'm not finding that clone2() works -- We get a segfault in the cloned
process when it returns.

This is the program:

#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>

int func(void *arg) { 
    fprintf(stderr, "In child\n"); 
    return 0;
} 
 
int main(void) 
{ 
        int pagesize = sysconf(_SC_PAGESIZE); 
        char *stack;
	int status;
        pid_t kidpid; 
 
#define STACKSIZE (pagesize*8) 
        stack = valloc(STACKSIZE); 
        if ((kidpid = __clone2(func, stack, STACKSIZE, SIGCHLD, NULL,
		    NULL,  NULL, NULL)) = -1) 
                perror("clone"); 
        else { 
                waitpid(kidpid, &status, __WALL);
                if (status) 
                   fprintf(stderr, "child failed: status %x\n", 
				   status); 
	} 
        return 0; 
}

I see:

In child
child failed: status b

where b translates to segfault.

Peter c


