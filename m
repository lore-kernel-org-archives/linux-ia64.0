From: Matthew Wilcox <willy@debian.org>
Date: Thu, 02 Sep 2004 15:05:56 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <20040902150556.GJ642@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 01, 2004 at 11:10:30PM -0700, William Lee Irwin III wrote:
> You don't thave CONFIG_DISCONTIGMEM set? Why are you bothering with
> virtual mem_map if not? If the core helpers are insufficiently
> lightweight in the CONFIG_DISCONTIGMEM=n case we are very well going
> to have whatever sanction we need to repair it, as this is the common
> case among end users of the most predominant hardware and architectures.

Ah, basic lack of understanding of what VIRTUAL_MEM_MAP is used for
and why it exists.  It should be exclusive with DISCONTIGMEM as they
both solve the same problem, but in wildly different ways.  At the time
VIRTUAL_MEM_MAP was put in, the DISCONTIGMEM code was utterly broken
and nobody was interested in fixing it ("we have a version in the LSE
patch that doesn't suck as much" doesn't help).

Both should address the memory map on zx1:

0-1 GB
257-260GB
4-256GB

(in practice, the maximum memory you can put in any zx1 box at the moment
is 128GB because 4GB DIMMs aren't supported in the rx5670)

Without VIRTUAL_MEM_MAP or DISCONTIGMEM, a 2GB zx1 machine would have
a 13GB mem_map.  So DISCONTIGMEM does away with the global mem_map and
VIRTUAL_MEM_MAP constructs a mem_map in vmalloc space rather than the
kernel's fixed mapping.

If DISCONTIGMEM now works properly, I think VIRTUAL_MEM_MAP can disappear.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
