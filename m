From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 21 Jan 2004 16:55:19 +0000
Subject: RE: Link error with linux-2.5 bk
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F4FB0CF@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040120144809.GT27591@localhost>
In-Reply-To: <20040120144809.GT27591@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   LD      .tmp_vmlinux1
> local symbol 0: discarded in section `.exit.text' from drivers/built-in.o

My money is on this change to drivers/net/dummy.c (clipped from diff
between bk3 and bk4 trees).  "dummy_free_one()" is marked as __exit (so
we'll try to discard it), but it is called by dummy_init_module().

Dropping the "__exit" will fix it (but there may be other fixes).  Copying
Andi Kleen, as according to BitKeeper he appears to be the author of this
change.


-Tony



+static void __exit dummy_free_one(int index) 
+{
+	unregister_netdev(dummies[index]);
+	free_netdev(dummies[index]);
+} 
+
+static int __init dummy_init_module(void)
+{ 
+	int i, err = 0;
+	dummies = kmalloc(numdummies * sizeof(void *), GFP_KERNEL); 
+	if (!dummies)
+		return -ENOMEM; 
+	for (i = 0; i < numdummies && !err; i++)
+		err = dummy_init_one(i); 
+	if (err) { 
+		while (--i >= 0)
+			dummy_free_one(i);
+	}
+	return err;
+} 
+

