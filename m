From: Keith Owens <kaos@sgi.com>
Date: Sat, 20 Dec 2003 00:26:12 +0000
Subject: Re: [patch] 2.6.0 MCA TLB error recovery
Message-Id: <marc-linux-ia64-107188004426028@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107181047921141@msgid-missing>
In-Reply-To: <marc-linux-ia64-107181047921141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 19 Dec 2003 16:04:14 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>DavidM wroe
>> I didn't keep the old patches around.  Could you and Keith send me a
>> consistent set of patches?  That would help me.
>> 
>
>Keith's second fix:
>smp_call_function() must not be called from interrupt context (can
>deadlock on tasklist_lock).  Use keventd to call smp_call_function().
>Index: 23.5/arch/ia64/kernel/mca.c

Do not apply this patch to 2.6, it is for 2.4 only.  2.6 uses different
structure and function names, plus the patch needs tweaking for
preempt.

David, please apply the first mca/salinfo patch to your tree (Forward
port the recent changes to pal.h, sal.h, mca.h, salinfo.c and mca.c
from 2.4.23-rc2 to 2.6.0-test9), then I will do a 2.6 version of the
second patch over the top.

