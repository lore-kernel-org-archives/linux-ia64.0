From: Grant Grundler <iod00d@hp.com>
Date: Wed, 26 May 2004 15:08:13 +0000
Subject: Re: Installing kernel 2.6.6 on hp zx6000 (fwd)
Message-Id: <20040526150813.GD16451@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 26, 2004 at 08:46:19AM -0400, Younggyun Koh wrote:
>         /opt/gcc-3.3.3/usr/local/bin/ld  -static -T

ld isn't part of gcc AFAIK.
I find it odd that it's installed under a "/opt/gcc-3.3.3" directory.
Anyway...other people understand toolchain much better than I.

FWIW, I'm not having problems building kernels with gcc 3.3.3
on any architecture. That's using the current binutils (where
ld lives) from debian "testing" (aka sarge):

grundler@gsyprf3:~$ ld -v
GNU ld version 2.14.90.0.7 20031029 Debian GNU/Linux


grant
