From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Fri, 27 Feb 2004 21:48:50 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <20040227134850.5deb0f75.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 27 Feb 2004 20:25:05 +0000 Matthew Wilcox wrote:

| On Fri, Feb 27, 2004 at 11:33:36AM -0800, David Mosberger wrote:
| > Sounds good to me.  The extra blank kills me though... ;-)
| 
| Weeeeeelllllllll.... if you're not allergic to trigraphs,
| 
|         printk(KERN_INFO "SAL %d.%d: %.32s %.32s%sversion %d.%d\n",
|                         sal_rev_major, sal_rev_minor, systab->oem_id,
|                         systab->product_id, systab->product_id[0] ? " " : "",
|                         sal_b_rev_major, sal_b_rev_minor);
| 
| does the trick nicely ;-)
| 
| I'll send a patch when you've come to a decision about how you want the
| SAL revision comparison to look -- it all touches the same area of code.

Where's the trigraph???

A conditional operator ("?:") [section 6.5.15 of C99 spec.]
does not make a 'trigraph'.

Conditional operators are fine IMO, so long as the gcc extension of
"omitted second operand implies repeat the first operand" is not used... :)
This is ugly and prone to mistakes.

--
~Randy
