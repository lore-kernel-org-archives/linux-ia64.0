From: Bob Picco <bob.picco@hp.com>
Date: Tue, 27 Sep 2005 14:10:26 +0000
Subject: Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050927141026.GP16066@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner wrote:	[Tue Sep 27 2005, 08:45:00AM EDT]
> > We could be more aggressive than other arches but still follow the cautious
> > path.  I'm reluctant to suggest this but adding a couple of default 
> > configuration files with SPARSEMEM might be useful.  Perhaps 
> > sn2_defconfig_sparsemem and defconfig_sparsemem. 
> > 
> 
> Although many developers at SGI use SN-specific configuration files,
> customers run SuSE & RH and use kernels built with the GENERIC config 
> since the kernel binary runs on all hardware vendors platforms.
> It is important to make the default config file run efficiently
> on all platforms.
okay.
> 
> I haven't looked in detail at SPARSEMEM recently - is one config
> file for ALL hardware platforms easy to do without significantly 
> compromising performance of any individual platform?
I don't know whether that can be achieved.  We've really done limited 
performance comparisons. It would have to be investigated.
> 
> 
> -- 
> Jack
bob
