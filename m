From: "H . J . Lu" <hjl@valinux.com>
Date: Mon, 13 Nov 2000 20:59:54 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test1 0 and upper?
Message-Id: <marc-linux-ia64-105590678205695@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 13, 2000 at 12:38:40PM -0800, Broadfoot, KenX wrote:
> Redhat 7.0 shipped with two compilers.
> The new one is gcc 2.95 and it is terrible for compiling kernels. ( ia32 )
> 

I have very few problems with gcc 2.96 in RedHat 7.0. You just need 2
small kernel patches. 

# cat /proc/version
Linux version 2.2.17-0.5smp (root@load137.var.com) (gcc version 2.96 20000731 (Red Hat Linux 7.0)) #1 SMP Mon Oct 16 14:35:44 PDT 2000


H.J.

