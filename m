From: Matthew Wilcox <willy@debian.org>
Date: Tue, 17 Feb 2004 19:58:47 +0000
Subject: Re: megaraid warnings
Message-Id: <20040217195847.GC11824@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <16434.28509.327706.76307@napali.hpl.hp.com>
In-Reply-To: <16434.28509.327706.76307@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 17, 2004 at 11:45:33AM -0800, David Mosberger wrote:
> The 2.6 megaraid driver causes several ugly warnings along the lines of:
> 
> drivers/scsi/megaraid.c:3500: warning: cast to pointer from integer of different size
> 
> I think those may be harmless (I don't have hardware to test this) but
> it would still be better to fix the drivers so there are no warnings
> (most likely by casting u32 addresses that are guaranteed to be <4GB
> to "unsigned long" before converting them to a pointer).
> 
> Can someone look into this?

This keeps coming up on linux-scsi; basically these are ioctls that
are called by some binary-only (and x86-binary-only at that) management
program.  so if they want to ship an ia64 version of their management
program, they'll have to fix this; otherwise the addresses are guaranteed
to be in the lower 32 bits of the address space.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
