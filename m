From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Dec 2005 19:02:03 +0000
Subject: RE: [PATCH] Fix missing parameter for local_add
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05235A89@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0512071053450.24789@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0512071053450.24789@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


-#define local_add(l)	atomic64_add(&(l)->val)
+#define local_add(i, l)	atomic64_add((i), &(l)->val)
 #define local_sub(l)	atomic64_sub(&(l)->val)
 
 
local_sub() looks like it could use the same treatment?

-Tony
