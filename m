From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 03 Feb 2003 21:36:26 +0000
Subject: Re: [Linux-ia64] Preempt problems
Message-Id: <marc-linux-ia64-105590709805803@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805801@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805801@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter,

On Tue, Feb 04, 2003 at 07:17:01AM +1100, Peter Chubb wrote:
> 
> Hi David,
>    Just a heads up --- there are still two major problems with the
> patch I submitted for preemption support, so I suggest you don't merge
> it yet (although I'd very much appreciate having it reviewed and
> tested by third parties).
> 
> The two problems I see are:
>     -- perfmon missing interrupts *even with CONFIG_PREEMPT turned
> off!*

As for perfmon, there are some known issues with perfmon and the O(1) 
scheduler (deadlocks during ctxsw in SMP). I am not sure it affects your 
particular test case. I had postponed fixing this because I am working on 
a new perfmon code base for 2.5 in which (hopefully) all problems are gone. 
However a somewhat related issue came up last week and I decided to fix 
some of the problems. I will try to give a new patch to David this week.

As for preemption and perfmon, I haven't had a chance to look at the patch
yet. There are some assumptions about not being preemptable at several places.

-- 
-Stephane

