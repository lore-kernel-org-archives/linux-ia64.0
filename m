From: "H . J . Lu" <hjl@valinux.com>
Date: Wed, 19 Jul 2000 15:39:57 +0000
Subject: Re: [Linux-ia64] IA64 Linux library problem
Message-Id: <marc-linux-ia64-105590678205214@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205213@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205213@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 19, 2000 at 05:30:23PM +0200, Einar Saltnes wrote:
> Hello!
> 
> We are experiencing some problems using some library routines on ia64.
> We have an Itanium monoprocessor from Fujitsu Siemens running Red Hat
> Linux
> Development Release for IA-64.
> 
> 
> 1)
> We experience that
> sysconf(_SC_NPROCESSORS_ONLN) returns 0 (zero) on a monoprocessor ia64.
> 

Known problem. It is a mismatch between libc and kernel.

> 
> 2)
> We also experience errors using
>  cout << xxx << endl;
> when linking with the pthread library.
> Using "endl" will give segmentation fault when linking with pthread
> library, while the very same statement will be OK when not linking with

It is a known problem. libc is MT safe. But libstdc++ is not configured
for MT safe.


H.J.


