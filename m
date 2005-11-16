From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 16 Nov 2005 22:53:14 +0000
Subject: RE: [PATCH] RFC : Page table macros
Message-Id: <200511162253.jAGMrEg32150@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian Wienand wrote on Wednesday, November 16, 2005 2:42 PM
> Well, therein lies my point.  Is it the size of a pointer or is it the
> size of a pte/middle/uppper/global directory entry?

I think you are mixing up with pte_t versus {pmd_t, pud_t, pgd_t}.
Or maybe we simply don't understand each other :-(

- Ken

