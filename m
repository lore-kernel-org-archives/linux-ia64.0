From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 Jan 2004 17:42:58 +0000
Subject: RE: Link error with linux-2.5 bk
Message-Id: <16398.47650.781288.428834@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040120144809.GT27591@localhost>
In-Reply-To: <20040120144809.GT27591@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Jan 2004 08:55:19 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> LD      .tmp_vmlinux1
  >> local symbol 0: discarded in section `.exit.text' from drivers/built-in.o

  Tony> My money is on this change to drivers/net/dummy.c (clipped from diff
  Tony> between bk3 and bk4 trees).  "dummy_free_one()" is marked as __exit (so
  Tony> we'll try to discard it), but it is called by dummy_init_module().

  Tony> Dropping the "__exit" will fix it (but there may be other
  Tony> fixes).  Copying Andi Kleen, as according to BitKeeper he
  Tony> appears to be the author of this change.

Andrew sent me the attached.  He seems to agree with your analysis & fix.

	--david

----------------------------------------------
From: Andrew Morton <akpm@osdl.org>
To: David Mosberger <davidm@linux.hpl.hp.com>
Subject: Fw: dummy.c: __exit section fix
Date: Wed, 21 Jan 2004 01:56:43 -0800


fyi...

Begin forwarded message:

Date: Wed, 21 Jan 2004 01:52:08 -0800
From: Andrew Morton <akpm@osdl.org>
To: "David S. Miller" <davem@redhat.com>
Subject: dummy.c: __exit section fix




dummy_free_one() is marked __exit, but is called from dummy_init_module()
which is marked __init.

It's wrong, and doesn't link on ia64.


---

 25-akpm/drivers/net/dummy.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/dummy.c~dummy-init-fix drivers/net/dummy.c
--- 25/drivers/net/dummy.c~dummy-init-fix	Wed Jan 21 04:13:42 2004
+++ 25-akpm/drivers/net/dummy.c	Wed Jan 21 04:13:42 2004
@@ -112,7 +112,7 @@ static int __init dummy_init_one(int ind
 	return err;
 }
 
-static void __exit dummy_free_one(int index) 
+static void dummy_free_one(int index)
 {
 	unregister_netdev(dummies[index]);
 	free_netdev(dummies[index]);

_
