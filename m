From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 13 Dec 2005 18:26:00 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <439F1238.9090601@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:

> 
> Well, sure.  device_setup() was just an example.  I expect they'd
> want to add more (subsys, etc).  I doubt that all the levels would
> be needed, but even if they were, I'd prefer it over sprinkling
> "ia64_platform_is" everywhere.
> 

OTOH the moment they change the initcall sequence we would
have to change our machine vector interfaces.  And AFAICT no
one is happy with the 7 levels of init (everything from too
granular to not granular enough).

I'm inclined to move the direction that Tony suggests:

Tony Luck wrote:
> Running two separate parallel structures seems complex.
> Why not make the entries in the .initcall sections be tuples
> instead of just being an array:
> 

I think this seems a lot more sane than what I suggested.

I'll code something up and try to see if I can dig up a PPC
system to test on as well.

P.
