From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 24 Jan 2006 23:25:15 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601242325.k0ONPFg16082@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Friday, January 20, 2006 12:01 PM
> Regarding the direction Ingo sent me down, and considering what Jack
> said about needing a hook for a future platform, I'm thinking of grabbing
> a bit in task->thread.flags that IA64_HAS_EXTRA_STATE() could detect and
> let ia64_{save,load}_extra() call new machvecs to perform this
> chipset-specific context management.  It's a bit overengineered for
> my particular case, but would allow Jack to plug in his work very
> cleanly.

I wonder why you did not continue on this path.  I think the best you
can do is to grab a bit in task->thread.flags, at boot time dynamically
set it to 1 for init_task on sn2 platform and 0 for others, invent a
name something like IA64_THREAD_MMIO_SYNC. Then in switch_to(), you do:

If (t->thread.flags & IA64_THREAD_MMIO_SYNC)
	platform_switch_from(...)

On non-sgi machine, the test will always false, which address most of
the performance concerns from various people (including me).  And on
sn2 platform, it will handle the synchronization in sn2 platform specific
vector.

You can go even one step further that only set the bit for process that
has the MMIO address mapped.  So on sn2, you won't pay the extra cost if
it is not required for most of the processes.  Something workable?

- Ken

