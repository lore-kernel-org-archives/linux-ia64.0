From: Keith Owens <kaos@sgi.com>
Date: Thu, 20 Nov 2003 04:32:53 +0000
Subject: Re: Problems using psr.dd
Message-Id: <marc-linux-ia64-106930281505028@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106879020623297@msgid-missing>
In-Reply-To: <marc-linux-ia64-106879020623297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 19 Nov 2003 18:39:40 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 14 Nov 2003 17:09:15 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> I am unable to successfully use psr.dd on 2.4 and 2.6
>  Keith> kernels.  The patches below plus the debug.c module
>  Keith> demonstrate the problem.  do_trap29() sets regs->cr_ipsr.dd
>  Keith> and returns.  The kernel drops through ia64_leave_kernel,
>  Keith> loads the modified ipsr and does rfi.  However the same debug
>  Keith> fault occurs again, as if psr.dd were being ignored.
>
>  Keith> What am I missing?
>
>Did you find the answer already?

No, your response is the only one so far.

>I'm wondering if the problem would still occurr if the
>debug-fault-triggering memory access was in a function with an empty
>register frame.

Like this?  It makes no difference, trap29 just keeps occuring, even
though psr.dd is being set..

static void set_victim(void)
{
        victim = 1;
 300:   0d 78 00 02 00 24       [MFI]       addl r15=0,r1
                        300: GPREL22    victim
 306:   00 00 00 02 00 c0                   nop.f 0x0
 30c:   11 00 00 90                         mov r14=1;;
 310:   1d 00 38 1e 90 11       [MFB]       st4 [r15]=r14
 316:   00 00 00 02 00 80                   nop.f 0x0
 31c:   08 00 84 00                         br.ret.sptk.many b0;;

}

Forgot to mention, this is on a vanilla McKinley box, not a SN2.

# cat /proc/cpuinfo 
processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 0
revision   : 5
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 897.454998
itc MHz    : 897.454998
BogoMIPS   : 1342.17
...

