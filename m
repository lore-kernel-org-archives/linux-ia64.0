From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Nov 2007 20:39:03 +0000
Subject: Re: [patch 1/1] ia64: increase .data.patch offset
Message-Id: <20071114203850.GA2368@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
In-Reply-To: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 13, 2007 at 02:26:07PM -0800, Andrew Morton wrote:
> On Wed, 14 Nov 2007 09:07:45 +1100 Peter Chubb <peterc@gelato.unsw.edu.au> wrote:
> 
> > >>>>> "akpm" = akpm  <akpm@linux-foundation.org> writes:
> > 
> > akpm> From: Andrew Morton <akpm@linux-foundation.org> I get this:
> > 
> > akpm> /opt/crosstool/gcc-3.4.5-glibc-2.3.6/ia64-unknown-linux-gnu/lib/gcc/ia64-unknown-linux-gnu/3.4.5/../../../../ia64-unknown-linux-gnu/bin/ld:
> > akpm> section .data.patch [a000000000000500 -> a000000000000507]
> > akpm> overlaps section .dynamic [a0000000000003c8 -> a000000000000507]
> > 
> > If you switch to gcc 4.1 the patch section shrinks again and this patch
> > isn't necessary.
> 
> It took me two solid days work to generate my current cross-compile suite. 
> Weep.
> 
> I spose I can keep this patch locally if that's the direction which i64
> wants to take.  But in that case ia64 should #error out early if __GNUC__
> is wrong.

Hi Peter,

can you be a little more specific about what toolchain you are using?
I'm using crosstool but the most recent thing that it seems to like is
gcc-3.4.5 + glibc 2.3.6. I don't mind working on crosstool a bit to get
a newer gcc working, but I'd be grateful of any advice on versions to
avoid too much stabbing in the dark.

-- 
Horms, California Edition

