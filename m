From: Eric Piel <Eric.Piel@Bull.Net>
Date: Fri, 21 Feb 2003 16:38:24 +0000
Subject: [Linux-ia64] Bug: Blocking of RT signals in a pause()
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------D57071F28536760B73B084DE"
Message-Id: <marc-linux-ia64-105590709805904@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------D57071F28536760B73B084DE
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello,

I'm still very newby to kernel hacking, however while trying to port the
hrtimer-posix patch (which is now in the main tree) to ia64 I think I
came to find a bug.

Basically the problem is that while my program is in a pause() I can not
receive any signal > 32 (RT signals) even if I've just unblocked them.
In addition if I unblock signal 32 then all the RT signals are
unblocked. This strange behaviour is not reproductible during a sleep().
No idea came to my mind to test other system calls so I can't say more.

Attached to this email, there is a small program to highlight this
behaviour. The bug was reproductible under 2.4ia64 and 2.5ia64 but never
with an ia32 arch. To run it on your computer you compile it:
cc -Wall -DPAUSE -g bug_signal_rt.c -o bug_signal_rt

*and then run it as a background process (so you can send it some
signals):
>./bug_signal_rt &
[3] 15424
Testing SIGNAL1=33 with signal 32 unblocked.

*you send it a signal 33:
>kill -33 15424
The signal 33 was received.
Testing SIGNAL1=33 with signal 33 unblocked.

*send the signal 33:
>kill -33 15424
###nothing happens

So you can see the bug when it received the signal 33 while unblocking
only the signal 32!
If it's not so clear you can have a look at usage_bug_signal_rt.txt to
read a bit more.

Whatever, I tried to correct the bug but after reading
arch/ia64/kernel/signal.c I could find anything to help. My knowledge of
the kernel is still quite poor. So if someone could confirm the bug and
also give me some hints about where I should hunt this bug I would be
very grateful...

Cheers
Eric
--------------D57071F28536760B73B084DE
Content-Type: text/plain; charset=us-ascii;
 name="bug_signal_rt.c"
Content-Disposition: inline;
 filename="bug_signal_rt.c"
Content-Transfer-Encoding: 7bit

/* to enable the signal 33 you have to unblock signal 32 instead of 33!*/

#include <sys/types.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#define SIGNAL1	33 /* SIGRTMIN */

int sig_received;

void sigminrt_handler(int signo, siginfo_t * info, void * ptr)
{
	sig_received = 1;	/* we passed the handler */
}

int do_test(int sig)
{
	sig_received = 0;
#ifdef PAUSE
	pause();		/* wait a lot */
#else
	sleep(10);		/* wait a little bit */
#endif
	if (sig_received) printf("The signal %d was received.\n", sig);
	else printf("The signal %d was NOT received.\n", sig);

	return (sig_received);
}

int main()
{
	struct sigaction sigact;
 	sigset_t new_mask;

        sigact.sa_sigaction =sigminrt_handler;
        sigact.sa_flags = SA_SIGINFO;
        sigemptyset(&sigact.sa_mask);
	sigaction(SIGNAL1, &sigact, NULL);

	sigfillset(&new_mask);
	sigdelset(&new_mask, 32);
	sigprocmask(SIG_SETMASK, &new_mask, NULL);
	printf("Testing SIGNAL1=%d with signal %d unblocked.\n", SIGNAL1, 32);
	do_test(SIGNAL1);

	sigfillset(&new_mask);
	sigdelset(&new_mask, SIGNAL1);
	sigprocmask(SIG_SETMASK, &new_mask, NULL);
	printf("Testing SIGNAL1=%d with signal %d unblocked.\n", SIGNAL1, SIGNAL1);
	do_test(SIGNAL1);

	return 0;
}


--------------D57071F28536760B73B084DE
Content-Type: text/plain; charset=us-ascii;
 name="usage_bug_signal_rt.txt"
Content-Disposition: inline;
 filename="usage_bug_signal_rt.txt"
Content-Transfer-Encoding: 7bit

How to compile and use bug_signal_rt

Compile it with:
cc -Wall -g bug_signal_rt.c -o bug_signal_rt
to provide a sleep() mechanism

or:
cc -Wall -DPAUSE -g bug_signal_rt.c -o bug_signal_rt
to provide a pause() mechanism

Usage:
*run the program in background and note the PID:
./bug_signal_rt &
[3] 15424
Testing SIGNAL1=33 with signal 32 unblocked.

*send it a signal 33:
kill -33 15424
The signal 33 was received.
Testing SIGNAL1=33 with signal 33 unblocked.

*redo it:
kill -33 15424

*if nothing happens you can kill it:
kill -KILL 15424

What it should demonstrate:
In pause() the RT signals blocking methods are not working as specified/expected.
All signals >= 32 are blocked if the flag for signal 32 is set. Flags > 32 are taken into account. This problem doesn't happens in a sleep().

The program blocks all blockable signals execpted one and set an signal handler for signal 33. Then it call a sleep() or a pause() and when going out checks if the signal handler was called.
It does this procedure twice, first with signal 32 unblocked, second with signal 33 unblocked.




--------------D57071F28536760B73B084DE--


