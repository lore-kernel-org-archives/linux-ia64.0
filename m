From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 14 Mar 2005 12:13:07 +0000
Subject: Re: IA64 memory (zx1 mio)
Message-Id: <20050314121307.GT21986@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb0503132305641cfa33@mail.gmail.com>
In-Reply-To: <851caabb0503132305641cfa33@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 14, 2005 at 12:35:07PM +0530, Vaibhav Sharma wrote:
> Actually, I had downloaded a zx1 mio pdf, and my task involved just to
> recognize whether there are any scalability limits at any place....
> If my question was wrong...plz spare me...!
> 
> I think i had wrongly interpreted the "System Address Map" figure, on
> page 12 of the pdf, (site:
> http://ftp.parisc-linux.org/docs/chips/zx1-mio.pdf ). It shows the
> "zones", memory0, memory1 and memory2, with corresponding addresses.
> It says that m0+m1+m2=1+3+252%6 GB, now if 257th GB of address is to
> be mapped by zx1, in which memory zone (m0,m1,m2) will it be
> mapped..?..if this is not the case, how will zx1 map this giga byte..?

It doesn't.  The zx1 chipset supports "only" 256GB of memory max.
HP uses the sx1000 chipset for machines that support more than 256GB.
As was said earlier, this isn't a practical limitation yet; for the
4-socket space HP ships the rx4640 which supports 128GB (4GB x 32 slots)
and the rx5670 which supports 96GB (2GB x 48 slots).  The 8-socket and
up boxes (rx7620, rx8620 and Superdome) use the sx1000 chipset.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
