From: Matthew Wilcox <willy@debian.org>
Date: Wed, 19 May 2004 01:59:13 +0000
Subject: Re: Disable CONFIG_SMP for IA64_HP_SIM
Message-Id: <20040519015913.GM6484@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040519012326.GA27655@cse.unsw.EDU.AU>
In-Reply-To: <20040519012326.GA27655@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 18, 2004 at 06:35:12PM -0700, David Mosberger wrote:
> CONFIG_SMP probably shouldn't depend on CONFIG_IOSAPIC.

I agree -- I think the SGI machines don't have an IOSAPIC.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
