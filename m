From: Matthew Wilcox <willy@debian.org>
Date: Wed, 14 Jul 2004 02:01:46 +0000
Subject: Re: Next Revison of timer patches with split into nanosecond, time_interpolator and debug patch
Message-Id: <20040714020146.GW32326@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 13, 2004 at 06:57:25PM -0700, David Mosberger wrote:
>  - the fsys.S code depends on depends on the layout of the
>    time_interpolator data-structure; that's OK, but it might be a good
>    idea to add some safe-guards which ensure that the code fails to
>    build if someone changes the layout of the structure

How about using the asm-offsets.c method, so it will build even if
someone changes time_interpolator?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
