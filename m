From: Grant Grundler <iod00d@hp.com>
Date: Sat, 09 Apr 2005 05:16:53 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <20050409051653.GL3844@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 08, 2005 at 09:05:48PM -0700, David Mosberger wrote:
...
> #if __GNUC__ >= 4 || (__GNUC__ = 3 && __GNUC_MINOR__ >= 4)
> # define popcount(x)         __builtin_popcountl(x)
> #else
> # define popcount(x)         ia64_popcnt(x)
> #endif

Ah - thanks!
I didn't know how gcc versions could be determined.
(And was too lazy to look it up now.  /o\ )

I was told "build-tools" was the wrong repository and I have to agree.
Now available from:
	wget http://cvs.parisc-linux.org/*checkout*/userspace/test_fls.c

Or for the CVS enabled:
	cvs -d :pserver:anonymous@cvs.parisc-linux.org:/var/cvs co userspace


Randolph Chung played around with it on hppa and noted quickly
that gcc 4.0 with -O3 and -O4 was optimizing out the entire indirect
function call.  Adding a consumer of the return value fixed that.
We've also put asm() "barriers" around the loop to prevent code from
"leaking" outside the measured area though that might be overkill:

@@ -300,11 +304,14 @@
        struct timeval start, stop;
	long i, count = 1000000;
	double t;
+       volatile int discard;
			 
	while (1) {
		gettimeofday(&start, NULL);
+		asm volatile ("":::"memory");
		for (i = 0; i < count; ++i)
-                       (*func)(i | (i << 16));
+                       discard = (*func)(i | (i << 16));
+               asm volatile ("":::"memory");
		gettimeofday(&stop, NULL);

		t = ((stop.tv_sec + 1e-6*stop.tv_usec)


Results on my 1.5hz Madison are slightly different than what was
previously posted:

grundler@iota:/usr/src/userspace$ gcc-3.3 -O2 test_fls.c 
grundler@iota:/usr/src/userspace$ ./a.out
done with correctness test
  overhead:     4.007 ns
   generic:     8.680 ns
    womack:    12.019 ns
      arch:    10.683 ns
  popcount:    10.015 ns
  ia64_fls:    10.016 ns
popcount64:    10.683 ns
grundler@iota:/usr/src/userspace$ gcc-3.4 -O2 test_fls.c 
grundler@iota:/usr/src/userspace$ ./a.out
done with correctness test
  overhead:     5.342 ns
   generic:     8.013 ns
    womack:     8.680 ns
      arch:     8.681 ns
  popcount:     7.345 ns
  ia64_fls:     7.345 ns
popcount64:     8.680 ns

thanks,
grant
