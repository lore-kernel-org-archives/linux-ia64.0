From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 19 Dec 2003 23:07:29 +0000
Subject: Re: [PATCH] initialize bootmem maps in reverse order
Message-Id: <marc-linux-ia64-107187526421837@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107151544512148@msgid-missing>
In-Reply-To: <marc-linux-ia64-107151544512148@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Dec 2003 07:12:39 -0800, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> Great!  Fixed it first try! :) David, does this patch look ok
  Jesse> for 2.6.1?

The patch looks fine to me, except for the weird whitespace in front of
the declration of "cpu_data" (not introduced by your patch, but while
you're working in that neighborhood, why not fix it?).

Also, please include a brief description of what the patch does (for
bk changelog).  You probably have done that with the original patch,
but I don't have that anymore.

Thanks,

	--david
