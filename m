From: Keith Owens <kaos@sgi.com>
Date: Fri, 10 Dec 2004 01:21:45 +0000
Subject: Re: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <5284.1102641705@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <15449.1102482344@kao1.melbourne.sgi.com>
In-Reply-To: <15449.1102482344@kao1.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 9 Dec 2004 15:08:35 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>Can't you stash away a reference to the task-structure and bump the
>reference count?   I suspect that might get you into trouble when a
>task exits with first unmapping all MMIO-memory, but that's might not
>be so hard to deal with (when task exits, check whether it has any
>MMIO mappings and if so, kill those, or at least the associated
>registrations first).

Too sensitive to changes in task scheduling and exit code, plus it
requires extra code in the fast path for task exit.  Saving the pid and
the task's start timestamp uses stable data that can be obtained
without any locks.  Apart from exposing the current idle task, my patch
is isolated to ia64 and requires no extra code on any fast path.

