From: Jack Steiner <steiner@sgi.com>
Date: Wed, 03 Apr 2002 21:43:37 +0000
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Message-Id: <marc-linux-ia64-105590701905372@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I isolated the strncpy problem to a simple test program. It fails
with the new glibc-2.2.4-19.3 within a few seconds.

Works fine with older versions of glibc.




David Mosberger took a look at the strncpy code & spotted
the error:

From David:
>> I took a closer look and there seem to be several bugs in the routine:
>> 
>>  (1) I don't think it's save to do:
>> 
>>                 chk.s r[MEMLAT], .recovery3
>>                 mov value = r[MEMLAT]
>> 
>>      in the same cycle.  In the patch below, I fixed this by adding a
>>      stop bit, but obviously it would be better to avoid that (either
>>      by re-ordering the code or by adding a pipeline stage).
>> 
>>  (2) stop bit was missing after br.cloop.dptk
>> 
>>  (3) off-by-one error in .recovery4 code: the destination should be
>>      r[MEMLAT-1], not r[MEMLAT]
>> 
>>  (4) I believe the address calcuation in .recovery3 and .recovery4 may
>>      also be off by 8; this is just based on eye-balling the code though,
>>      so I may be wrong
>> 
>> Hope this helps,
>> 
>>         --david
>> 


---- 
Test case - run ~12 copies of this in parallel.

#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <time.h>

char *dest, *src;

void
sigill_handler(int sig)
{
        fprintf(stderr,"SIGILL: pid %d, dest 0x%lx, src 0x%lx\n",
                getpid(), (long)dest, (long)src);
        exit(1);
}

int
main() {
  time_t temp1;
  char *p, buffer[1024];

  signal(SIGILL, sigill_handler);
  
  time(&temp1);
  src = ctime(&temp1);

  dest = buffer;

  printf("%d\n", strlen(src));

  while(1)
      strncpy(buffer,src,strlen(src));
}


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


