From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Aug 2002 22:42:24 +0000
Subject: Re: [Linux-ia64] test patch relative to 2.5.30
Message-Id: <marc-linux-ia64-105590701905935@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905931@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905931@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 12 Aug 2002 13:20:48 -0700, Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> said:

  Kimio> Hi David, I updated the boot-change patch for 2.5.30.
  Kimio> Curious to say, the kernel with the patch worked fine on two
  Kimio> way Bigsur, while the original kernel caused panic at
  Kimio> booting.

Thanks for the patch, I applied it now.

  Kimio> Why don't you take it into your tree? :-)

It's simply a matter of finding time.  Doing the DRM update was a big
effort for me because I'm not all that familiar with AGP, GART, etc.,
yet it's important to clean it up so we can get it into the mainline
of the kernel (otherwise, it will keep eating small bits of my time
each time a new kernel is released).  Of course, having 2.5.29 corrupt
files on some of my IDE disks didn't help either.  Anyhow, I think
we're very close now to having DRM out of the way (only one open issue
is left over).

	--david

