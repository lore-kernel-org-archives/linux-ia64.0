From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 18 Mar 2005 06:26:12 +0000
Subject: Re: recent fix for pgd_addr_end
Message-Id: <16954.29828.432531.913855@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

Tony> Here's the version that handles region 5 correctly too.  -Tony

Is it always OK to evaluate addr and end more than once?

Or would something like
({ unsigned long __boundary = ((addr) + PGDIR_SIZE) & PGD_MASK;
   unsigend long __region  = __boundary >> 61;
   if (region =5)
      ...
   else
     ...
})
be better?
