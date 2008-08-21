From: Gerald Pfeifer <gp@novell.com>
Date: Thu, 21 Aug 2008 23:39:55 +0000
Subject: RE: linux-next: ia64 allmodconfig
Message-Id: <alpine.LSU.1.99.0808220133050.16120@enan.fvgr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080820233526.14c44ea6.akpm@linux-foundation.org>
In-Reply-To: <20080820233526.14c44ea6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 21 Aug 2008, Luck, Tony wrote:
> Still need to figure out exactly what broke the build with a 3.x gcc to 
> see if there is an easy workaround. Though 4.0.0 was released over three 
> years ago ... is it time to give up on the ancient 3.x technology?

Yes.  I've got a hard time seeing why anyone would use GCC 3.x to build 
current Linux kernels for Itanium (except when using an acient distro as
the base for kernel development).

> [*] If you ignore that the 4.2.4 compiler is about 15% slower
> than my trusty old 3.4.6 :-(

The resulting binary should be faster, though. ;-)  How about giving
GCC 4.3 a try, by the way?  IIRC, GCC 4.2 has some aliasing issues
that have been addressed.

Gerald
