From: Keith Owens <kaos@sgi.com>
Date: Mon, 20 Jan 2003 10:10:28 +0000
Subject: [Linux-ia64] Re: realtime signals not held
MIME-Version: 1
Content-Type: multipart/mixed; boundary="==_Exmh_1086091520"
Message-Id: <marc-linux-ia64-105590709805730@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multipart MIME message.

--==_Exmh_1086091520
Content-Type: text/plain; charset=us-ascii

Greg Edwards wrote
>A part of one of our test suites that checks signal holding/releasing
>between a parent and forked child appears to have problems with realtime
>signals.  The test forks a child, has the child mask two signals, the
>parent then sends the signals to the child, and the child should release
>and handle one of the signals.  None of the realtime signals are ever
>held, they are caught right away.

It is a glibc bug on ia64, which exists on at least glibc-2.2.4-30 and
glibc-2.2.4-31 (RH AS 2.1).  pause() incorrectly maps sigset from long
to words and corrupts the high order word of the mask (contains the
blocked realtime signals), letting signals through that should be
blocked.  Minimal test case attached based on Greg's code.  Works fine
on ia32, fails on ia64.

# gcc kao2.c -o kao2
# ./kao2
c start 3063
c after defining testsig
c after defining alrm
c setup complete
p sending signal 45
c caught signal 45
Child caught signal 45 before it was unblocked
p Child exited with status 1

# gcc -DMAGIC_INCANTATION kao2.c -o kao2
# ./kao2
c start 3071
c after defining testsig
c after defining alrm
c setup complete
p sending signal 45
c caught signal 14 - ignored
c releasing signal 45
c caught signal 45
p Child exited with status 0

The pause() code in glibc extracts the current blocked mask then
incorrectly propagates signal 32 into signals 33-64 before passing the
mask back to the kernel.  So if signal 32 is blocked, _all_ rt signals
are blocked.  If 32 is not blocked, pause() unblocks all rt signals.
Not good.


--==_Exmh_1086091520
Content-Type: text/plain ; name="kao2.c"; charset=us-ascii
Content-Description: kao2.c

#define _GNU_SOURCE
#include <errno.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

static int child_pid;           /* process id of child */
static int pipe_fd[2];          /* file descriptors for pipe */
static int caught[NSIG];

static void def_handler(int sig)
{
	fprintf(stderr, "Unexpected signal %d received.\n", sig);
	exit(1);
}

static void read_pipe(void)
{
	static char buf[1];
	if (read(pipe_fd[0], buf, sizeof(buf)) < 0) {
		fprintf(stderr, "read() pipe failed. error:%d %s.\n",
			errno, strerror(errno));
		exit(1);
	}
}

static void write_pipe(void)
{
	if (write(pipe_fd[1], "", 1) < 0) {
		fprintf(stderr, "write() pipe failed. error:%d %s.\n",
			errno, strerror(errno));
		exit(1);
	}
}

static void parent(int testsig)
{
	int term_stat;
	int sig;

	for (sig = 1; sig < NSIG; sig++) {
		switch(sig) {
		    case SIGKILL:
		    case SIGSTOP:
		    case SIGCONT:
			break;
		    case SIGCLD:
			continue;
		    default:
			if (signal(sig, def_handler) == SIG_ERR) {
				fprintf(stderr, "signal() failed for signal %d. error:%d %s.\n",
					sig, errno, strerror(errno));
				exit(1);
			}
		}
	}
	read_pipe();
	printf("p sending signal %d\n", testsig);
	if (kill(child_pid, testsig) < 0) {
		fprintf(stderr, "kill() failed. sig:%d error:%d %s.\n",
			testsig, errno, strerror(errno));
		exit(1);
	}
	if (wait(&term_stat) < 0) {
		fprintf(stderr, "wait() failed. error:%d %s.\n",
			errno, strerror(errno));
		exit(1);
	}
	if (WIFSIGNALED(term_stat)) {
		sig = WTERMSIG(term_stat);
		fprintf(stderr, "Unexpected signal killed child. sig:%d.\n", sig);
		exit(1);
	}
	if (!WIFEXITED(term_stat)) {
		fprintf(stderr, "Unexpected return killed child.\n");
		exit(1);
	}
	printf("p Child exited with status %d\n", WEXITSTATUS(term_stat));
	return;
}

static void handler(int sig)
{
	printf("c caught signal %d", sig);
	if (sig == SIGALRM)
		printf(" - ignored");
	else
		++caught[sig];
	printf("\n");
}

static void child(int testsig)
{
	int rv;
	int sig;
	printf("c start %d\n", getpid());
	if (signal(testsig, handler) == SIG_ERR) {
		fprintf(stderr,
			"signal() failed for signal %d. error:%d %s.\n",
			testsig, errno, strerror(errno));
		exit(1);
	}
	printf("c after defining testsig\n");
	if (signal(SIGALRM, handler) == SIG_ERR) {
		fprintf(stderr,
			"signal() failed for signal %d. error:%d %s.\n",
			SIGALRM, errno, strerror(errno));
		exit(1);
	}
	printf("c after defining alrm\n");

	if ((rv = sighold(testsig)) != 0) {
		fprintf(stderr,
			"sighold did not return 0. rv:%d sig:%d.\n", rv, testsig);

	}
#ifdef MAGIC_INCANTATION
	/* holding sig32 makes the hold of other rt signals work */
	if ((rv = sighold(32)) != 0) {
		fprintf(stderr,
			"sighold did not return 0. rv:%d sig:%d.\n", rv, 32);

	}
#endif
	printf("c setup complete\n");
	write_pipe();
	alarm(2);
	pause();
	for (sig = 1; sig < NSIG; ++sig) {
		if (caught[sig]) {
			fprintf(stderr, "Child caught signal %d before it was unblocked\n", sig);
			exit(1);
		}
	}
	printf("c releasing signal %d\n", testsig);
	if ((rv = sigrelse(testsig)) != 0) {
		fprintf(stderr, "sigrelse did not return 0. rv:%d\n", rv);

	}
	for (sig = 1; sig < NSIG; ++sig) {
		if (caught[sig] && sig != testsig) {
			fprintf(stderr, "Child caught unexpected signal %d\n", sig);
			exit(1);
		}
	}
	if (caught[testsig] != 1) {
		fprintf(stderr, "Child did not receive signal %d after it was released\n", testsig);
		exit(1);
	}
	exit(0);
}

#define TESTSIG 45

int main(void)
{
	setvbuf(stdout, NULL, _IONBF, 0);
	if (pipe(pipe_fd) < 0) {
		fprintf(stderr, "pipe() failed. error:%d %s.\n",
			errno, strerror(errno));
		return 1;
	}
	if ((child_pid = fork()) < 0) {
		fprintf(stderr, "fork() failed. error:%d %s.\n",
			errno, strerror(errno));
		return 1;
	}
	if (child_pid > 0) {
		parent(TESTSIG);
	} else {
		child(TESTSIG);
	}
	return 0;
}

--==_Exmh_1086091520--



