From: Eric Piel <Eric.Piel@Bull.Net>
Date: Wed, 26 Mar 2003 12:39:25 +0000
Subject: Re: [Linux-ia64] [PATCH] settimeofday() not synchronised with
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------DC23C7F891317145B2F1D47A"
Message-Id: <marc-linux-ia64-105590723705318@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806076@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806076@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------DC23C7F891317145B2F1D47A
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Eric Piel wrote:
> However, now, it still gives negative difference:
> # ./a.out
> requested:      1047572128s 2564ns
> new:            1047572128s 1588ns
> diff is -0.000976000sec
> 
> That's better but there is still something...
> Can anyone reproduce this bug? Any idea about what may cause this
> shifted results?
> 
> I don't understand what does the line in settimeofday():
>         nsec -= (jiffies - wall_jiffies ) * (1000000000 / HZ);

Finally I read the code to do the same thing for i386 (get and
settimeofday()). This explains the meaning of this line, in the i386
it's associated with the equivalent line in do_gettimeofday()! On ia64
everything is done inside of gettimeoffset(). Therefore I'm now
confident that suppressing this line is a Good Thing ;-) The patch doing
it wrt the bk tree is attached.

The test case confirms that it works:
requested:      1048681051s 194873ns
new:            1048681051s 194874ns
diff is  0.000001000sec

That's the same result than on a 2.4.19 . 
This also solved an error on the high resolution timers test suite.

	Eric
--------------DC23C7F891317145B2F1D47A
Content-Type: text/plain; charset=us-ascii;
 name="settimeofday2-ia64-2.5.64-030326.patch"
Content-Disposition: inline;
 filename="settimeofday2-ia64-2.5.64-030326.patch"
Content-Transfer-Encoding: 7bit

--- arch/ia64/kernel/time.c.back	2003-03-26 11:47:42.000000000 +0100
+++ arch/ia64/kernel/time.c	2003-03-26 11:48:05.000000000 +0100
@@ -98,7 +98,6 @@
 		 * it!
 		 */
 		nsec -= gettimeoffset();
-		nsec -= (jiffies - wall_jiffies ) * (1000000000 / HZ);
 
 		while (unlikely(nsec < 0)) {
 			nsec += 1000000000;

--------------DC23C7F891317145B2F1D47A--


