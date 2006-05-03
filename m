From: "Bob Picco" <bob.picco@hp.com>
Date: Wed, 03 May 2006 13:38:06 +0000
Subject: strcpy returns NULL pointer and not destination pointer
Message-Id: <20060503133806.GC19859@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ken:

I'm assuming you can speak to this because your email address is in
memcpy_mck.S.

The removal of -ffreestanding compiler flag in 2.6.17-rcX (commit id
6edfba1b33c701108717f4e036320fc39abe1912) causes strcpy calls 
with a known size for the source string to be replaced with memcpy which
is faster.  ia64 memcpy has return values which are unlike stdlibc and
the other arch memcpy routines examined by me in the kernel.  The ia64 return
values are 0 for success and number of bytes copied for failure. Thus any
instance of pointer = strcpy(dest, "some string") has zero assigned to
pointer.  I detected this when testing kgdb on 2.6.17-rc3.  

The implementation in memcpy_mck.S doesn't leave a single scratch
register or predicate. I didn't pursue very long for a solution.

thanks,

bob
