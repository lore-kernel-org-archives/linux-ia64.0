From: Martin Hicks <mort@bork.org>
Date: Fri, 06 Feb 2004 17:44:13 +0000
Subject: Re: [PATCH] SN - fix pxm_to_nasid() for large machines
Message-Id: <20040206174413.GC21486@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206173838.GB21486@localhost>
In-Reply-To: <20040206173838.GB21486@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Fri, Feb 06, 2004 at 12:38:38PM -0500, Martin Hicks wrote:
> 
> Hi,
> 
> This is a patch for SN2 that fixes up pxm_to_nasid() for big machines.
> Compile and boot tested.  The patch is against the latest 2.6 bitkeeper.

Jbarnes pointed out to me moments after I sent this out that the basic
patch is already in -mm

Sorry.

> I also marked sn_init_pdas as __init, because it is.

I'll send a patch that adds the __init to these two functions.

mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE
