From: Matthew Wilcox <willy@debian.org>
Date: Tue, 16 Mar 2004 14:54:02 +0000
Subject: Re: [patch] 2.6.4 remove intermittent warnings from spinlock code
Message-Id: <20040316145402.GR25059@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <2465.1079310276@kao2.melbourne.sgi.com>
In-Reply-To: <2465.1079310276@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 15, 2004 at 11:34:43PM -0800, David Mosberger wrote:
> Hmmh, in my opinion GCC should put a stop-bit when using a register
> after an "asm" that marks that register as "clobbered".  For now, I
> put an explicit stop-bit after the McKinley spinlock versions (the
> Merced ones should be OK because they already have a stop-bit after
> writing p14).  We should still sort out why GCC doesn't get this
> right.

I'm not a compiler person, but ...

Seems to me that doing exactly what you're asking for is hard.  Editing
the inline asm to use a stop-bit if the compiler needs to reuse that
register would be a really awful layering violation.  But it shouldn't
be too hard for p14 to be considered unavailable until the next stop
bit has been issued.

Al, want to raise this on the gcc mailing list?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
