From: "Jose Luu" <jluu@mainsoft.com>
Date: Fri, 11 May 2001 20:57:17 +0000
Subject: [Linux-ia64] call to sysinfo in ia32 mode trashes the stack
Message-Id: <marc-linux-ia64-105590693005569@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I noticed the above problem using kernel 2.4.1. Is it solved in 2.4.4 ?

Thanks
Jose

------------------------------ test
program ------------------------------------

#include <stdio.h>
#include <sys/sysinfo.h>

typedef struct {

    unsigned int dwTotalPhys ;
    unsigned int dwAvailPhys ;
    unsigned int dwTotalPageFile ;
    unsigned int dwAvailPageFile ;
}  MEMORYSTATUS;

int Memory(MEMORYSTATUS *lpmstMemStat)
{
#if defined(AIR_BAG)
    char szBuffer[1000];
#endif

      struct sysinfo info;

       if(sysinfo(&info))
               return 1;
       lpmstMemStat->dwTotalPhys = info.totalram;
       lpmstMemStat->dwAvailPhys = info.freeram;
       lpmstMemStat->dwTotalPageFile = info.totalswap;
       lpmstMemStat->dwAvailPageFile = info.freeswap;
       return 0;
}

main ()
{
    MEMORYSTATUS mem;
    if (Memory(&mem) != 0) {
fprintf(stderr,"error\n");
    }
    fprintf(stderr,"Total Phys %u\n",mem.dwTotalPhys);
    fprintf(stderr,"Avail Phys %u\n",mem.dwAvailPhys);
    fprintf(stderr,"Total PageFile  %u\n",mem.dwTotalPageFile);
    fprintf(stderr,"Avail PageFile  %u\n",mem.dwAvailPageFile);
}



