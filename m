From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 16 Sep 2005 03:27:21 +0000
Subject: Re: [PATCH] mca_drv cleanup
Message-Id: <17194.15257.865949.159579@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <432A38A9.509@jp.fujitsu.com>
In-Reply-To: <432A38A9.509@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Hidetoshi" = Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> writes:

Hidetoshi> There were some trailing white spaces, long lines, and so
Hidetoshi> on.  This patch cleans them.

If you're going to tidy those up, how about changing the style to
conform to Documentation/CodingStyle at the same time?


 	/* whether physical address is valid or not */ 
- if ( !ia64_phys_addr_valid(paddr) ) 
+ if ( !ia64_phys_addr_valid(paddr) ) return ISOLATE_NG;

e.g., 
  if (!ia64_phys_addr_valid(paddr))
	return ISOLATE_NG;


Peter C
