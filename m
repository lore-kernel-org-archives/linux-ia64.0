From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 04 Jan 2002 22:36:50 +0000
Subject: [Linux-ia64] Re: IA64 Kernel Question
Message-Id: <marc-linux-ia64-105590698805741@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[I'm cc'ing the reply to linux-ia64 in the hope that it goes through,
 as I think this might be of interest to others.]

Rob,

I haven't tried running your code, but from looking at it, it appears
that it fails to establish coherency with the i-cache.  With gcc, you
can use a routine along the lines of:

static void
flush_cache (void *addr, unsigned long len)
{
  void *end = (char *) addr + len;

  while (addr < end)
    {
      asm volatile ("fc %0" :: "r"(addr));
      addr = (char *) addr + 32;
    }
  asm volatile (";;sync.i;;srlz.i;;");
}

For example, a call of the form:

	flush_cache(pBuffer1, 0x1000);

should do.

The reason this is needed is that on ia64, CPU local stores are not
coherent with respect to i-cache fetches (everything else *is*
cache-coherent).

The memory allocated by malloc() does indeed have execute permission
turned on.  Linux does this for historical reasons.  One performance
caveat: when executing malloc()'d memory, you'll get one additional
page fault for each page that is actually executed so it is
advantageous to use as few pages as possible for dynamicaly generated
code.

If your code is multi-threaded, there are additional consideration to
ensure all CPUs see the right version of the code at the right time.
See the IA-64 architecture manual for details.

Hope this helps,

	--david

>>>>> On Fri, 4 Jan 2002 16:02:44 -0600, "Matthews, Robert" <Robert.Matthews@compaq.com> said:

  Rob> David,
  Rob> I am sorry for sending this directly to you, but I am unable to send
  Rob> email to the IA64 kernel list for some reason.  I thought you may know
  Rob> the answer off hand, or could forward it to the list for me.

  Rob> I have noticed a problem when trying to execute code in a user mode app
  Rob> from an allocated buffer.  The code below does a malloc to get a buffer,
  Rob> and then copies code from another function to the buffer.  Being careful
  Rob> to treat function pointers properly as structures, I believe that the
  Rob> buffer function is called properly.    
  Rob> Unfortunately it seg faults upon execution, although it does at least
  Rob> display the correct fault address.  Is using the same GP value from the
  Rob> other function the correct thing to do in a case like this?  Is the
  Rob> memory region user mode malloc uses being set to allow execution?
  Rob> Perhaps there is something else that needs to be done in my code to
  Rob> allow this to work.  I would appreciate any insights anyone might have.


  Rob> Rob


  Rob> #include <stdio.h>
  Rob> #include <stdlib.h>
  Rob> #include <string.h>
  Rob> #include <malloc.h>

  Rob> typedef struct _fp
  Rob> {
  Rob> long addr;
  Rob> long gp;
         
  Rob> } IA64_FUNCTION;

  Rob> void TestApp(void)
  Rob> {
   
  Rob> __asm__ __volatile__ ("nop.i 0");
  Rob> __asm__ __volatile__ ("nop.i 0");
  Rob> __asm__ __volatile__ ("nop.i 0");
  Rob> __asm__ __volatile__ ("nop.i 0");
   
  Rob> return;
  Rob> }   

  Rob> int main(int argc, char *argv[])
  Rob> {
  Rob> void  
  Rob> (*pSubroutine)(void);   
  Rob> unsigned char
  Rob> *pBuffer1;
  Rob> long
  Rob> alignment;
         
  Rob> IA64_FUNCTION *fp;
  Rob> IA64_FUNCTION newfp;
   
  Rob> printf("Test ***\n");
   
  Rob> // Allocate and align buffer on 16 byte boundary
  Rob> pBuffer1 = (unsigned char *)malloc(0x1000);
  Rob> alignment = ((unsigned long)pBuffer1 % 16);
  Rob> pBuffer1 = pBuffer1 + 16 - alignment;
   
  Rob> fp = (IA64_FUNCTION *)TestApp;
  Rob> printf("pSub Addr = 0x%lX GP = 0x%lX\n", fp->addr, fp->gp);
   
  Rob> memcpy(pBuffer1, (unsigned char *)fp->addr, 256);
   
  Rob> newfp.gp = fp->gp;
  Rob> newfp.addr = (long)pBuffer1;
  Rob> printf("pSub Addr = 0x%lX GP = 0x%lX\n", newfp.addr, newfp.gp);
  Rob> pSubroutine = (void (*)(void))&newfp;

  Rob> (*pSubroutine)();

  Rob> return(0);
  Rob> }


