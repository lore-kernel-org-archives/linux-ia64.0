From: wtc@netscape.com (Wan-Teh Chang)
Date: Mon, 05 Jun 2000 05:44:24 +0000
Subject: [Linux-ia64] Two IA-64 Linux bugs
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------E22C6A411323F9DB0376196C"
Message-Id: <marc-linux-ia64-105590678205116@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------E22C6A411323F9DB0376196C
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

System info:
[nspr@tl2 unix]$ uname -a
Linux tl2.compile.sourceforge.net 2.3.99-pre6-000501-18smp
#1 SMP Sat May 6 21:30:48 PDT 2000 ia64 unknown

Bug #1: pthread_cond_wait sometimes returns EINVAL (22).
Run the first attachment (pingpong.c) repeatedly.
Note that this test doesn't call pthread_cond_destroy
so it is impossible that we are waiting on a destroyed
condition variable.  This failure is intermittent so you
may need to try many times to reproduce it.

Bug #2: sysconf(_SC_NPROCESSORS_ONLN) returns 0.
It should return the number of processors online.
Run the second attachment (ncpus.c) to reproduce it.

Wan-Teh
--------------E22C6A411323F9DB0376196C
Content-Type: text/plain; charset=us-ascii;
 name="pingpong.c.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pingpong.c.txt"

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#define LOOP 20000

int toggle = 0;          /* either 0 or 1 */
pthread_mutex_t mutex;   /* protects 'toggle' */
pthread_cond_t cond;     /* for the threads to wait on */

void *ping(void *arg)
{
    int i;
    int rv;

    rv = pthread_mutex_lock(&mutex);
    if (rv) {
        fprintf(stderr, "pthread_mutex_lock failed: %d\n", rv);
        exit(1);
    }
    for (i = 0; i < LOOP; i++) {
        while (toggle == 0) {
            rv = pthread_cond_wait(&cond, &mutex);
            if (rv) {
                fprintf(stderr, "pthread_cond_wait failed: %d\n", rv);
                exit(1);
            }
        }
        toggle--;
        rv = pthread_cond_signal(&cond);
        if (rv) {
            fprintf(stderr, "pthread_cond_signal failed: %d\n", rv);
            exit(1);
        }
    }
    rv = pthread_mutex_unlock(&mutex);
    if (rv) {
        fprintf(stderr, "pthread_mutex_unlock failed: %d\n", rv);
        exit(1);
    }
    return NULL;
}

void *pong(void *arg)
{
    int i;
    int rv;

    rv = pthread_mutex_lock(&mutex);
    if (rv) {
        fprintf(stderr, "pthread_mutex_lock failed: %d\n", rv);
        exit(1);
    }
    for (i = 0; i < LOOP; i++) {
        while (toggle == 1) {
            rv = pthread_cond_wait(&cond, &mutex);
            if (rv) {
                fprintf(stderr, "pthread_cond_wait failed: %d\n", rv);
                exit(1);
            }
        }
        toggle++;
        rv = pthread_cond_signal(&cond);
        if (rv) {
            fprintf(stderr, "pthread_cond_signal failed: %d\n", rv);
            exit(1);
        }
    }
    rv = pthread_mutex_unlock(&mutex);
    if (rv) {
        fprintf(stderr, "pthread_mutex_unlock failed: %d\n", rv);
        exit(1);
    }
    return NULL;
}

int main()
{
    pthread_attr_t attr;
    pthread_t t1, t2;
    int rv;

    rv = pthread_mutex_init(&mutex, NULL);
    if (rv) {
        fprintf(stderr, "pthread_mutex_init failed: %d\n", rv);
        exit(1);
    }
    rv = pthread_cond_init(&cond, NULL);
    if (rv) {
        fprintf(stderr, "pthread_cond_init failed: %d\n", rv);
        exit(1);
    }

    rv = pthread_attr_init(&attr);
    if (rv) {
        fprintf(stderr, "pthread_attr_init failed: %d\n", rv);
        exit(1);
    }
    rv = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    if (rv) {
        fprintf(stderr, "pthread_attr_setdetachstate failed: %d\n", rv);
        exit(1);
    }
    rv = pthread_create(&t1, &attr, ping, NULL);
    if (rv) {
        fprintf(stderr, "pthread_create failed: %d\n", rv);
        exit(1);
    }
    rv = pthread_create(&t2, &attr, pong, NULL);
    if (rv) {
        fprintf(stderr, "pthread_create failed: %d\n", rv);
        exit(1);
    }

    rv = pthread_join(t1, NULL);
    if (rv) {
        fprintf(stderr, "pthread_join failed: %d\n", rv);
        exit(1);
    }
    rv = pthread_join(t2, NULL);
    if (rv) {
        fprintf(stderr, "pthread_join failed: %d\n", rv);
        exit(1);
    }
    
    return 0;
}

--------------E22C6A411323F9DB0376196C
Content-Type: text/plain; charset=us-ascii;
 name="ncpus.c.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ncpus.c.txt"

#include <stdio.h>
#include <unistd.h>

int main()
{
    printf("# processors online = %d\n", sysconf(_SC_NPROCESSORS_ONLN));
    return 0;
}

--------------E22C6A411323F9DB0376196C--



