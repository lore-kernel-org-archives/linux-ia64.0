From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Mon, 13 Dec 2004 22:16:19 +0000
Subject: Re: Anticipatory prefaulting in the page fault handler V1
Message-Id: <8880000.1102976179@flay>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain><156610000.1102546207@flay> <Pine.LNX.4.58.0412091130160.796@schroedinger.engr.sgi.com><200412132330.23893.amgta@yacht.ocn.ne.jp> <Pine.LNX.4.58.0412130905140.360@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412130905140.360@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, Akinobu Mita <amgta@yacht.ocn.ne.jp>
Cc: nickpiggin@yahoo.com.au, Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>> I also encountered processes segfault.
>> Below patch fix several problems.
>> 
>> 1) if no pages could allocated, returns VM_FAULT_OOM
>> 2) fix duplicated pte_offset_map() call
> 
> I also saw these two issues and I think I dealt with them in a forthcoming
> patch.
> 
>> 3) don't set_pte() for the entry which already have been set
> 
> Not sure how this could have happened in the patch.
> 
> Could you try my updated version:

Urgle. There was a fix from Hugh too ... any chance you could just stick
a whole new patch somewhere? I'm too idle/stupid to work it out ;-)

M.

