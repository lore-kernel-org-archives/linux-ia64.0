From: "Saxena, Sunil" <sunil.saxena@intel.com>
Date: Mon, 11 Nov 2002 02:56:12 +0000
Subject: RE: [Linux-ia64] Newbie questions
Message-Id: <marc-linux-ia64-105590709805378@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805370@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805370@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The Software conventions document is at
http://developer.intel.com/design/itanium/downloads/245358.htm 

All documents can now be found at
http://developer.intel.com/design/itanium/arch_spec.htm 

Thanks
Sunil
-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
Sent: Friday, November 08, 2002 11:09 AM
To: CH Gowri Kumar
Cc: 'linux-ia64@linuxia64.org '
Subject: Re: [Linux-ia64] Newbie questions

>>>>> On Sat, 9 Nov 2002 00:21:40 +0530 (IST), CH Gowri Kumar
<gkumar@csa.iisc.ernet.in> said:

  Gowri> char sc[] ="\x0a" "\x10" "\x00"
  Gowri> "\x18\x00\x21\x00\x92\x00\x00\x42\xe0\x11\x00\x20\x84\x0a";
  Gowri> main() { void (*fp)(void); fp = (void*)sc; fp(); }

  Gowri> But this program on execution gives me the error: "Illegal
  Gowri> instruction (core dumped)" (A similar program for IA-32
  Gowri> worked well.)

  Gowri> I couldn't figure out what could be the problem.  I also
  Gowri> tried using "br instruction" approach instead of the function
  Gowri> pointer approach, but couldn't succeed.

  Gowri> Can anyone explain why it is failing or atleast give me
  Gowri> pointers where to look for?

You'll want to read the software convention manual, especially that
portion talking about function descriptors.  The manual is normally
available at:

	http://www.intel.com/design/Itanium/arch_spec.htm

Unfortunately, the URL it points to
(http://www.intel.com/design/itanium/downloads/24535803s.htm) is
currently broken.  [Could someone from Intel look into getting this
fixed?]

But briefly, a function descriptor consists of (at least) two words:
the first one being the entry point (instruction address) and the
second one being the global pointer.  I attached a small test program
that demos "dynamic" code generation (note: instruction bundles must
be aligned to 16-byte boundary, which wasn't guaranteed in your test
program).

	--david

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <malloc.h>

#include <sys/mman.h>

#ifdef __ia64__
typedef struct _fp
{
  long addr;
  long gp;
} IA64_FUNCTION;

static void flush_cache (void *addr, unsigned long len)
{
  void *end = (char *) addr + len;

  while (addr < end)
    {
      asm volatile ("fc %0" :: "r"(addr));
      addr = (char *) addr + 32;
    }
  asm volatile (";;sync.i;;srlz.i;;");
}
#endif

void TestApp(void)
{
#ifdef __ia64__
  __asm__ __volatile__ ("nop.i 0");
  __asm__ __volatile__ ("nop.i 0");
  __asm__ __volatile__ ("nop.i 0");
  __asm__ __volatile__ ("nop.i 0");
#else
  __asm__ __volatile__ ("nop");
#endif
  return;
}

int main(int argc, char *argv[])
{
  void (*pSubroutine)(void);
  unsigned char *pBuffer1;
  long alignment;
#ifdef __ia64__
  IA64_FUNCTION *fp;
  IA64_FUNCTION newfp;
#endif

  printf("Test ***\n");

  malloc(0x10000);

  // Allocate and align buffer on 16 byte boundary
  pBuffer1 = (unsigned char *)malloc(0x1000);
  alignment = ((unsigned long)pBuffer1 % 16);
  pBuffer1 = pBuffer1 + 16 - alignment;

#ifdef __ia64__
  fp = (IA64_FUNCTION *)TestApp;
  printf("pSub Addr = 0x%lX GP = 0x%lX\n", fp->addr, fp->gp);
  memcpy(pBuffer1, (unsigned char *)fp->addr, 256);
  flush_cache(pBuffer1, 0x1000);

  newfp.gp = fp->gp;
  newfp.addr = (long)pBuffer1;
  printf("pSub Addr = 0x%lX GP = 0x%lX\n", newfp.addr, newfp.gp);
  pSubroutine = (void (*)(void))&newfp;

  mprotect((void *) ((long) pBuffer1 & ~(getpagesize () - 1)),
	   getpagesize(), PROT_READ | PROT_WRITE | PROT_EXEC);
#else
  printf("pSub Addr = 0x%lX\n", pBuffer1);
  memcpy(pBuffer1, &TestApp, 32);
  pSubroutine = (void (*)(void)) pBuffer1;
#endif

  (*pSubroutine)();

  printf ("done!\n");
  return(0);
}

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

