From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 03 Aug 2004 16:32:29 +0000
Subject: RE: Multiple Processors on OS_MCA
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01C61FD4@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>2.6.7 kernel/mca_asm.S serializes processors at the entry and exit of
>the OS_MCA with a spinloop, hence makes sure only one 
>processor performs the OS_MCA at a time.
>A processor toggles the spinloop var before exiting OS_MCA so that
>another processor spinning on the entry can proceed to OS_MCA.

That wasn't intended to be a final solution ... just a temporary fix
to make sure that two processors couldn't enter the kernel at the
same time (which would lead to chaos in the current implementation
because we only have one block of memory declared to save registers,
use a stack etc.).

>My question is about the SAL behavior (or OS_MCA behavior) on multiple
>processors returnings to SAL after OS_MCA. 
>Here's a typical OS_MCA snapshot after global events; the first
>processor just returns to SAL w/ IA64_MCA_COLD_BOOT, a second processor
>proceeds to OS_MCA, and other processors are still spinning at the
>entry.
>
>In this scenario, does SAL just cold boot the system on the first
>processor's return, or wait for all processors that were sent to OS_MCA
>to return after they all completed OS_MCA? 
>If SAL doesn't do the wait, does OS_MCA need to synchronize the
>processors on exit so that they all complete OS_MCA in sequence before
>returning to SAL?

I would expect that when the first cpu returns to SAL with the COLD_BOOT
request, that the system will be rebooted right away ... but I suppose
it might be SAL implementation dependent.

-Tony
