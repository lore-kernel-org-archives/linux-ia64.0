From: "H . J . Lu" <hjl@valinux.com>
Date: Sun, 10 Sep 2000 23:04:40 +0000
Subject: Re: [Linux-ia64] More on B1 BigSur and test8 kernel
Message-Id: <marc-linux-ia64-105590678205486@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205482@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Sep 10, 2000 at 12:30:01PM -0700, David Mosberger wrote:
> >>>>> On Sun, 10 Sep 2000 12:25:24 -0700, "H . J . Lu" <hjl@valinux.com> said:
> 
>   HJ> compiled on my BigSur with 0825 RedHat ia64 running TurboLinux
>   HJ> 0828 kernel. I get         ^^^^
> 
> That is your problem.  The new toolchain is not ready for the
> compiler.  I stopped tracking the lastest patches and decided to wait
> for a new snapshot.  If you build the kernel with the new toolchain,
> you're on your own.
> 

I got the similar results with the 20000501 toolchain come with the
0825 RedHat ia64 beta distribution. I don't think it is a purely
compiler issue since the same kernel, which works on A2 stepping,
failed to boot on B1 stepping. I suspect some interaction between
the ACPI stuff and the interrupts. It seems on B1 stepping, the
kernel will get interrupts very early on in the ACPI code.

-- 
H.J. Lu (hjl@gnu.org)

