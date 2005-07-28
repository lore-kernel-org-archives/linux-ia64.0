From: Smarduch Mario-CMS063 <CMS063@motorola.com>
Date: Thu, 28 Jul 2005 21:34:19 +0000
Subject: RE: fix possible mm_context wrap-around race
Message-Id: <A752C16E6296D711942200065BFCB6941D79BAAF@il02exm10>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430507252220db22b1c@mail.gmail.com>
In-Reply-To: <ed5aea430507252220db22b1c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a program that exposes the issue on a 2.4
and 2.6 kernel. It pretty easy to reproduce on an 8-way -
takes about 1 or 2 minutes on a 2-way it has not been
reproduced or tried on a 4-way (i.e. no available
system).

- mario
----------------------------

gcc -g -pthread foo.cpp -o foo -lpthread

#include <stdio.h>
#include <errno.h>
#include <pthread.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

void * worker(void *self) {
  int x = -1;
  FILE *pp = 0;
  long junk[8192];
  char buf[1024];

    x = -1;
    errno = 0;
    pp = popen("ls", "r");
    x = errno;
    if(pp) {
      memset(buf, 0, sizeof(buf));
      while(fgets(buf, sizeof(buf)-1, pp) != 0) {
        ;
        }
      pclose(pp);

    }
    else printf("popen failed: %s\n", strerror(errno));
    pthread_exit(NULL);
}

int main(void) {
  pthread_t pt[128];
  pthread_t pthr;
  int x = 0;

  while(1) {
        for (x = 0; x < 5; x++)
                pthread_create(&(pt[x]), 0, worker, (void *)&x);
        for (x = 0; x < 5; x++)
                pthread_join( pt[x], NULL);
        usleep(5000);
        }
  return 0;
}



-----Original Message-----
From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of david mosberger
Sent: Tuesday, July 26, 2005 12:23 AM
To: Luck, Tony
Cc: linux-ia64@vger.kernel.org
Subject: Re: fix possible mm_context wrap-around race


Argh, some day I'll hopefully remember to attach the actual patch...

  --david

On 7/25/05, david mosberger <dmosberger@gmail.com> wrote:
> Tony, since I can't test the patch on anything but a UP machine at 
> this time (which is uninteresting, since the race doesn't trigger 
> there), I'd suggest to put this into the "testing" tree.  Hopefully, 
> somebody could run some tests which involve multi-threaded apps doing 
> a lot of fork/exec'ing.
> 
> Thanks,
> 
>   --david
> --
> Mosberger Consulting LLC, voice/fax: 510-744-9372, 
> http://www.mosberger-consulting.com/
> 35706 Runckel Lane, Fremont, CA 94536
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372, http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
