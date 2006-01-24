From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 16:52:38 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124105029.G90635@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Jan 2006, Grant Grundler wrote:

> On Tue, Jan 24, 2006 at 12:30:42AM -0600, Brent Casavant wrote:
> > The only obvious marker I can thing of would be a flag in the
> > mm struct set by a device driver when such a mapping occurs.
> 
> Device driver? Your original email only talks about user space:
> http://marc.theaimsgroup.com/?l=linux-ia64&m3771591308925&w=2

Right.  But the whole situation occurs when user space mmap()s
an IO device (e.g. a PCI aperture).  That mmap() call triggers
kernel device driver mmap code to take place, and that is where
the flag would need to be set.

Sorry I wasn't clear about that.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
