From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 10 Feb 2005 16:41:50 +0000
Subject: Re: Porting driver from x86
Message-Id: <20050210164150.GC17242@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1108041115.29380.6.camel@oshawa.rd.discreet.qc.ca>
In-Reply-To: <1108041115.29380.6.camel@oshawa.rd.discreet.qc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 10, 2005 at 10:05:04AM -0500, Eric Desjardins wrote:
> The drivers want's to know if it has been put to sleep or not. It's not
> used often. It's not my code and the reasons seems a bit obscure to me.

Do you mean "wants to know if it can sleep or not"?  If so, checking like
this isn't appropriate -- it should already know whether or not it can sleep.
Where's the source to this driver?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
