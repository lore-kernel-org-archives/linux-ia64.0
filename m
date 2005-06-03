From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Jun 2005 18:50:55 +0000
Subject: RE: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F039D7FC3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This explains why XPC has been so troublesome to load on older systems.
>Thanks Dean!
>
>Tony, can this still get into 2.6.12?

Probably ... but the first hunk of the patch looks like a no-op,
and contravenes some style guidlines about initializing global
variables to 0.

-static int shub_1_1_found __initdata;
+static int __initdata shub_1_1_found = 0;

Presumably you'd still like the second hunk?

-Tony
