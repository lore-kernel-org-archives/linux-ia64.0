From: Matthew Wilcox <willy@debian.org>
Date: Mon, 01 Mar 2004 16:03:03 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <20040301160303.GW25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 27, 2004 at 03:02:06PM -0800, David Mosberger wrote:
> >>>>> On Fri, 27 Feb 2004 22:42:15 +0000, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> I actually can't find a name for the ?: operator in the C
>   Matthew> FAQ.
> 
> conditional expression?

I remembered I had a copy of the C99 spec ... 6.5.15 calls it the
"conditional operator".  I also found a document calling it the "ternary
operator".

> I'd really prefer sal_revision() combined with a SAL_VERSION() macro.
> I can just look at that and intuitively understand what it's doing
> (especially given the symmetry with the LINUX_VERSION macros), whereas
> with the sal_version_check() function, I have to go look at it's
> definition.

Okey dokey, done.  I'll send it as a separate message to keep the
?:??! discussion out of the changelog ;-)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
