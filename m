From: Horms <horms@verge.net.au>
Date: Thu, 26 Jul 2007 01:31:30 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <20070726013130.GB12284@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 25, 2007 at 11:26:42AM -0400, Doug Chapman wrote:
> On Wed, 2007-07-25 at 22:37 +0900, Horms wrote:
> 
> > I was also seeing a strange problem relating to the
> > vector domain patch which seemed to be causing
> > corruption of vectors_in_migration, which caused migrate_irqs()
> > to emmit suprious IRQ errors (when called by kexec).
> > 
> > I'll try and confirm that this patch soles the problem that
> > I was seeing tomorrow.
> > 
> 
> You may also want to try this patch:
> http://www.mail-archive.com/linux-ia64@vger.kernel.org/msg03113.html

Thanks, will do.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

