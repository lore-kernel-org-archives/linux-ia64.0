From: Dean Nelson <dcn@sgi.com>
Date: Tue, 14 Sep 2004 18:58:37 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20040914185837.GA12088@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 24, 2004 at 08:13:43PM +0100, Christoph Hellwig wrote:
> > +++ bk-linux-2.6/kernel/sched.c	2004-08-24 07:29:11.000000000 -0500
> > @@ -2814,6 +2814,7 @@
> >  {
> >  	return setscheduler(pid, policy, param);
> >  }
> > +EXPORT_SYMBOL(sys_sched_setscheduler);
> 
> As said previously you're not supposed to mess with this one.

Yeah, I know, but how is one suppose to deal with the following
issue raised by Robin? (Never did get a response from you.)

On Wed, Jun 16, 2004 at 02:36:22PM -0500, Robin Holt wrote:
> On Wed, Jun 16, 2004 at 06:43:47PM +0100, Christoph Hellwig wrote:
> > On Wed, Jun 16, 2004 at 12:40:53PM -0500, Robin Holt wrote:
> > > > > +EXPORT_SYMBOL(sys_sched_setscheduler);
> > > >
> > > > Again, don't mess with scheduler paramters from your modules.
> > >
> > > How should a kernel thread raise itself to real-time priority?
> >
> > Answer to both:  it shouldn't
>
> To the second, we found that contention would result in very high
> latency without raising the priority to real-time levels.  What is
> the proper way to handle having a user thread at the same priority
> as a kernel thread causing this holdoff?

The problem arises when enough user processes, which have the same
priority as XPC's kthreads, are spinning doing a bit of work mixed
with sleeping. Because of the sleep, these processes get a bonus
which gives them a higher effective priority than the XPC kthreads.
As a result, when cross partition interrupts come in, the XPC kthreads
do not get scheduled immediately, but are held off until the end of
the user processes' time slice.

This problem was encountered running a legitimate user land work load.
I concocted the following program to reproduce the behavior we were
seeing. I did this to see if the problem still exists on the 2.6
kernel (we originally saw the problem running on 2.4).

I ran the program on one of two partitions that were connected via XPC
and XPNET. A ping on each partition was pinging the other partition. With
XPC's priority left to default, the ping times shot way up (300 times the
latency). But with XPC's priority set to realtime, there was no change.

So I would ask again, how are we to deal with this issue if we're
not allowed to change the priority of XPC's kthreads to realtime?

Should we be exporting setscheduler() instead?

Thanks,
Dean


 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <linux/types.h>
#include <sys/types.h>
#include <sys/wait.h>
// #include <asm/ia64regs.h>

/*
 *	choke [ -n <nchildren> ]
 *
 *	-n  number of children to fork (defaults to '#of CPUs * 4')
 */

#define STR_BUF_SIZE	80

#define _IA64_REG_AR_KR0	3072
#define _IA64_REG_AR_ITC	3116
                                                                                
__u64 current_itc;
// long long current_itc;
                                                                                
__u64
get_itc()
{
	asm volatile ("mov %0=ar%1" : "=r" (current_itc) :
			"i"(_IA64_REG_AR_ITC - _IA64_REG_AR_KR0));
	return current_itc;
}

int
get_nCPUs(void)
{
	char str_buf[STR_BUF_SIZE];
	FILE *str_fd;


	/* figure out the number of CPUs on this system */
	str_fd = popen("cat /proc/cpuinfo | grep processor | wc -l", "r");
	if (str_fd = NULL || fgets(str_buf, STR_BUF_SIZE, str_fd) = NULL) {
		fprintf(stderr, "couldn't determine number of CPUs\n");
		return 0;
	}
	(void) pclose(str_fd);
	return atoi(str_buf);
}

void
child_work_and_sleep(void)
{
	int i;
	__u64 t1, t2;
	struct timespec req_time;

	
	req_time.tv_sec = 0;
	req_time.tv_nsec = 4000000;	/* 4msec */

	while (1) {
		/* work for a bit (just less than 1msec) */
		t2 = get_itc();
		do {
			t1 = t2;
			for (i = 1123000; i > 0; i--) {
				i--;
			}
			t2 = get_itc();
		} while (t2 - t1 < 99999);	/* < 1msec */

		/* sleep for a bit (about 4msec) */
		if (nanosleep(&req_time, NULL) = -1) {
			fprintf(stderr, "nanosleep() failed, errno=%d\n",
									errno);
			exit(1);
		}
	}
}

int
main(int argc, char *argv[])
{
	pid_t pid;
	int c, i;
	int nChildren = -1;


	while ((c = getopt(argc, argv, "n:")) != EOF) {
		switch (c) {
		case 'n':
			nChildren = atoi(optarg);
			break;
		case '?':
			fprintf(stderr, "choke [-n nchildren]\n");
			exit(1);
		}
	}

	if (optind != argc) {
		fprintf(stderr, "choke [-n nchildren]\n");
		exit(1);
	}

	if (nChildren = -1) {
		nChildren = get_nCPUs() * 4;
	}


	/* fork nChildren worth of children who work a msec and sleep 4msec */
	printf("forking %d children\n", nChildren);


	for (i = 0; i < nChildren; i++) {

		if ((pid = fork()) = -1) {
			fprintf(stderr, "fork() failed, errno=%d\n", errno);
			exit(1);
		}
		if (pid != 0) {
			printf("child %d: %d\n", i+1, pid);
			continue;
		}

		child_work_and_sleep();
		exit(1);	/* should never get here */
	}

	while ((pid = wait(NULL)) != -1) { /* spin */ }
	if (errno != ECHILD) {
		fprintf(stderr, "wait() failed, errno=%d\n", errno);
		exit(1);
	}
	exit(0);
}

