From: Matthew Wilcox <willy@debian.org>
Date: Mon, 23 Feb 2004 21:21:01 +0000
Subject: Re: SAL version checking
Message-Id: <20040223212101.GH25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040223210103.GG25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040223210103.GG25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 01:09:20PM -0800, Jesse Barnes wrote:
> It looks reasonable to me, though I thought we were the only ones that
> cared about PROM revisions ;).  If you go ahead and push this in, we
> could use it in arch/ia64/sn/kernel/setup.c, where we check for
> incompatibilties bad enough to cause us to bail out...

Well, you *were* the only ones who cared about SAL revisions ;-)
Actually, this isn't quite what you want.  I'm asking the firmware
what rev of the SAL spec it reports; you want version number of the
prom.  I want sal_rev_major/minor; you want sal_b_rev_major/minor.

I don't see why we shouldn't do both, and possibly even print both.
I've occasionally wondered what rev of firmware I'm running and
rebooting to figure that out is less satisfactory than grovelling through
/var/log/dmesg.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
