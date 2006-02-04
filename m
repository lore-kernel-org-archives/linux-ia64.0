From: Andrew Morton <akpm@osdl.org>
Date: Sat, 04 Feb 2006 05:08:07 +0000
Subject: Re: Altix SN2 2.6.16-rc1-mm5 build breakage (was:  msi support)
Message-Id: <20060203210807.56a48888.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060119194647.12213.44658.14543@lnx-maule.americas.sgi.com>
	<20060119194702.12213.16524.93275@lnx-maule.americas.sgi.com>
	<20060203201441.194be500.pj@sgi.com>
	<20060203202531.27d685fa.akpm@osdl.org>
	<20060203202742.1e514fcc.akpm@osdl.org>
	<20060204044234.GA31134@sgi.com>
In-Reply-To: <20060204044234.GA31134@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: pj@sgi.com, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, gregkh@suse.de

Mark Maule <maule@sgi.com> wrote:
>
> On Fri, Feb 03, 2006 at 08:27:42PM -0800, Andrew Morton wrote:
> > Andrew Morton <akpm@osdl.org> wrote:
> > >
> > > So it
> > >  looks like you've found a fix for a patch which isn't actually in -mm any
> > >  more.  I sent that fix to Greg the other day.
> > 
> > Actually, gregkh-pci-altix-msi-support-git-ia64-fix.patch fix`es
> > git-ia64.patch when gregkh-pci-altix-msi-support.patch is also applied, so
> > it's not presently useful to either Greg or Tony.  I'll take care of it,
> > somehow..
> > 
> 
> I think what happened here is that I submitted a patchset for msi
> abstractions (and others posted a couple of subsequent bugfix incrementals),
> but these were not taken into the 2.6.16 base 'cause of their invasiveness.
> These patches touched the tioce_provider.c file.
> 
> Then I submitted another patch which touched the tioce_provider.c file, and
> it looks like I probably based this file on the previous msi versions which
> were being held back, so in order for everything to build, you need all of
> the msi patches applied first.
> 
> What's the preferred way to handle this ... fix the current ia64 build and
> then resubmit the msi patches relative to that base?
> 

umm, tricky.  This situation doesn't arise very often.

What you could do is to prepare the patches against Tony's latest tree. 
Then I can put them in -mm and Greg can drop them.  Once Tony merges up
with Linus I transfer the patches to Greg.

Or we put the patches into Tony's tree.

Either way - they'll be the same patches.  But it does mean that the
patches won't be merged into mainline until Tony merges up.  If that's a
problem then we'll need to think again.
