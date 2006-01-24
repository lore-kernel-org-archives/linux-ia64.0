From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 22:12:09 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124160438.S90635@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Jan 2006, Chen, Kenneth W wrote:

> Yeah, I'm not thrilled either.  Currently, on context switch kernel
> doesn't read thread_info.cpu, nor any other neighboring field.  With
> the patch, it needs to do a cacheline read and possibly an update.
> If unlucky, it might be two cache lines with last_cpu 92 bytes away
> from thread_info.cpu. Perhaps, last_cpu should be next to cpu field.

Done.

> On the other hand, it may not be too bad because on kernel exit, flags
> field in thread_info is accessed for TIF_* and if kernel exit path is
> taken back-to-back with context switch, the net effect maybe small.

Actually, IA64_HAS_EXTRA_STATE() reads the TIF_* flags, and is called
in __switch_to(), which is in very close proximity to checking last_cpu.
I don't think there'll be a problem here, particularly as I've now moved
last_cpu to neighbor cpu.

Updated patch following in a few minutes.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
