From: "H . J . Lu" <hjl@valinux.com>
Date: Wed, 07 Feb 2001 07:06:20 +0000
Subject: Re: [Linux-ia64] The 1117 snapshot cpp problem
Message-Id: <marc-linux-ia64-105590693005120@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205880@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205880@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 06, 2001 at 01:56:13PM +0100, Andreas Schwab wrote:
> |> > 
> |> > There is no problem with cross compilers as you suggested, because cross
> |> > compilers don't use /usr/local/include.  I believe the original problem was
> |> > that we shipped compilers to some customers that had random files in
> |> > /usr/local, the customers reported problems, and we had a lot of trouble
> |> > debugging the problem.  We fixed it by deciding not to use /usr/local/include
> |> > by default anymore.  This was 8 years ago, so Linux usage was not a concern.
> |> > Now that we are part of Red Hat, it is a serious concern.
> |> > 
> |> > The resulting patch is 100K because configure had to be rebuilt.  I put it
> |> > in the usual place, ftp.cygnus.com:/pub/ia64-linux/snap-001117/patch.055.
> |> > 
> |> 
> |> I don't think it works with the gnupro rpm from RedHat. I had to
> |> add the patch enclosed here. I think the problem is includedir in gcc
> |> is overriden from the toplevel Makefile.
> 
> This is a very old bug that I have already reported twice (see
> http://gcc.gnu.org/ml/gcc-patches/1999-07/msg00488.html and
> http://gcc.gnu.org/ml/gcc-patches/1999-05/msg00477.html).

It is ok if you use "make bootstrap" since $(includedir) passed down
is ignored during "make bootstrap" in gcc. But the toolchain may not
be built with "make bootstrap". I believe

"includedir=$(includedir)" \

should not be passed to gcc during any build.


-- 
H.J. Lu (hjl@valinux.com)

