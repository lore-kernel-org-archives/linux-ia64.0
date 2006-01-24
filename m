From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 24 Jan 2006 22:19:15 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601242219.k0OMJFg15207@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Tuesday, January 24, 2006 2:12 PM
> > On the other hand, it may not be too bad because on kernel exit, flags
> > field in thread_info is accessed for TIF_* and if kernel exit path is
> > taken back-to-back with context switch, the net effect maybe small.
> 
> Actually, IA64_HAS_EXTRA_STATE() reads the TIF_* flags, and is called
> in __switch_to(), which is in very close proximity to checking last_cpu.

Where??

IA64_HAS_EXTRA_STATE() uses task->thread.flags, not task->thread_info->flags.
These two flags are in two different places.

- Ken

