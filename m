From: Matthew Wilcox <willy@debian.org>
Date: Tue, 17 Feb 2004 20:09:18 +0000
Subject: Re: megaraid warnings
Message-Id: <20040217200918.GD11824@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <16434.28509.327706.76307@napali.hpl.hp.com>
In-Reply-To: <16434.28509.327706.76307@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 17, 2004 at 12:08:22PM -0800, David Mosberger wrote:
> >>>>> On Tue, 17 Feb 2004 19:58:47 +0000, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> This keeps coming up on linux-scsi; basically these are
>   Matthew> ioctls that are called by some binary-only (and
>   Matthew> x86-binary-only at that) management program.  so if they
>   Matthew> want to ship an ia64 version of their management program,
>   Matthew> they'll have to fix this; otherwise the addresses are
>   Matthew> guaranteed to be in the lower 32 bits of the address space.
> 
> Then why not disable the offending code for 64-bit platforms for the
> time being?

Because it works when the x86 app is run in emulation.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
