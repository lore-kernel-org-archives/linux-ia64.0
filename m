From: Matthew Wilcox <willy@debian.org>
Date: Thu, 15 Jul 2004 19:31:43 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040715193143.GL32326@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 15, 2004 at 12:11:07PM -0700, Luck, Tony wrote:
> Notes and Caveats:
> 1) Is there a define someplace for log2(BITS_PER_LONG)?  I couldn't
> find one, which is why I calculate the "order" in this patch.

ffs()?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
