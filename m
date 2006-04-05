From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 05 Apr 2006 09:44:45 +0000
Subject: Re: [ANNOUNCE]: IA64 ISOs based on Fedora Core 5
Message-Id: <1144230285.6227.10.camel@pmac.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44332325.8050207@sgi.com>
In-Reply-To: <44332325.8050207@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2006-04-04 at 22:25 -0400, Paul Nasrat wrote:
> I assume for the weekly snapshots of rawhide that you'll be putting
> unique (eg date based) names on the isos so they can be readily
> identified, else you're going to run into trouble tracking issues
> across media sets. 

To be honest, I'm not convinced that weekly ISO builds are particularly
useful -- we don't do that for rawhide on other architectures either.
It's probably better just to encourage people to use rsync to keep up
with rawhide, rather than downloading it all over again each week.

>  Do these isos correspond with FC5 or a random snapshot?

Rawhide for about a week leading up to March 20th was identical to FC5
in all but the 'fedora-release' package. 

If making an IA64 'FC5' I'd be inclined to replace the fedora-release
package too. In fact, you almost certainly want to do that anyway, since
you'll be publishing the errata, and fedora-release contains the yum
configuration.

Aside from the updates, the next task is building Extras and Livna for
IA64, of course...

-- 
dwmw2

