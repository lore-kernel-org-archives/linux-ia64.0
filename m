From: Grant Grundler <iod00d@hp.com>
Date: Wed, 26 May 2004 03:23:31 +0000
Subject: Re: Installing kernel 2.6.6 on hp zx6000 (fwd)
Message-Id: <20040526032331.GK7616@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 25, 2004 at 04:09:19PM -0400, Younggyun Koh wrote:
> i'm trying to run linux kernel 2.6.6 on hp itanium2 machine - zx6000,
> which is running Redhat advanced server 2.1AW...
> and i got some questions..
> 
> 1. has anyone succeeded with the same condition?

HP formally only tests the original kernels delivered with the OS.
You should just try it if you no longer need formal support from HP.

Nearly all of the folks I know doing 2.6 linux kernel developement are
either using RHEL 3.0, a future release of SLES, or (most likely) Debian.

> 2. nfs-utils currently installed is version 0.3.3. the minimum requirement
> for 2.6.6 is 1.0.5, but i was told from the system management guy that
> installing 1.0.5 might cause serious problems... is it true?

Can you post details?

Sorry - since I run debian "testing" release, I'm not exposed to this kind
of problems. I expect the RHEL update service would avoid them too.
But one wouldn't get a 2.6 kernel yet with that either.

> 3. i got the link error when i build the kernel
> 
> bash-2.05$ make CROSS_COMPILE=/opt/gcc-3.3.3/usr/local/bin/

Can you add "V=1" parameter so we can see the commands?

thanks,
grant
