From: Matthew Wilcox <willy@debian.org>
Date: Tue, 01 Jun 2004 16:21:32 +0000
Subject: Re: Real time clock on ia64 platforms
Message-Id: <20040601162132.GO5850@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <40BC3558.7040606@hob.de>
In-Reply-To: <40BC3558.7040606@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 01, 2004 at 09:50:48AM +0200, Christian Hildner wrote:
> someone may know what kind of RTC device the ia64 platforms (HP ZX 6000 
> + i2000) use. I want to access it directly, without using EFI calls.

It's probably different on each of them.  Why do you want to access it
without going through firmware?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
