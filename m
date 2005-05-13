From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 13 May 2005 17:54:11 +0000
Subject: RE: elf header bits for page migration support......
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03793A73@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42847F6B.3080609@engr.sgi.com>
In-Reply-To: <42847F6B.3080609@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The alternative being suggested is to mark the elf header of object files
>that should only have shared pages migrated, or that should not be migrated
>(e. g. you don't want to migrate /bin/csh all the time.)

No ... I'd like you to replicate shared pages (of /bin/bash ... I personally don't
care what happens to the pages of /bin/csh :-)

>Can I use some bits (I need 2) of p_flags of Elf64_Phdr for this purpose?
>If so, which bits?
>
>If not which other fields can I use?

I think H.J's suggestion of an extra section makes sense ... then you can go
wild with as many bits as you can dream up uses for, rather than constraining
yourself to squeeze into just 2 bits.

-Tony
