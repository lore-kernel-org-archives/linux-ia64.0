From: Matthew Wilcox <willy@debian.org>
Date: Thu, 15 Jul 2004 23:34:20 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040715233420.GQ32326@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 15, 2004 at 04:16:38PM -0700, William Lee Irwin III wrote:
> On Thu, Jul 15, 2004 at 12:11:07PM -0700, Luck, Tony wrote:
> > Notes and Caveats:
> > 1) Is there a define someplace for log2(BITS_PER_LONG)?  I couldn't
> > find one, which is why I calculate the "order" in this patch.
> 
> Unfortunately no. It would be nice to have one.

#define log2(x) (ffs(x) - 1)

(ffs returns a value from 0 to 32 whereas log2 wants to return -1 to 31)

Obviously it rounds down, but that's entirely consistent with the behaviour
of, say, 7/4 in C.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
