From: Jack Steiner <steiner@sgi.com>
Date: Thu, 13 Jun 2002 00:56:50 +0000
Subject: [Linux-ia64] pthread failure ???
Message-Id: <marc-linux-ia64-105590701905668@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have a pthread'ed application that ran fine on IA64 2.4.17.

When we upgraded the kernel to 2.4.18, the application started to
fail. The failure occurs in glibc at:
	chunk_free
	__libc_free
	...

We verified that the app consistently fails with a 2.4.18 kernel
but works fine with a 2.4.17 kernel (same app & libraries).

No other failures have been seen in other apps.



Has anyone else seen this behavior or have any ideas??


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


