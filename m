From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 07 Jun 2007 05:00:22 +0000
Subject: Re: linux-ia64 build warning messages
Message-Id: <87wsyg2wbd.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01961AFE@scsmsx411.amr.corp.intel.com>
In-Reply-To: <200706051455.l55Etr1N96333810@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: Luck Tony <tony.luck@intel.com>, Prarit Bhargava <prarit@redhat.com>, Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

>>>>> "Russ" = Russ Anderson <rja@sgi.com> writes:

Russ> Tony Luck wrote:
>> > I used the sn2_defconfig in the tree :)
>> 
>> So there is something odd happening.  Russ complained that he was
>> still seeing several errors from the sn2_defconfig build too when I
>> posted the "last fix" to Len.  But I don't see them when I build.

Russ> An additional data point.  I have a copy of Tony's test tree
Russ> pulled down on March 30th that builds without the warning
Russ> messages.  The copy of Tony's test tree pulled down on May 22nd
Russ> does have warning messages.  I'm building both with the same
Russ> compiler (etc).  I'm fairly certain a tree I pulled down in
Russ> April built without warnings.  I've since blown away that tree.

Change request 85bd2fddd68e757da8e1af98f857f61a3c9ce647 introduced
section-mismatch checking for vmlinux, which caused all these warnings
to become visible.

It looks as if gcc can create references from .sdata to .init.sdata
depending on what optimisations it chooses to do.  Ideally we could
teach gcc to put its constants in the same section they reference.
But I'm no gcc guru.  The alternative is to get modpost to ignore such
references, at the cost of perhaps missing a real problem somewhere.
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
