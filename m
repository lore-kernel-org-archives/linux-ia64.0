From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 03 Feb 2006 18:30:37 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <200602031830.k13IUbg19769@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Friday, February 03, 2006 10:04 AM
> [1] http://tinyurl.com/ah642

Ha, should've check the archive :-)

Now that I read the whole thread, how about remove pining DTR 
requirement for per-cpu data?  In alt_dtlb_miss, we can just
detect whether ifa is per_cpu address and read ar.k3 to get the
physical address, then insert a TC.  That will free up a tlb
entry for application to use.

- Ken

