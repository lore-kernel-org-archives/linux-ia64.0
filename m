From: Andi Kleen <ak@suse.de>
Date: Wed, 21 Jan 2004 17:20:19 +0000
Subject: Re: Link error with linux-2.5 bk
Message-Id: <20040121182019.358eed82.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040120144809.GT27591@localhost>
In-Reply-To: <20040120144809.GT27591@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 Jan 2004 08:55:19 -0800
"Luck, Tony" <tony.luck@intel.com> wrote:

> >   LD      .tmp_vmlinux1
> > local symbol 0: discarded in section `.exit.text' from drivers/built-in.o
> 
> My money is on this change to drivers/net/dummy.c (clipped from diff
> between bk3 and bk4 trees).  "dummy_free_one()" is marked as __exit (so
> we'll try to discard it), but it is called by dummy_init_module().
> 
> Dropping the "__exit" will fix it (but there may be other fixes).  Copying
> Andi Kleen, as according to BitKeeper he appears to be the author of this
> change.

Yep, the __exit is wrong. Thanks, Tony.

Jeff, can you apply this patch, please? It should fix compiling in of the dummy
device. 

Thanks.

-Andi

--- linux-2.6.2rc1-amd64/drivers/net/dummy.c-o	2004-01-21 15:52:42.000000000 +0100
+++ linux-2.6.2rc1-amd64/drivers/net/dummy.c	2004-01-21 18:19:05.000000000 +0100
@@ -112,7 +112,7 @@
 	return err;
 }
 
-static void __exit dummy_free_one(int index) 
+static void dummy_free_one(int index) 
 {
 	unregister_netdev(dummies[index]);
 	free_netdev(dummies[index]);


