From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 10 Apr 2009 10:19:21 +0000
Subject: Re: cross-compilers
Message-Id: <8bd0f97a0904100319kb16c81bs596341e016cc41a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com>
	 <20090408010331.GB10768@sgi.com> <20090408054612.GA6744@ldl.fc.hp.com>
	 <20090407225457.86f8a458.akpm@linux-foundation.org>
	 <20090409003308.GK16602@bilbo.ozlabs.org>
	 <20090408174443.79e71503.akpm@linux-foundation.org>
	 <20090409215207.GN16602@bilbo.ozlabs.org>
	 <20090409234750.GE7921@lug-owl.de> <20090410101220.GF7921@lug-owl.de>
In-Reply-To: <20090410101220.GF7921@lug-owl.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Andrew Morton <akpm@linux-foundation.org>, Alex Chiang <achiang@hp.com>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

On Fri, Apr 10, 2009 at 06:12, Jan-Benedict Glaw wrote:
> On Fri, 2009-04-10 01:47:50 +0200, Jan-Benedict Glaw wrote:
>> I've started a build-bot like script for binutils + GCC from CVS/GIT.
>> If it builds through, I'll start uploading i686 hosted compilers
>> later on today.
>
> So... I've now build trunk kernel-only cross-compilers (hosted on
> i686) for these targets:
>
>        bfin-uclinux.tar.bz2

we already host up-to-date Blackfin compilers on the Blackfin website:
http://blackfin.uclinux.org/gf/project/toolchain/frs/

and we build for a variety of platforms ... atm that is x86, x86_64,
ia64, and ppc

we also provide for simple distro integration:
 - Gentoo has ebuilds in-tree
 - deb based distros can use "deb
http://download.analog.com/27516/distros/debian stable main"
 - rpms are available at the link above (fedora/suse/etc...)
 - tarballs are available at the link above (everyone else)

not sure it can get much easier than that for installing the Blackfin
toolchain ;)
-mike
