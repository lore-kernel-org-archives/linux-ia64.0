From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 20 Jul 2002 19:15:59 +0000
Subject: [Linux-ia64] Re: [PATCH]: scheduler complex macros fixes
Message-Id: <marc-linux-ia64-105590701905793@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 19 Jul 2002, mgross wrote:

> Thats too bad.  I've been looking at Ingo's SCHED_BATCH design to help
> suspend processes with out lock problems while doing multithreaded core
> dumps.
> 
> Is there any ETA on the return path to user mode clean up?

oh, there's no fundamental problem here, i'm doing the return-path-cleanup
patch too :-) [which, as a side-effect, also removes the global irq lock.]
I temporarily suspended it for the sake of the SCHED_BATCH feature and
other scheduler maintainance work. But it just got higher priority, so ...

	Ingo


