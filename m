From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Feb 2006 20:04:36 +0000
Subject: RE: missing entries in fsys.S
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05B875C0@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060215143359.GB14787@frankl.hpl.hp.com>
In-Reply-To: <20060215143359.GB14787@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Sadly gnu assembler gives only warning if .space's count argument
> is zero or negative.
> 
> I agree that this is redundant given that we already check the
> size in sys_call_table (entry.S).  So this can be removed.  Tony,
> do you want me to send you another patch or you can just massage it?

I think that the .org thing only gives a warning too.

I'll massage the patch (gives me a chance to try out the "git squash"
code that I'm working on).

-Tony
