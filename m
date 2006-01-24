From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 24 Jan 2006 21:43:57 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601242143.k0OLhug14696@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Tuesday, January 24, 2006 1:13 PM
> The new patch below implements pretty much exactly that.  I'm not
> thrilled about carrying around the thread_info.last_cpu field even
> on non-SN2, but making the presence/updating of the field conditional
> led to huge headaches in the "should we call platform_switch_from"
> conditionals/logic.

Yeah, I'm not thrilled either.  Currently, on context switch kernel
doesn't read thread_info.cpu, nor any other neighboring field.  With
the patch, it needs to do a cacheline read and possibly an update.
If unlucky, it might be two cache lines with last_cpu 92 bytes away
from thread_info.cpu. Perhaps, last_cpu should be next to cpu field.
On the other hand, it may not be too bad because on kernel exit, flags
field in thread_info is accessed for TIF_* and if kernel exit path is
taken back-to-back with context switch, the net effect maybe small.

- Ken

