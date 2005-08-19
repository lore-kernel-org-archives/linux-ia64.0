From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 19 Aug 2005 18:35:35 +0000
Subject: Re: debian/testing cannot compile static with gcc3.3.5
Message-Id: <Pine.LNX.4.62.0508191135090.15808@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050819162011.GB6405@frankl.hpl.hp.com>
In-Reply-To: <20050819162011.GB6405@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 19 Aug 2005, Stephane Eranian wrote:

> I recently upgraded my system to the latest testing.
> Since then, I cannot comile any program with static linking:
> 
> $ cc hello.c -o hello -g -static
> /usr/bin/ld: __libc_errno: TLS definition in /usr/lib/gcc-lib/ia64-linux/3.3.5/../../../libc.a(errno.o) section .tbss mismatches non-TLS reference in /usr/lib/gcc-lib/ia64-linux/3.3.5/../../../libc.a(check_fds.o)
> /usr/lib/gcc-lib/ia64-linux/3.3.5/../../../libc.a: could not read symbols: Bad value
> collect2: ld returned 1 exit status

gcc-4.0 issue? Try rebuilding glibc.

