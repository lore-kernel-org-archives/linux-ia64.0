From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 02 Feb 2002 00:21:34 +0000
Subject: Re: [Linux-ia64] O(1) MQ scheduler J9 patch for IA64
Message-Id: <marc-linux-ia64-105590698805981@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805977@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805977@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 1 Feb 2002 15:45:32 +0100 (MET), 
Erich Focht <efocht@ess.nec.de> wrote:
>please find attached a patch which aplies to
>
>linux-2.4.17 + kdb_common + ia64_patch + kdb_ia64 + sched-O1-2.4.17-J9.patch
>
>I had to add a function smp_call_function_nowait which sends an IPI and
>returns immediately in order to get rid of a IA64-specific race condition
>when the mmu_context wraps around. Now it makes a very stable and fast
>impression, interactive work is even possible while doing a "hackbench
>55" and ping flooding the machine... Tested on 2 CPU BigSur, 4 CPU LION,
>16 CPU AzusA.

Why is there a global change of current->processor to current->cpu?
That has knock on effects because #define cpu and references to that
macro also have to be changed.  I don't see any benefit.


