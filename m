From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 28 Apr 2006 08:57:49 +0000
Subject: Re: [rfc] dynamic 3-level / 4-level page table
Message-Id: <4451D90D.4080105@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4sur0l$s99mf@fmsmga001.fm.intel.com>
In-Reply-To: <4sur0l$s99mf@fmsmga001.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Could you please describe how e.g. the VHPT miss handler works
with the modification?
Especially the "LOAD_PGD()" related operations.

Should not we have two instances of the VHPT miss handler:
one for the 3 and one for the 4 level page tables, and
should no we copy the selected one into the trap table at
init. time?

(The source will be more readable, and one could see e.g.
with "gdb vmlinux" how the final code will look like.)

Thanks,

Zoltan
