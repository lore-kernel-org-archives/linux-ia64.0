From: bdale@gag.com (Bdale Garbee)
Date: Wed, 31 Oct 2001 21:39:03 +0000
Subject: [Linux-ia64] gcc won't inline function returning struct?
Message-Id: <marc-linux-ia64-105590698805421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm playing around with Thomas Sailer's user space soundcard modems for use
on amateur radio links.  One of the things he includes is a small library of 
complex math functions intended to be used inline.  The way this is coded is
to create a .h file with the gcc "magic" use of extern and inline, like so:

	typedef struct {
        	float re, im;
	} complex;

	/*
 	* Complex multiplication.
 	*/
	extern __inline__ complex cmul(complex x, complex y)
	{
        	complex z;
	
        	z.re = x.re * y.re - x.im * y.im;
        	z.im = x.re * y.im + x.im * y.re;
	
        	return z;
	}

A couple of C source files in the same directory include the header containing
this code, and are aggregated into a .a that an application in an adjacent
directory links against later in the build process.

On my Pentium laptop running Debian with a 2.95.4 compiler, this builds and
runs fine.  On my Itanium system running Debian with everyone's favorite 2.96
plus lots of patches, the above function fails to inline with the complaint

	complex.h: In function `cmul':
	complex.h:14: warning: inline functions not supported for this 
		return value type

when I add a -Winline.  I get the same complaint with gcc-3.0.  The effect of
this is that since the function isn't inlined it's left as an extern, and the
linker can't find it when it tries to link the application against this lib
later in the build.

So, my question.  Why does the ia64 gcc not handle this when the i386 gcc 
likes it just fine?  That's way beyond my toolchain knowledge right now...

Bdale

