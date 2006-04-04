From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 Apr 2006 14:23:32 +0000
Subject: RE: [PATCH] eliminate compiler warning for xpc_channel.c
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0622396D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
In-Reply-To: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Placate a compiler warning that 'msg' may be used uninitialized in
> function xpc_initiate_allocate().

Which version of which compiler ... at first glance the code looks
trivially OK (&msg is passed to xpc_allocate_msg() before it is used).
On closer inspection I assume that the compiler must have inlined
xpc_allocate_msg() in order to detect this, and there are four "return"
statements in there that can return w/o doing the initialization. So
the warning is real, and we are not just "placating" the compiler.

-	struct xpc_msg *msg;
+	struct xpc_msg *msg = msg;

Did you mean to say "*msg = NULL"?

-Tony
