From: Horms <horms@verge.net.au>
Date: Fri, 29 Sep 2006 05:37:52 +0000
Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
Message-Id: <20060929053751.GB26519@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609271152.12393.Tristan.Gingold@bull.net>
In-Reply-To: <200609271152.12393.Tristan.Gingold@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 29, 2006 at 01:13:17PM +0800, Zou, Nanhai wrote:
> > -----Original Message-----
> > From: linux-ia64-owner@vger.kernel.org
> > [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Horms
> > Sent: 2006年9月29日 11:03
> > To: Zou, Nanhai
> > Cc: Magnus Damm; Tristan Gingold; Linux-IA64;
> > xen-ia64-devel@lists.xensource.com
> > Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
> > 
> > On Fri, Sep 29, 2006 at 10:21:33AM +0800, Zou, Nanhai wrote:
> > > > -----Original Message-----
> > > > From: Magnus Damm [mailto:magnus.damm@gmail.com]
> > > > Sent: 2006年9月28日 20:34
> > > > To: Tristan Gingold
> > > > Cc: Horms; Zou, Nanhai; Linux-IA64; xen-ia64-devel@lists.xensource.com
> > > > Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
> > > >
> > > > On 9/28/06, Tristan Gingold <Tristan.Gingold@bull.net> wrote:
> > > > > Le Jeudi 28 Septembre 2006 03:27, Horms a écrit :
> > > > > > On Wed, Sep 27, 2006 at 11:52:12AM +0200, Tristan Gingold wrote:
> > > > > > > Linux and xen call efi in real mode if set_virtual_address_map fails.
> > > > > > > You may add an option in both xen and linux to force calling efi in
> > real
> > > > > > > mode. This should be really simple and you will be able to make progress.
> > > > > >
> > > > > > Great, I will test this out and see how it goes.
> > > > > >
> > > > > > > The only possible drawback is performance.
> > > > > >
> > > > > > What kind of performance issues would you expect?
> > > > > Making EFI calls in physical mode is slower: Linux must switch from and
> > to
> > > > > virtual mode.
> > > > >
> > > > > However EFI calls are very unfrequent so the impact should be almost nul.
> > > >
> > > > This makes me wonder - is it really worth having two code paths in that
> > case?
> > > >
> > > > / magnus
> > >
> > > I am still not quiet clear about the particular issue on Xen.
> > >
> > > For native IA64,
> > > I put an empty efi.set_virtual_address_map() in purgatory code, So
> > > when the second kernel boots, it will still call to
> > > set_virtual_address_map() as if it successes.  I guess you can modify
> > > the empty function in purgatory to return an error.  So the second
> > > kernel will call EFI in physical mode.
> > 
> > I'm not 100% sure what the issue with xen->linux and linux->xen is
> > either. However my theory is that it relates to the fact that in linux
> > PAGE_OFFSET is 0xe000..., while in Xen it is 0xf000..., and thus any
> > addressing setup using efi.set_virtual_address_map() in one would seem
> > to be invalid in the other.
> > 
>  That is why I suggest you to return error in the set_virtual_address_map() in purgatory code. That will force the second kernel to use EFI physical call.

Sure. I think that is a pretty good idea. Except that we
need to make sure that set_virtual_address_map() isn't called
by the original code (well at least not a real working version),
as once it is called real mode EFI calls can no longer be made.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

