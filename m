From: "H . J . Lu" <hjl@valinux.com>
Date: Wed, 26 Jul 2000 19:29:05 +0000
Subject: Re: [Linux-ia64] Internal Error compiling ddd
Message-Id: <marc-linux-ia64-105590678205231@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205226@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205226@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 24, 2000 at 12:55:22PM -0700, Jim Wilson wrote:
> 
> Red Hat is working on a new toolchain release for the ia64-linux project.  We
> made a CVS branch for the release last Monday, based on the July 10 FSF gcc
> snapshot, and we are now testing the compiler and fixing bugs.  I could make
> a pre-release at any time, but I think we need to fix a couple of more bugs
> before that will be really useful.
> 

Hi, Jim,

I assume you are aware that EH of glibc/gcc is currently broken under
ia64. I have proprosed a fix:

http://gcc.gnu.org/ml/gcc/2000-07/msg00168.html
http://gcc.gnu.org/ml/gcc-bugs/2000-07/msg00117.html

Could you please make sure the new ia64 toolchain is ok?

Thanks.


H.J.


