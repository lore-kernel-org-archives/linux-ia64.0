From: Jack Steiner <steiner@sgi.com>
Date: Tue, 01 Oct 2002 20:08:01 +0000
Subject: [Linux-ia64] glibc bug / pthread bug???
Message-Id: <marc-linux-ia64-105590701906079@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone seen this problem or know enough about glibc/threads
to have a good idea about what is busted.


The test case listed below consistently hang using 2.4.18 & glibc-2.2.4-19.3.

If only one instance (fork=1)of the test is run, it runs ok. If multiple copies
of the test are run, it hangs in:

	 *      rt_sigsuspend
	 *      __sigsuspend
	 *      __pthread_wait_for_restart_signal
	 *      pthread_cond_wait
	 *      thread_func
	 *      pthread_start_thread

Has anyone seen this???

/*
  * compile with
  *      gcc -g -Wall -o test test.c -lrt
  *
  * execute 
  *      test [<inner_loop_count> [<outer_loop_count>]]
  *
  *
  * Test creates timer threads that hang in 
  *      rt_sigsuspend
  *      __sigsuspend
  *      __pthread_wait_for_restart_signal
  *      pthread_cond_wait
  *      thread_func
  *      pthread_start_thread
  *
  */ 

 #include <signal.h>
 #include <time.h>
 #include <stdio.h>
 #include <sys/types.h>
 #include <sys/time.h>
 #include <sys/times.h>
 #include <stdlib.h>
 #include <unistd.h>
 #include <sys/wait.h>

 int     forks=5;
 int     count=5;

 void *
 slave(void)
 {
         timer_t timerid;
         pid_t   pid;
         int     i, status;

         for (i=0; i<forks; i++) {
                 if (fork() = 0) {
                         if (timer_create(CLOCK_REALTIME, NULL, &timerid) = -1) {
                                 perror("timer_create");
                                 exit(1);
                         }
                         execlp("/bin/date", "date",  (char *)0);
                 }

                 pid = wait(&status);
         }

         exit(0);
 } 

 int
 main (int argc, char *argv[])
 {
         int i;

         count = argc >= 2 ? atoi(argv[1]) : 5;
         forks = argc >= 3 ? atoi(argv[2]) : 5;

         for (i=0; i<count; i++) {
                 if (fork() = 0)
                         slave();
         }

         exit(0);
 }



-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


