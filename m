From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 16 Oct 2002 05:52:15 +0000
Subject: Re: [Linux-ia64] Re: loading a kernel module
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------5714BA46F0D9EDBB2EA7DBE8"
Message-Id: <marc-linux-ia64-105590709805170@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805162@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805162@msgid-missing>
To: linux-ia64@vger.kernel.org

Dies ist eine mehrteilige Nachricht im MIME-Format.
--------------5714BA46F0D9EDBB2EA7DBE8
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Keith Owens schrieb:

> On 15 Oct 2002 14:57:07 -0400,
> Jim Wilson <wilson@redhat.com> wrote:
> >You can get brl instructions by changing "#undef USE_BRL" to "#define USE_BRL"
> >in the BINUTILS bfd/elfxx-ia64.c file.  I believe that is the change that went
> >into the RHL AS toolchain.  Then write a large enough program, so that you
> >have a call site that is far enough away from its call target to require brl.
>
> You don't need a large program.  The test object from Christian Hildner
> is about as small as it gets and it still uses brl.  Christian, please
> post the source of the test object to the list.

Keith, Jim,

the source isn't that complex as you might have seen in the length of the objdump output.
The object I have given you is only a small test program to find out the missing linkage for
brl branches. My original program needs brl to branch across virtual pages with a big
difference in the virtual addresses. So the test prog never makes any sence, but shows the
missing R_IA64_PCREL60B nicely.

Christian

PS: Here is the source without any guarantee not to crash ...

--------------5714BA46F0D9EDBB2EA7DBE8
Content-Type: image/x-xbitmap;
 name="crash.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="crash.c"

#define MODULE
#include <linux/module.h>

int dummy(void)
{
    return 0;
}

int init_module(void)
{
    printk("Init Module starting. About to crash...\n");
    asm volatile ("brl dummy ");
    return 0;
}

void cleanup_module(void)
{
    printk("Done\n");
}



--------------5714BA46F0D9EDBB2EA7DBE8--


