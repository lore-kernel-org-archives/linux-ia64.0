From: Uros Prestor <uros@turbolinux.com>
Date: Sun, 10 Sep 2000 19:58:52 +0000
Subject: Re: [Linux-ia64] More on B1 BigSur and test8 kernel
Message-Id: <marc-linux-ia64-105590678205484@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205482@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> said:

> >>>>> On Sun, 10 Sep 2000 12:25:24 -0700, "H . J . Lu" <hjl@valinux.com> 
said:
> 
>   HJ> compiled on my BigSur with 0825 RedHat ia64 running TurboLinux
>   HJ> 0828 kernel. I get         ^^^^
> 
> That is your problem.  The new toolchain is not ready for the
> compiler.  I stopped tracking the lastest patches and decided to wait
> for a new snapshot.  If you build the kernel with the new toolchain,
> you're on your own.

David,

I was compiling test8 with the May compiler snapshot and I observed
pretty much the same behaviour as HJ.  I didn't try out his patches, though.

Uros

-- 
Uros Prestor
uros@turbolinux.com



