From: Matthew Wilcox <willy@debian.org>
Date: Wed, 09 Jun 2004 16:51:03 +0000
Subject: Re: Please requeue atlas3
Message-Id: <20040609165103.GC24864@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 09, 2004 at 10:05:15AM -0600, LaMont Jones wrote:
> On Wed, Jun 09, 2004 at 11:31:38AM -0400, Camm Maguire wrote:
> > TO close the book on ia64 atlas3, are there any isa extensions
> > available on certain subclasses of the cpu which might warrant a
> > separate build, as is the case for sse2 on i386?
> 
> Absolutely no clue here.  Anyone else?

I think the only ISA addition so far is BranchLong which gets emulated
by the kernel.  I hear murmurings of additional instructions in future
processors, but let's cross that bridge when there's silicon to be had.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
