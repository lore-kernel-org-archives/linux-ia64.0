From: Matthew Wilcox <willy@debian.org>
Date: Tue, 24 Feb 2004 15:52:48 +0000
Subject: Re: [PATCH] improve gate generation
Message-Id: <20040224155248.GP25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040224015640.GJ25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040224015640.GJ25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 06:08:13PM -0800, David Mosberger wrote:
> >>>>> On Tue, 24 Feb 2004 01:56:40 +0000, Matthew Wilcox <willy@debian.org> said:
>   Matthew> - Adding the extra-y list prevents it from being rebuilt
>   Matthew> unnecessarily.
> 
> Ah, so _that's_ the missing magic.

Yeah, it was bugging me too.  Not enough to fix it until I wanted to run
"sudo make install" and of course the output was then owned by root.
Took me a while to figure it out; finally I asked myself what the
difference was between gate.lds.s and vmlinux.lds, and vmlinux.lds was
in extra-y.  Make does so much that staring at make -d isn't always a
great help.  ("It depends on FORCE.  Hm.  But why doesn't that other
thing depend on FORCE?")

> Now if only the patch applied with "patch -p1"...  (don't worry about
> it this time---I fixed it by hand).

Ta.  I actually have a patched version of CVS that'll generate -p1 by
default, just need to get it installed on that server.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
