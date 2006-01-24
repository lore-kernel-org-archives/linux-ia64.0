From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 06:30:42 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124001932.Q80998@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Jan 2006, Grant Grundler wrote:

> Would an app first need to mmap an uncached address?
> Or some other obvious "marker" that might warn the kernel?

I'm not sure an uncached address would be appropriate, as I
believe there are other non-IO uncached mappings which can
be performed (whatever the fetchop stuff morphed into, for
example -- I can't remember what its called now).

The only obvious marker I can thing of would be a flag in the
mm struct set by a device driver when such a mapping occurs.
All relevant device drivers would need to be updated, and we'd
need to handle partial unmappings, shared mappings and the like.

> I'm wondering if one could check some easily reachable state
> (or flag) before calling platform_switch_from() and thus
> mitigate Tony's concern.

I can't think of any obviously correct state/flag to inspect,
short of the other suggestion I made tonight.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
