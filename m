From: "ARADHYA, CHINMAYA TM (STSD)" <chinmaya@hp.com>
Date: Tue, 04 May 2004 09:34:35 +0000
Subject: IPC_STAT on ia64
Message-Id: <8BF7471D09AA9B4190A9C96778BC2A170108B854@qcaexc02.asiapacific.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hello,

I noticed that when a 32bit application running on a ia64 system 
makes a shmctl call  with IPC_STAT flag junk data will be filled 
in the shmid_ds structure.
This is on the kernel version - 2.4.18-e.12smp

Sample program to reproduce the problem:

#include <stdio.h>
#include <errno.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#define errmsg(s,no) { printf("*** %s - %s ***\n",s,strerror(no)); 
exit(1); }
#define FTOK_FILENAME "/sbin"
#define PRJ_NO 419
int main()
{
        key_t shmkey;
        int shmid;
        char *shmt=NULL;
        struct shmid_ds shdata;
        if ((shmkey = ftok(FTOK_FILENAME,PRJ_NO)) = -1)
                errmsg("ftok error",errno);
        if ((shmid = shmget(shmkey,1048700,IPC_CREAT|IPC_EXCL|0666)) 
= -1)
                errmsg("shmget error",errno);
        if((shmt=(char*)shmat(shmid,NULL,0)) = -1)
                errmsg("shmat error", errno);
        if(shmctl(shmid,IPC_STAT,&shdata) = 0)
        {
                printf("=Shared mem size=%d=\n",shdata.shm_segsz);
        }
        shmdt(shmt);
        shmctl(shmid,IPC_RMID,0);
}
  
Actual results:
=Shared mem size=1073832704=
Expected results:
=Shared mem size=1048700=


Could anybody tell me how to go about addressing this problem.

TIA
Chinmaya 
 
