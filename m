From: Don Dugger <n0ano@valinux.com>
Date: Fri, 11 May 2001 21:12:10 +0000
Subject: Re: [Linux-ia64] call to sysinfo in ia32 mode trashes the stack
Message-Id: <marc-linux-ia64-105590693005570@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jose-

Not yet, it's on my todo list.

On Fri, May 11, 2001 at 10:57:17PM +0200, Jose Luu wrote:
> 
> 
> I noticed the above problem using kernel 2.4.1. Is it solved in 2.4.4 ?
> 
> Thanks
> Jose
> 
> ------------------------------ test
> program ------------------------------------
> 
> #include <stdio.h>
> #include <sys/sysinfo.h>
> 
> typedef struct {
> 
>     unsigned int dwTotalPhys ;
>     unsigned int dwAvailPhys ;
>     unsigned int dwTotalPageFile ;
>     unsigned int dwAvailPageFile ;
> }  MEMORYSTATUS;
> 
> int Memory(MEMORYSTATUS *lpmstMemStat)
> {
> #if defined(AIR_BAG)
>     char szBuffer[1000];
> #endif
> 
>       struct sysinfo info;
> 
>        if(sysinfo(&info))
>                return 1;
>        lpmstMemStat->dwTotalPhys = info.totalram;
>        lpmstMemStat->dwAvailPhys = info.freeram;
>        lpmstMemStat->dwTotalPageFile = info.totalswap;
>        lpmstMemStat->dwAvailPageFile = info.freeswap;
>        return 0;
> }
> 
> main ()
> {
>     MEMORYSTATUS mem;
>     if (Memory(&mem) != 0) {
> fprintf(stderr,"error\n");
>     }
>     fprintf(stderr,"Total Phys %u\n",mem.dwTotalPhys);
>     fprintf(stderr,"Avail Phys %u\n",mem.dwAvailPhys);
>     fprintf(stderr,"Total PageFile  %u\n",mem.dwTotalPageFile);
>     fprintf(stderr,"Avail PageFile  %u\n",mem.dwAvailPageFile);
> }
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

