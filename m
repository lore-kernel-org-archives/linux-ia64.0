From: Matthew Wilcox <willy@debian.org>
Date: Fri, 16 Jul 2004 00:18:51 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040716001851.GR32326@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 15, 2004 at 05:09:00PM -0700, David Mosberger wrote:
> >>>>> On Fri, 16 Jul 2004 00:34:20 +0100, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> #define log2(x) (ffs(x) - 1)
> 
> At the risk of pointing out the obvious, this definition only works
> for integer-powers of two...
> 
> get_order() works for any "unsigned long" value.

Oh, um, I didn't realise that ffs() worked backwards.  fls() - 1, then.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
