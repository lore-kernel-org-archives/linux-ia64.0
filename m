From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 10 Feb 2005 15:06:15 +0000
Subject: Re: Porting driver from x86
Message-Id: <20050210150615.GB17242@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1108041115.29380.6.camel@oshawa.rd.discreet.qc.ca>
In-Reply-To: <1108041115.29380.6.camel@oshawa.rd.discreet.qc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 10, 2005 at 08:11:55AM -0500, Eric Desjardins wrote:
> I'm not to familiar with kernel code but I'm trying to port a kernel
> driver from x86 to ia64.
> 
> I was just wondering how should I translate that:
> 
> static int interrupts_blocked()

Drivers shouldn't need to know whether interrupts are blocked or not.
What are you trying to do?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
