From: Matthew Wilcox <willy@debian.org>
Date: Fri, 27 Feb 2004 20:25:05 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <20040227202505.GS25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 27, 2004 at 11:33:36AM -0800, David Mosberger wrote:
> Sounds good to me.  The extra blank kills me though... ;-)

Weeeeeelllllllll.... if you're not allergic to trigraphs,

        printk(KERN_INFO "SAL %d.%d: %.32s %.32s%sversion %d.%d\n",
                        sal_rev_major, sal_rev_minor, systab->oem_id,
                        systab->product_id, systab->product_id[0] ? " " : "",
                        sal_b_rev_major, sal_b_rev_minor);

does the trick nicely ;-)

I'll send a patch when you've come to a decision about how you want the
SAL revision comparison to look -- it all touches the same area of code.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
