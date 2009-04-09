From: Segher Boessenkool <segher@kernel.crashing.org>
Date: Thu, 09 Apr 2009 20:51:38 +0000
Subject: Re: cross-compilers
Message-Id: <1D6A3AE1-14BE-491F-89F2-BC9CE04F444E@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com> <20090408010331.GB10768@sgi.com> <20090408054612.GA6744@ldl.fc.hp.com> <20090407225457.86f8a458.akpm@linux-foundation.org> <20090408173332.GB20187@ldl.fc.hp.com> <20090409125237.GD7921@lug-owl.de>
In-Reply-To: <20090409125237.GD7921@lug-owl.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan-Benedict Glaw <jbglaw@lug-owl.de>
Cc: Alex Chiang <achiang@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> Is anybody building GCC trunk for the targets on a daily basis?

Not daily yet, but often anyway.  Also binutils and kernel mainline.

Scripts: <http://git.infradead.org/users/segher/buildall.git>

Edit "config" for your local paths etc.
Run  ./build [--kernel] <arch> [<some-defconfig>]  to build a toolchain
and a kernel, or only the kernel if --kernel is given.  Run  ./buildall
to build a toolchain+kernel for all archs.


Segher

