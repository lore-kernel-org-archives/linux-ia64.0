From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Wed, 16 Mar 2005 19:15:32 +0000
Subject: RE: Mprotect needs arch hook for updated PTE settings
Message-Id: <01EF044AAEE12F4BAAD955CB75064943032F10F8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB75064943032C6020@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB75064943032C6020@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davidm@hpl.hp.com

Zoltan Menyhart <> wrote on Wednesday, March 16, 2005 4:58 AM:

> The text segment can be huge. There is no reason to flush all the text
> segment every time when ld-linux-ia64.so.* patches an instruction and
> changes the protection.
> 

You flush only the pages that got written and thus marked for defered
flushing by kernel.  Even though the whole region may have got new
permissions.

> I think the solution should consist of these two measures:
> 
> 1. Let's say that if an VMA is "executable", then it remains
>    "executable" for ever, i.e. the mprotect() keeps the PROT_EXEC bit.
>    As a result, if a page is faulted in for this VMA in the mean
>    time, the old good mechanism makes sure that the I-caches are
> flushed. 
> 
> 2. Let's modify ld-linux-<arch>.so.*: having patched an instruction,
>    it should take the appropriate, architecture dependent measure,
>    e.g. for ia64, it should issue an "fc" instruction.
> 

The generic part of kernel is clearly ensuring that caches and TLBs are
flushed whenever there is any change in permission.  IA-64 specific code
in kernel, when the COW breaks, marks the new page for defered
flushing.....to be used in future if the page ever gets PROT_EXEC.
Later when the app again changes the permission to PROT_EXEC, the arch
specific code in kernel should actually make sure that if a page is
marked for defered flushing then it is done.  

>    (Who cares for a debugger ? It should know what it does ;-).)
> 
> I think there is no need for any extra flushes.

No, there will be no extra flushes.....this hook ensures that IA-64 arch
specific code actually gets the chance to do lazy flushing when
required.

I will be sending an updated patch based on few comments that I got from
Andrew and Linus.

-rohit
