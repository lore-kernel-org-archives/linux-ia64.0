From: Matthew Wilcox <willy@debian.org>
Date: Sat, 11 Sep 2004 16:38:23 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <20040911163823.GF642@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 11, 2004 at 08:43:21AM -0700, Christoph Lameter wrote:
> There is no dmesg line showing that a hpet device has been detected. Are
> you sure that the box provides a hpet timer? If its not detected then you
> better talk with the author of the hpet driver.

There is no hpet device in currently shipping zx1 boxes.  I'm not sure
there's one in currently shipping sx1000 boxes either.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
