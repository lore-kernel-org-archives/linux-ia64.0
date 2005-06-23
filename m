From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 23 Jun 2005 17:52:18 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <17082.63186.449160.941707@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 23 Jun 2005 12:30:23 -0500 (CDT), Russ Anderson <rja@sgi.com> said:

  Russ> -ENTRY(interrupt)
  Russ> +GLOBAL_ENTRY(interrupt)

Please don't create such name-space pollution.

AFAICS, you should be able to use ia64_ivt and the architected offset
for the external-interrupt handler instead.

	--david
