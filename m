From: Jim Wilson <wilson@specifixinc.com>
Date: Sat, 07 Feb 2004 02:05:15 +0000
Subject: RE: gcc problems
Message-Id: <1076119515.1051.169.camel@leaf.tuliptree.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-02-06 at 09:34, Wichmann, Mats D wrote:
> If it's a question of glibc 2.2.x vs. 2.3.x, there are
> ia64 Linux distributions based on glibc 2.2 that work
> pretty well - SUSE's SLES8, for example.

gcc-3.x will have some problems when used on a glibc-2.2.x system, but
most of them are obscure, and probably none of them apply to building
kernels, because the kernel doesn't link in glibc.

It is reasonable that gcc should be buildable though.  I believe the
following patch solves this problem.  I just ifdefed out the code for
old glibc versions.  I see no point in trying to make this work, because
unwinding will fail (for user apps) for other reasons if you are using
glibc-2.2.4.

I don't have access to a glibc-2.2.4 system for testing.  I can't use
such old systems for gcc 3.x development.  It works OK for glibc 2.3,
where it has no effect.  If someone tells me that this does work, then I
can check it into the FSF gcc sources.

2004-02-06  James E Wilson  <wilson@specifixinc.com>

	* config/ia64/linux.h (MD_FALLBACK_FRAME_STATE_FOR): Only define for
	glibc 2.3 or better.

Index: linux.h
=================================RCS file: /cvs/gcc/gcc/gcc/config/ia64/linux.h,v
retrieving revision 1.27
diff -p -r1.27 linux.h
*** linux.h	19 Dec 2003 14:00:51 -0000	1.27
--- linux.h	7 Feb 2004 01:50:46 -0000
*************** do {						\
*** 58,63 ****
--- 58,68 ----
  /* Do code reading to identify a signal frame, and set the frame
     state data appropriately.  See unwind-dw2.c for the structs.  */
  
+ /* This works only for glibc-2.3 and later, because sigcontext is different
+    in glibc-2.2.4.  */
+ 
+ #if __GLIBC__ > 2 || (__GLIBC__ = 2 && __GLIBC_MINOR__ >= 3)
+ 
  #ifdef IN_LIBGCC2
  #include <signal.h>
  #include <sys/ucontext.h>
*************** do {						\
*** 207,209 ****
--- 212,215 ----
      }
  
  #endif /* IN_LIBGCC2 */
+ #endif /* glibc-2.3 or better */
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

