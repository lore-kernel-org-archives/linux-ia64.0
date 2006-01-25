From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 25 Jan 2006 00:10:31 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124175543.K90635@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Jan 2006, Chen, Kenneth W wrote:

> Brent Casavant wrote on Tuesday, January 24, 2006 3:29 PM
> > Take 4.  Moved "really migrated?" check as late as possible in
> > __switch_task(), and moved thread_info last_cpu field closer to
> > flags and cpu fields.  Some nomenclature changes as well.
> 
> I think you should seriously consider my other proposal :-)

Well... if Ingo is amenable to the arch hook in the scheduler, I'm
OK with changing directions.  Again.  :-)

The arch hook would be a lot simpler this time -- simply setting
a flag instead of performing the PIO write drain.  Not sure if
that's enough to argue in favor of the hook or not.

Truth be told, I have no strong preference either way.  I'd just
like to break out of this Brownian motion.  :-)

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
