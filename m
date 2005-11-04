From: Dean Nelson <dcn@sgi.com>
Date: Fri, 04 Nov 2005 17:20:18 +0000
Subject: Re: [Patch 2.6.14] Extend notify_die() hooks for IA64
Message-Id: <20051104172018.GA8306@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5844.1130898771@kao2.melbourne.sgi.com>
In-Reply-To: <5844.1130898771@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 02, 2005 at 03:34:39PM -0600, Dean Nelson wrote:
> On Wed, Nov 02, 2005 at 02:29:21PM +1100, Keith Owens wrote:
> 
> I called panic() and induced a MCA error, both worked as expected. I did
> have trouble trying to induce a recoverable MCA due to a problem with
> our error injector. It was not an issue with this patch since our error
> injector was also failing on a vanilla Tony Luck test tree (i.e., minus
> your patch).

The issues with our error injector were finally resolved, but in trying
to induce a recoverable MCA error, I did encounter a problem with Keith's
patch. The fix follows. Once fixed, recoverable MCAs worked as expected.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6.git-test/arch/ia64/kernel/mca.c
=================================--- linux-2.6.git-test.orig/arch/ia64/kernel/mca.c	2005-11-04 07:49:29.943576388 -0600
+++ linux-2.6.git-test/arch/ia64/kernel/mca.c	2005-11-04 08:46:05.500525374 -0600
@@ -1621,7 +1621,7 @@
 		       "(status %ld)\n", rc);
 		return;
 	}
-	if (!register_die_notifier(&default_init_monarch_nb)) {
+	if (register_die_notifier(&default_init_monarch_nb)) {
 		printk(KERN_ERR "Failed to register default monarch INIT process\n");
 		return;
 	}
