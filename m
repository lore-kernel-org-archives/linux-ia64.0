From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 04 Mar 2005 12:26:31 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <yq0k6onegw8.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	<20050303033704.6fb77a34.akpm@osdl.org>
	<yq0r7iwevqm.fsf@jaguar.mkp.net>
In-Reply-To: <yq0r7iwevqm.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Jes" = Jes Sorensen <jes@wildopensource.com> writes:

>>>>> "Andrew" = Andrew Morton <akpm@osdl.org> writes:
Andrew> This patch causes hiccups on my ia32e box.

Andrew> linux:/home/akpm# /usr/sbin/hwscan --isapnp zsh: 7528
Andrew> segmentation fault

Jes> Weird, I'll take a look.

-EPROGRAMMERISANIDIOT ... try this.

Cheers,
Jes

/dev/mem handle read/write case where ppos+count < PAGE_SIZE

Signed-off-by: Jes Sorensen <jes@wildopensource.com>


--- ../old/linux-2.6.11-rc5-mm1/drivers/char/mem.c	2005-03-04 07:20:51.000000000 -0500
+++ drivers/char/mem.c	2005-03-04 07:22:20.000000000 -0500
@@ -152,7 +152,9 @@
 		if (-p & (PAGE_SIZE - 1))
 			sz = -p & (PAGE_SIZE - 1);
 		else
-			sz = min_t(unsigned long, PAGE_SIZE, count);
+			sz = PAGE_SIZE;
+
+		sz = min_t(unsigned long, sz, count);
 
 		/*
 		 * On ia64 if a page has been mapped somewhere as
@@ -207,7 +209,9 @@
 		if (-p & (PAGE_SIZE - 1))
 			sz = -p & (PAGE_SIZE - 1);
 		else
-			sz = min_t(unsigned long, PAGE_SIZE, count);
+			sz = PAGE_SIZE;
+
+		sz = min_t(unsigned long, sz, count);
 
 		/*
 		 * On ia64 if a page has been mapped somewhere as
@@ -353,7 +357,9 @@
 			if (-p & (PAGE_SIZE - 1))
 				sz = -p & (PAGE_SIZE - 1);
 			else
-				sz = min_t(unsigned long, PAGE_SIZE, count);
+				sz = PAGE_SIZE;
+
+			sz = min_t(unsigned long, sz, count);
 
 			/*
 			 * On ia64 if a page has been mapped somewhere as
@@ -430,7 +436,9 @@
 		if (-realp & (PAGE_SIZE - 1))
 			sz = -realp & (PAGE_SIZE - 1);
 		else
-			sz = min_t(unsigned long, PAGE_SIZE, count);
+			sz = PAGE_SIZE;
+
+		sz = min_t(unsigned long, sz, count);
 
 		/*
 		 * On ia64 if a page has been mapped somewhere as
