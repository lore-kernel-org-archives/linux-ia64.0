From: Don Dugger <n0ano@valinux.com>
Date: Wed, 18 Oct 2000 14:32:04 +0000
Subject: Re: [Linux-ia64] running ia32 binaries with same .so names as ia64
Message-Id: <marc-linux-ia64-105590678205592@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205587@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205587@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ross-

In a word, `ldconfig' is your friend.

We've modified the Runtime loader to only get libraries of the
appropriate architecture out of the `/etc/ld.so.cache'.  All you
need to do is put your IA64 and IA32 libraries in different
directories, put those directory names in `/etc/ld.so.conf'
and then run `ldconfig' to create the cache. From then on your IA64
and IA32 programs can refer to libraries of the same name and
get the right one.

As an example, my `/etc/ld.so.conf' contains:

	/usr/lib
	/usr/X11R6/lib
	/usr/ia32/lib
	/usr/ia32/urs/lib
	/usr/ia32/usr/X11R6/lib

Just make sure you re-run `ldconfig' after you put a new library
in one of these directories.

On Tue, Oct 17, 2000 at 06:49:29PM -0700, Ross A. Towle wrote:
> Since Perl is not working for the SPEC harness, I have brought over
> specperl that SPEC2000 distribution disk which is for RedHat6.0 and
> later.
> 
> When I run it looks for an IA32 libgdbm.so.2 and reports "error in loading
> shared libraries: libgdbm.so.2: ELF file class not 32-bit". So I copied it from
> a IA32 box from /usr/lib and put it in /usr/i386-glibc21-linux/usr/lib.  This
> still does not fix the problem (same error message).  But if I put it in
> /usr/lib/temp and set LD_LIBRARY_PATH to /usr/lib/temp:$LD_LIBRARY_PATH
> then everything runs fine.
> 
> Any ideas on how to do this without the LD_LIBRARY_PATH?
> 
> To generalize,  if I want to bring over a IA32 binary linked against
> some .so's with the same name(s) as on IA64, where do I place the IA32 .so's so
> they are found without setting LD_LIBRARY_PATH?
> 
> -Ross
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

