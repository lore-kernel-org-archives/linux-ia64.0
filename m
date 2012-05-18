From: Greg KH <greg@kroah.com>
Date: Fri, 18 May 2012 19:28:07 +0000
Subject: Re: [PATCH 3.0.y, 3.2.y] ia64: Add accept4() syscall
Message-Id: <20120518192807.GB4874@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120516215700.GA10476@burratino>
In-Reply-To: <20120516215700.GA10476@burratino>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, May 16, 2012 at 04:57:00PM -0500, Jonathan Nieder wrote:
> From: =C9meric Maschino <emeric.maschino@gmail.com>
>=20
> commit 65cc21b4523e94d5640542a818748cd3be8cd6b4 upstream.
>=20
> While debugging udev > 170 failure on Debian Wheezy
> (http://bugs.debian.org/cgi-bin/bugreport.cgi?bugd8325), it appears
> that the issue was in fact due to missing accept4() in ia64.
>=20
> This patch simply adds accept4() to ia64.
>=20
> Signed-off-by: =C9meric Maschino <emeric.maschino@gmail.com>
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
> ---
> Hi Ben and Greg,
>=20
> =C9meric Maschino wrote[1]:
>=20
> > Starting with udev 170 (well, IIRC!), console is flooded at startup wit=
h:
> >
> >     udevd[XXX]: unable to receive ctrl connection: Function not impleme=
nted
> >
> > where XXX is a number (PID?).
> >
> > And system takes ~3 min. to get login prompt.
>=20
> Indeed, udev versions since 168 (2011-04-22) require the accept4()
> syscall.  That syscall was added to the kernel in 2.6.28 (2008-11-19),
> but arches were slow to pick it up because checksyscalls.sh didn't
> catch it[2] (it was implemented on 32-bit x86 using sys_socketcall).
> Here is a list of when each arch added the syscall:
>=20
>  x86 and arches using socketcall (2008-11-19) v2.6.28-rc6~45
>  sparc64 (2008-11-19) v2.6.28-rc6~44
>  MIPS (2009-08-03) v2.6.31-rc6~64^2
>  microblaze (2009-12-28) v2.6.33-rc5~19^2~3
>  sh64 (2010-01-19) v2.6.33-rc5~13^2
>  parisc (2009-12-26) v2.6.34-rc1~13^2~6
>  ARM (2010-08-15) v2.6.36-rc2~52^2~2
>  sh (2010-12-13) v2.6.37-rc6~10^2
>  alpha (2011-10-31) v3.2-rc1~108^2~58
>  ia64 (2012-01-09) v3.3-rc1~73^2
>=20
> Lots of arches are not listed above because they use the multiplexed
> socketcall call and got support right away.  (sh and sh64 provide both
> the direct syscall and socketcall.)
>=20
> This patch was merged upstream during the 3.3 merge window and has
> been in use in Debian's 3.2.y-based kernel since January.
>=20
> As long as libc was built to use the syscall, applying this patch
> makes udev work properly again on ia64.  What do you think?

I'd accept it for the 3.0-stable kernel, but it doesn't apply, care to
provide a backported version that does?

thanks,

greg k-h
