From: Paul Nasrat <pnasrat@redhat.com>
Date: Wed, 05 Apr 2006 12:16:48 +0000
Subject: Re: [ANNOUNCE]: IA64 ISOs based on Fedora Core 5
Message-Id: <1144239409.12268.34.camel@enki.eridu>
List-Id: <linux-ia64.vger.kernel.org>
References: <44332325.8050207@sgi.com>
In-Reply-To: <44332325.8050207@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-04-05 at 06:54 -0400, Prarit Bhargava wrote:
> David Woodhouse wrote:
> > On Tue, 2006-04-04 at 22:25 -0400, Paul Nasrat wrote:
> > 
> >>I assume for the weekly snapshots of rawhide that you'll be putting
> >>unique (eg date based) names on the isos so they can be readily
> >>identified, else you're going to run into trouble tracking issues
> >>across media sets. 
> > 
> > 
> > To be honest, I'm not convinced that weekly ISO builds are particularly
> > useful -- we don't do that for rawhide on other architectures either.
> > It's probably better just to encourage people to use rsync to keep up
> > with rawhide, rather than downloading it all over again each week.
> > 
> 
> Unfortunately, it seems I have users who are unwilling to use yum, etc., 
> in the short term.  They would prefer weekly snapshots.

Really having done this for ppc, and also working on anaconda - I'd
heartily recommend using NFS and tracking rawhide.  With NFS it's
trivial to drop in an RHupdates to fix up issues, with isos it becomes
much harder.

Paul

