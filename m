From: Don Dugger <n0ano@valinux.com>
Date: Wed, 26 Apr 2000 14:47:47 +0000
Subject: Re: [Linux-ia64] 2.3.99-pre5 Kernel Compile
Message-Id: <marc-linux-ia64-105590678205049@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205048@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205048@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ronen-

Remove the `-g' flag from the `CFLAGS' definition in your top level
`Makefile' and your kernel should go back to ~5M.

On Wed, Apr 26, 2000 at 10:40:02AM -0400, roneng@ca.ibm.com wrote:
> 
> 
> Hi,
> 
> I was wondering if anyone has had a problem with very large kernel sizes
> when
> compiling the 2.3.99-pre5 kernel with the 4/24 patch.
> When I compile this kernel I get a 34Mb kernel, but when I compile the
>  2.3.47 kernel sources in turbolinux distribution with the same .config
> file
> I get a 5MB kernel. The toolchains I have tries have been the 2/16
> toolchain
> included with the turbolinux distribution and the 3/23 toolchain (
> gnupro-2.9-000323.src.rpm).
> 
> 
> Thank you,
> Ronen Grosman
> - e-mail roneng@ca.ibm.com
> 
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838


