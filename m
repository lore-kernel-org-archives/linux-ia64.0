From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 26 Nov 2002 22:30:35 +0000
Subject: Re: [Linux-ia64] Rdesktop 1.10
Message-Id: <marc-linux-ia64-105590709805489@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805488@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805488@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith,

Don't know much about rdesktop or how WTS works, but I was able to get
it to work here at work (pretty neat program, really).  The attached
small patch was needed to avoid a bug that caused the upper 32 bits of
a pointer returned by xmalloc() to be cleared to zero.  There are
certainly better ways of fixing this, but it's probably best to leave
that to the expert (I'm cc'ing Matt on this mail...).

	--david

--- rdesktop-1.1.0/crypto/bn.h~	Mon Sep 17 04:01:03 2001
+++ rdesktop-1.1.0/crypto/bn.h	Tue Nov 26 14:25:55 2002
@@ -67,6 +67,8 @@
 extern "C" {
 #endif
 
+extern void *xmalloc (int size);
+
 #define BNerr(context,err)   error("crypto error\n");
 #define OPENSSL_malloc(size) xmalloc(size)
 #define OPENSSL_free(ptr)    xfree(ptr);


>>>>> On Tue, 26 Nov 2002 14:01:54 -0500, Keith A Howells <keith.howells@bms.com> said:

  Keith> Hi all, downloaded the source from http://www.rdesktop.org

  Keith> ran ./configure then make which seems to complete fine.

  Keith> Getting Error: Recv: Connection reset by peer Broken Pipe

  Keith> Any ideas?  I'm running Rhat 7.2 Advanced Technical
  Keith> Workstation on HP ZX2000 workstation.

  Keith> I don't think there is an IA64 version that i know of.  Maybe
  Keith> in the next release it will be included by Redhat as it is
  Keith> part of the 8.0 release.

  Keith> Thank you for any feedback.

  Keith> Keith

