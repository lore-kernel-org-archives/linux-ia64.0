From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 Apr 2004 16:06:18 +0000
Subject: RE: Questions on the stack for IA64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F010E2239@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
In-Reply-To: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Another question on this, who allocates the memory for
>the backing store? What if the RSE runs out of memory
>there?

For the user ... the kernel allocates space for RSE.  If it
runs out, then the kernel will grow the vma (just like it
does when you run out of regular stack ... except the RSE
grows up to higher addresses instead of down to lower addresses).

In the kernel the RSE starts just above the task structure and
grows up towards the stack which is growing down from the 
the pt_regs that are allocated at the top of the pages allocated
for the task.  Running out of kernel RSE (or stack) results in
clobbering the switch_stack which lies in between. There is
a pretty ascii picture in include/asm-ia64/ptrace.h

-Tony
