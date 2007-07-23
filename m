From: Doug Chapman <doug.chapman@hp.com>
Date: Mon, 23 Jul 2007 20:39:39 +0000
Subject: Re: Linus' tree broken?
Message-Id: <1185223179.7158.44.camel@dchapman.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2007-07-23 at 22:22 +0200, Jes Sorensen wrote:
> Luck, Tony wrote:
> >> I heard from John Keller that he had problems too. What kind of
> >> userland are you running? I've seen hanging around udev.
> > 
> > I took 2.6.23-rc1 over to a Hitachi box running FC7 userspace.
> > It booted just fine there.
> > 
> > Maybe we broke SN2?
> > 
> > -Tony
> 
> Could be, but it sounds like there's something fishy in the current
> tree - Doug Chapman is having problems as well, presumably on zx1 boxes.

I am seeing the panic on HP zx1 and zx2 systems.  Currently doing a git
bisect to narrow it down.

- Doug



