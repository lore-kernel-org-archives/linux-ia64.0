From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 05 Jan 2002 23:30:46 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
Message-Id: <marc-linux-ia64-105590698805751@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805186@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805186@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 05 Jan 2002 16:01:29 +0100, 
Steffen Persvold <sp@scali.no> wrote:
>--- linux-2.4.17/mm/memory.c.orig	Fri Dec 21 18:42:05 2001
>+++ linux-2.4.17/mm/memory.c	Sat Jan  5 13:13:26 2002
>@@ -791,6 +791,9 @@
>  * maps a range of physical memory into the requested pages. the old
>  * mappings are removed. any references to nonexistent pages results
>  * in null mappings (currently treated as "copy-on-access")
>+ *
>+ * For physical (or I/O) memory mapped into the kernel virtual space,
>+ * the old mappings will not be removed.

That comment worries me.  If you have multiple mappings for the same
page then you may have problems on hardware that uses virtually indexed
caches.  Two virtual addresses could map to the same physical page but
index to different cache lines, destroying cache coherency.  How do you
prevent that?


