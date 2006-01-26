From: Brent Casavant <bcasavan@sgi.com>
Date: Thu, 26 Jan 2006 20:28:15 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060126142503.U40136@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 26 Jan 2006, Luck, Tony wrote:

> Perhaps "SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK" is just a bit too
> verbose/descriptive?  44 characters in a name is just asking for problems
> in an 80 column environment.

I agree.  As changing that name would mean mixing what's essentially
a coding style cleanup with a "meaty" change, how would you like me
to proceed?

As I mentioned earlier in this discussion, there are some changes
needed in the area of mmiowb(), which is the primary user of this
definition.  Perhaps such a change is best left for that effort?

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
