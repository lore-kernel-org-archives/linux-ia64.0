From: Matthew Wilcox <willy@debian.org>
Date: Mon, 23 Feb 2004 19:46:02 +0000
Subject: Re: [PATCH] SAL version is not zero-padded
Message-Id: <20040223194602.GF25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040223191857.GE25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040223191857.GE25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 11:38:26AM -0800, David Mosberger wrote:
> >>>>> On Mon, 23 Feb 2004 19:18:57 +0000, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> SAL is version 3.1, not 3.01.
> 
> -	printk(KERN_INFO "SAL v%x.%02x: oem=%.32s, product=%.32s\n",
> +	printk(KERN_INFO "SAL v%x.%x: oem=%.32s, product=%.32s\n",
> 
> Eh, it was printing a _byte_.  If you remove the byte-printing, I
> suspect you'd also want to switch to a decimal format.

No, it's still BCD encoded.  So it'll go from 0x09 to 0x10 when we move
from 3.9 to 3.10.  It just shouldn't be 0-padded.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
