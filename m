From: Rob Landley <rob@landley.net>
Date: Thu, 09 Apr 2009 00:20:58 +0000
Subject: Re: cross-compilers
Message-Id: <200904081921.00647.rob@landley.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com> <20090408054612.GA6744@ldl.fc.hp.com> <20090407225457.86f8a458.akpm@linux-foundation.org>
In-Reply-To: <20090407225457.86f8a458.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Chiang <achiang@hp.com>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wednesday 08 April 2009 00:54:57 Andrew Morton wrote:
> On Tue, 7 Apr 2009 23:46:12 -0600 Alex Chiang <achiang@hp.com> wrote:
> > * Robin Holt <holt@sgi.com>:
> > > Don't know if this answers your problem, but I use the tools from
> > > emdebian and they do not suffer from the problems you list below.
> >
> > Wow, this seems _much_ simpler. Once you get the toolchain
> > installed, all you have to do is set ARCH and CROSS_COMPILE
> > appropriately?
> >
> > I guess the question remains for Andrew. Since I pretty much did
> > all the work needed to update his cross-compiler repo, is there
> > still value in it?
>
> We would benefit very much from having someone who actually maintains a
> suite of cross-compilers for kernel developers.

I already maintain cross compilers for my own use and the uClibc.org guys, 
along with little root filesystems and system images bootable under qemu:

  http://uclibc.org/downloads/binaries

We're about to start doing nightly builds based on uClibc snapshots, I could 
easily get our server to do similar nightly builds based on the git version 
kernel headers and upload 'em to 
http://kernel.org/pub/linux/kernel/people/landley/ if there's any interest...

Rob
-- 
GPLv3 is to GPLv2 what Attack of the Clones is to The Empire Strikes Back.
