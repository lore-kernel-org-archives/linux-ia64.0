From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Sep 2003 20:26:49 +0000
Subject: Re: [PATCH] allocate page tables on the right node
Message-Id: <marc-linux-ia64-106460829220226@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442750600527@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442750600527@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Sep 2003 11:17:57 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> +#define node_distance(from,to)	10

This looks bogus to me.  node_distance() is used as an lvalue in acpi.c.

	--david
