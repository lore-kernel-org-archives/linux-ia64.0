From: Dean Nelson <dcn@sgi.com>
Date: Mon, 23 Aug 2004 19:16:28 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040823191628.GA13385@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 23, 2004 at 06:52:39PM +0100, Christoph Hellwig wrote:
> On Mon, Aug 23, 2004 at 12:10:08PM -0500, Dean Nelson wrote:
> > Although I agree that the nodemask_t patch is the proper solution to the
> > numnodes issue, I don't feel that waiting for its arrival should prevent
> > my continuing on with my XP[C|NET] patch. So I'm going to resubmit my
> > proposed patch with numnodes exported. This is with the understanding
> > that once the nodemask_t patch is accepted by the community (resulting
> > in the 'EXPORT_SYMBOL(numnodes);' line being deleted), I'll be glade to
> > rework the two XPC functions to use the 'for_each_node()' macro instead.
> 
> Can you post a current snapshot of your work?  As in the last mail numnodes
> is not the kind if 'interface' we'd like to export, especially with things
> like node hotplug in the pipe.

Yeah, I'll submit my latest version (probably tommorrow) for round two of
the review process. Keep in mind that it will not reflect your comments
from your latest two emails.
