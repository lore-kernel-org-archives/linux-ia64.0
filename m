From: "H . J . Lu" <hjl@valinux.com>
Date: Wed, 16 Aug 2000 18:08:20 +0000
Subject: Re: [Linux-ia64] building glibc
Message-Id: <marc-linux-ia64-105590678205339@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Aug 16, 2000 at 05:54:13PM +1000, Alan Au wrote:
> Hi,
> 
> I'm having trouble building glibc. I'm using the current turbolinux SRPM, 
> glibc-2.1.3-hjl000629p1.src.rpm.
> 
> My build environment is HP's NUE.
> After applying all the patches, doing configure and then make, I get:
> 
> ....
> 
> make  -C misc subdir_lib
> make[2]: Entering directory `/home/alanau/src/glibc/glibc-2.1-hjl/misc'
> make[2]: *** No rule to make target
> `/home/alanau/glibc-build/misc/mincore.o', needed by
> `/home/alanau/glibc-build/misc/stamp.o'.  Stop.
> make[2]: Leaving directory `/home/alanau/src/glibc/glibc-2.1-hjl/misc'
> make[1]: *** [misc/subdir_lib] Error 2
> make[1]: Leaving directory `/home/alanau/src/glibc/glibc-2.1-hjl'
> make: *** [all] Error 2
> 

Your kernel header files are too old.

-- 
H.J. Lu (hjl@gnu.org)

