From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 16 Mar 2005 12:58:04 +0000
Subject: Re: Mprotect needs arch hook for updated PTE settings
Message-Id: <42382D5C.1030104@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB75064943032C6020@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB75064943032C6020@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davidm@hpl.hp.com

An application should not change the protection of its _own_ text region
without knowing well the requirements of the given architecture.
I do not think we should add anything into the kernel for this case.

I did see /lib/ld-linux-ia64.so.* changing the protection of the text
segment of the _victim_ application, when it linked the library references.
ld-linux-ia64.so.* changes the protection for the whole text segment
(otherwise, as the protection is per VMA, it would result in a VMA
fragmentation).
The text segment can be huge. There is no reason to flush all the text
segment every time when ld-linux-ia64.so.* patches an instruction and
changes the protection.

I think the solution should consist of these two measures:

1. Let's say that if an VMA is "executable", then it remains "executable"
   for ever, i.e. the mprotect() keeps the PROT_EXEC bit.
   As a result, if a page is faulted in for this VMA in the mean time, the
   old good mechanism makes sure that the I-caches are flushed.

2. Let's modify ld-linux-<arch>.so.*: having patched an instruction, it
   should take the appropriate, architecture dependent measure, e.g. for
   ia64, it should issue an "fc" instruction.

   (Who cares for a debugger ? It should know what it does ;-).)

I think there is no need for any extra flushes.

Thanks,

Zoltan Menyhart
