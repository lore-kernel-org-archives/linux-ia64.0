From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Fri, 25 May 2001 23:17:37 +0000
Subject: [Linux-ia64] Bug report: 4-threaded program gets seg. fault on malloc, on linu
Message-Id: <marc-linux-ia64-105590693005668@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have reported this on bugzilla also, Bug #42354.  I don't know whether it
is
a kernel bug, libc, or libpthread.
The attached program spawns 3 new threads, and each of the 4 threads does a
malloc.  Run it on a 4P Lion.
On Linux kernel R2.4.3 (Red Hat release 7.0.98), it aborts with a
segmentation fault.  The same binary executable runs correctly on a R2.4.1
kernel.


#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>   
#include <asm/page.h>

#define MAXPROCS        4

void SlaveStart();

typedef struct
{
        volatile int bt_count0;
        volatile int bt_count1;
} barrier_t;

static pthread_mutex_t barrier_lock;
pthread_mutex_t (idlock);
int id = 0;
barrier_t start;
barrier_t end;
static int threadno = 0;
static pthread_t thread[MAXPROCS];


void
init_barrier(barrier_t *barr)
{
	pthread_mutex_init(&(barrier_lock), (const pthread_mutexattr_t *)0);
	barr->bt_count0 =  barr->bt_count1 = 0;
}

void
wait_barrier(barrier_t *barr, int nprocs)
{
	int rc;

	/* Two barriers guarantee that no one comes around to the barrier
	 * again before everyone is out if it, even if there are long
	 * delays in the kernel.
 	 */
	rc = pthread_mutex_lock(&barrier_lock);
	if (barr->bt_count0 = nprocs)
		barr->bt_count0 = 1;
	else
		++barr->bt_count0;
	rc = pthread_mutex_unlock(&barrier_lock);
	while (barr->bt_count0 < nprocs){
		;
	}

	rc = pthread_mutex_lock(&barrier_lock);
	/* If this has been called before, re-initialize the counter */
	if (barr->bt_count1 = nprocs)
		barr->bt_count1 = 1;
	else
		++barr->bt_count1;
	rc = pthread_mutex_unlock(&barrier_lock);
	while (barr->bt_count1 < nprocs){
		;
	}
}

main(argc, argv)

int argc;
char *argv;

{
  int i; 
  int j; 
  int c;
  int status;
  pthread_attr_t *attr = 0;

  init_barrier(&start);
  init_barrier(&end);

  for (i=1; i<MAXPROCS; i++) {
    status = pthread_create(&thread[threadno++], attr,(void
*)(SlaveStart),(void *)0);

  }
  SlaveStart();


  {exit(0);};
}


void SlaveStart()
{
  int i;
  int j;
  int MyNum;
  double error;
  double *upriv;
  int initdone; 
  int finish; 
  int l_transtime=0;
  int MyFirst; 
  int MyLast;

  {pthread_mutex_lock(&(idlock));};
    MyNum = id;
    id++;
  {pthread_mutex_unlock(&(idlock));}; 



  {wait_barrier((barrier_t *)&(start), (MAXPROCS));};

printf("Calling malloc: %d\n", MyNum);
  upriv = (double *) malloc(2*(28000000-1)*sizeof(double));  
  if (upriv = NULL) {
    fprintf(stderr,"Proc %d could not malloc memory for upriv\n",MyNum);
    exit(-1);
  }
printf("Called malloc: %d\n", MyNum);
  {wait_barrier((barrier_t *)&(end), (MAXPROCS));};
}


