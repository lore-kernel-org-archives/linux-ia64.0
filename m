From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 01 Jun 2007 08:00:33 +0000
Subject: RE: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <617E1C2C70743745A92448908E030B2A01961AFE@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <465F9315.2050207@redhat.com>
References: <20070522234314.54081817.akpm@linux-foundation.org>
In-Reply-To: <20070522234314.54081817.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prarit Bhargava <prarit@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

> I used the sn2_defconfig in the tree :)

So there is something odd happening.  Russ complained that he
was still seeing several errors from the sn2_defconfig build
too when I posted the "last fix" to Len.  But I don't see them
when I build.

-Tony
