From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Mar 2005 22:47:53 +0000
Subject: RE: [Patch 3/3] Shrink quicklist based upon node free memory.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03008EFD@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C51F7A.3A2175E9"
List-Id: <linux-ia64.vger.kernel.org>
References: <20050302184312.GD16517@lnx-holt.americas.sgi.com>
In-Reply-To: <20050302184312.GD16517@lnx-holt.americas.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C51F7A.3A2175E9
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Robin,

You define NODE_FREE_PAGES_SHIFT with a comment:

>+/* This value was chosen to prevent a large block of frees to hold off =
timer ticks */
>+#define NODE_FREE_PAGES_SHIFT	4


But then go on to use it in two different ways.  First you limit
the size of the quicklist to 1/16th of the free memory on the node:

>+	max_pgt_pages =3D node_free_pages >> NODE_FREE_PAGES_SHIFT;


And then as a throttle on how many pages to free before enabling
preemption and recalculating how much to free:

>+		pages_to_free =3D min(pages_to_free, 1L << NODE_FREE_PAGES_SHIFT);

The second usage matches the comment ... though the two are somewhat
interconnected (freeing 16 pages from the quicklist will raise your
limit on the size of the quicklist since there will now be more
pages free on the node).

Should there be separate defines for these?

I also played with re-arranging the code in check_pgt_cache()
to try to make it prettier ... I'm not sure whether I succeeded
(see attached).

-Tony

------_=_NextPart_001_01C51F7A.3A2175E9
Content-Type: application/octet-stream;
	name="check_pgt_cache.c"
Content-Transfer-Encoding: base64
Content-Description: check_pgt_cache.c
Content-Disposition: attachment;
	filename="check_pgt_cache.c"

dm9pZApjaGVja19wZ3RfY2FjaGUgKHZvaWQpCnsKCWxvbmcgcGFnZXNfdG9fZnJlZTsKCglpZiAo
dW5saWtlbHkocXVpY2tsaXN0X3NpemUgPD0gTUlOX1BHVF9QQUdFUykpCgkJcmV0dXJuOwoKCWZv
ciAoOzspIHsKCQlwcmVlbXB0X2Rpc2FibGUoKTsKCQlwYWdlc190b19mcmVlID0gcXVpY2tsaXN0
X3NpemUgLSBtYXhfcGd0X3BhZ2VzKCk7CgkJaWYgKGxpa2VseShwYWdlc190b19mcmVlIDw9IDAp
KQoJCQlicmVhazsKCQlwYWdlc190b19mcmVlID0gbWluKHBhZ2VzX3RvX2ZyZWUsIDFMIDw8IE5P
REVfRlJFRV9QQUdFU19TSElGVCk7CgkJd2hpbGUgKHBhZ2VzX3RvX2ZyZWUtLSkgewoJCQlmcmVl
X3BhZ2UoKHVuc2lnbmVkIGxvbmcpcGd0YWJsZV9xdWlja2xpc3RfYWxsb2MoKSk7CgkJfQoJCXBy
ZWVtcHRfZW5hYmxlKCk7Cgl9CglwcmVlbXB0X2VuYWJsZSgpOwp9Cg==

------_=_NextPart_001_01C51F7A.3A2175E9--
