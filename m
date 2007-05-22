From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 22 May 2007 12:47:13 +0000
Subject: is TIF_NOTIFY_RESUME used?
Message-Id: <20070522124713.GB27428@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, Stephane Eranian <eranian@hpl.hp.com>, ak@suse.de, akpm@linux-foundation.org, tony.luck@intel.com

Hello,

For perfmon, we need a couple of TIF bits. It seems that with 2.6.22-rc2
there is now a TIF_RESTORE_SIGMASK which uses the last remaining bit in the
first 7 bits of the thread flag. Many architectures, including IA-64, rely
on the fact that some of the TIF flags (TIF_ALL_WORKMASK or TIF_ALL_WORK)
tested on kernel exit reside in the low 8-bit or 7-bit because they use
instructions (such as add r1=imm8,r2 on IA-64) which operate on 8 or 7 bit
immediate.

On IA-64, adding that one perfmon flag (as bit 7) would cause some
restructuring in the kernel exit path but also in all the lightweight syscall
handlers.

I looked at all the low order TIF flags and found that TIF_NOTIFY_RESUME 
was never set nor used anywhere in any architecture. Is that really the case?

If so, we could get rid of it and free up one low-order TIF bit.

Thanks.

-- 
-Stephane
