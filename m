From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 22 Oct 2004 17:05:57 +0000
Subject: ptrace problem in 2.6.9
Message-Id: <20041022170557.GW19372@frankl.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="pAwQNkOnpTn9IO2O"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--pAwQNkOnpTn9IO2O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Roland,

I have some problems with the recent modifications to the
Ptrace infrastructure in 2.6.9 release. Basically I have
the smiple test program attached to this E-mail and it
hangs in 2.6.9 but not in 2.6.9-rc4. Somehow the first
waitpid() does not return. It is not clear to me why.
Is there something Ineed to change in the call itself?
I am running all of this on a 2-way IA-64 machine with
2.6.9. I have not tried on x86. 

I would appreciate your thoughts on this.

Thanks.

-- 
-Stephane

--pAwQNkOnpTn9IO2O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test_ptrace.c"

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/ptrace.h>

static int p[2];

int
child(void)
{
	int ret;
	char c;

	printf("child %d started\n", getpid());
	ret = read(p[0], &c, 1);
	if (ret != 1) {
		perror("read");
		return -1;
	}
	return 0;
}

int
do_test(int argc, char **argv)
{
	int ret, status;
	pid_t pid;
	char c;

	ret = pipe(p);
	if (ret) {
		perror("pipe");
		return -1;
	}

	pid = fork();
	switch(pid) {
		case 0: close(p[1]); exit(child());

		case -1: perror("fork"); return -1;

		default: close(p[0]);
			 sleep(5);
			 /*
			  * stop child
			  */
			 ret = ptrace(PTRACE_ATTACH, pid, NULL, NULL);
			 if (ret) {
				 perror("ptrace_attach");
				 goto abort;
			 }
			 printf("issued ptrace attach ret=%d\n", ret);

			 /*
			  * wait for child stop
			  */
			 ret = waitpid(pid, &status, WUNTRACED);
			 if (ret != pid) {
				 perror("waitpid");
				 goto abort;
			 }
			 printf("got process stopped\n");

			 if (WIFEXITED(status)) {
				printf("child has exited\n");
				goto abort;
			 }

			 /*
			  * detach and resume execution
			  */
			 ptrace(PTRACE_DETACH, pid, NULL, NULL);

			 /*
			  * signal child can proceed
			  */
			 ret = write(p[1], &c, 1);
			 if (ret != 1) {
				 perror("write");
				 kill(pid, SIGKILL);
				 return -1;
			 }

			/* wait for child exit */
			 ret = waitpid(pid, &status, 0);
			 if (ret == -1) {
				perror("final waitpid");
			 }
	}
	return ret == -1 || WEXITSTATUS(status) != 0? -1: 0;
abort:
	 kill(pid, SIGKILL);
	 return -1;
}

int
main(int argc, char **argv)
{
	return do_test(argc, argv);
}

--pAwQNkOnpTn9IO2O--
