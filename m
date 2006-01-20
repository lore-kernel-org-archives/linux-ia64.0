From: Brent Casavant <bcasavan@sgi.com>
Date: Fri, 20 Jan 2006 20:01:24 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060120134424.E91550@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
 <200601191818.43157.jbarnes@virtuousgeek.org> <20060120003303.O81637@chenjesu.americas.sgi.com>
 <200601200936.21111.jbarnes@virtuousgeek.org>
In-Reply-To: <200601200936.21111.jbarnes@virtuousgeek.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jes@sgi.com, tony.luck@intel.com

On Fri, 20 Jan 2006, Jesse Barnes wrote:

> Of course, the other option is just to require tasks that do MMIO 
> accesses from userspace to be pinned to particular CPU or node. :)

One idea I had was to add a counter into the mm struct that gets
bumped if the process performs any MMIO mappings, so that only
affected processes pay the penalty.  However, the added complexity
in the drivers (e.g. handling partial unmaps, etc.) doesn't seem worth
it.  On average this code adds 800ns to the task migration path, which
is relatively infrequent and already a bit expensive (what with cold
caches and the like).

Regarding the direction Ingo sent me down, and considering what Jack
said about needing a hook for a future platform, I'm thinking of grabbing
a bit in task->thread.flags that IA64_HAS_EXTRA_STATE() could detect and
let ia64_{save,load}_extra() call new machvecs to perform this
chipset-specific context management.  It's a bit overengineered for
my particular case, but would allow Jack to plug in his work very
cleanly.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
