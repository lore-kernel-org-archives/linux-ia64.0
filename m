From: Umut Aymakoglu <umuta@us.ibm.com>
Date: Fri, 29 Aug 2003 00:04:10 +0000
Subject: shmat() ... is it a bug?
Message-Id: <marc-linux-ia64-106211685507764@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





Hi -
 Below ,I have 2 small programs which shows a problem in shmat() when the
executable linked with the curses library(libncurses). Has anybody seen
something like this?

a.c --> allocates a shared memory segment and attaches.
b.c --> attaching the allocated shared memory segment using the address
from a.c

thanks,
Umut


a.c:
-----
#include <stdio.h>
#include <sys/types.h>
#include <sys/shm.h>

main()
{

unsigned int segsize = 512*1024;
int                     shmid;
key_t               shmkey = 123456789;
void * adr;

shmid = shmget(shmkey, segsize,IPC_CREAT|0660);
adr = shmat(shmid, 0,0);

printf("shmid = %d  adr = %p\n",shmid, adr);
}


b.c:
-----
#include <stdio.h>
#include <stdlib.h>
#include<sys/types.h>
#include <sys/shm.h>

main(int argc, char **argv)
{
 void * addr1, * addr2;
key_t  shmkey = 123456789;
int shmid;

addr1 = (void*) strtoul(argv[1],NULL,0);
shmid = shmget(shmkey, 0, 0660);

addr2 = shmat(shmid, addr1, 0);
printf("addr2 = %p\n",addr2);
}

%gcc3 -o a a.c
%gcc3 -o b b.c
%gcc3 -o c b.c -lncurses

% ./a
shmid = 313556996 adr = 0x2000000000300000

%./b 0x2000000000300000
addr2 = 0x2000000000300000

%./c 0x2000000000300000
addr2 = 0xffffffffffffffff


