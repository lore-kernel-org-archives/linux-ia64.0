From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 05 Apr 2006 11:24:15 +0000
Subject: Re: [ANNOUNCE]: IA64 ISOs based on Fedora Core 5
Message-Id: <1144236255.6227.30.camel@pmac.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44332325.8050207@sgi.com>
In-Reply-To: <44332325.8050207@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-04-05 at 06:54 -0400, Prarit Bhargava wrote:
> > To be honest, I'm not convinced that weekly ISO builds are particularly
> > useful -- we don't do that for rawhide on other architectures either.
> > It's probably better just to encourage people to use rsync to keep up
> > with rawhide, rather than downloading it all over again each week.
> 
> Unfortunately, it seems I have users who are unwilling to use yum, etc., 
> in the short term.  They would prefer weekly snapshots.

They actually want to _reinstall_ weekly? Or do a full 'upgrade' weekly?

Even so, they could quite happily do that from a normal rawhide mirror
like everyone else does, rather than using ISO images. That just seems
like a gratuitous waste of bandwidth to me -- for rawhide even more so
than for the actual releases.

> Yep -- I replaced fedora-release with the FC5 version in the images.  I 
> didn't mention it because I didn't think it was that important :).

The _real_ FC5 version -- doesn't that mean the updates repo is
configured to point at a non-existent directory? 

> > Aside from the updates, the next task is building Extras and Livna for
> > IA64, of course...
> 
> Whaddya think I'm working on? :)

:)


-- 
dwmw2

