From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 12 Jul 2005 19:05:19 +0000
Subject: RE: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03E3D66C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>/dev/[k]mem should use the EFI memory attributes to determine
>accessibility.  This is being done to some degree already (well, I
>didn't check the current code, but it's supposed to be there).

The current code relies on checking "PageUncached(page)" to decide
whether to convert a region 7 access into a region 6 access.

But this patch would allow any address in region 6 to be accessed
(and so we'd see an MCA if the address had been cached via a
region 7 access ... or for that matter a user-mode access).

Now, I suppose we could build on this patch so that if a user tries
to access a cacheable page through region 6, we'll quietly swap it
for an cacheable access to the matching address in region 7.  But I'm
not sure whether this is really useful.  Region 6 and 7 provide
access to the same memory, but with different cache attributes.

It comes down to what the real semantics of /dev/kmem are supposed
to be.

-Tony
