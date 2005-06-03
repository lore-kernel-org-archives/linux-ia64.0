From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Jun 2005 19:36:07 +0000
Subject: RE: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F039D8051@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>It was my understanding from linux/Documentation/DocBook/kernel-hacking.tmpl
>that '__initdata' meant that the variable shub_1_1_found was not initialized
>to anything (unlike ordinary static data).

I'd never noticed that ... but it does make sense.  I wonder whether there
are any other __initdata declarations, written by people as clueless as me,
that are wrong?

-Tony
