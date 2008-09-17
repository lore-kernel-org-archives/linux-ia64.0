From: Roland McGrath <roland@redhat.com>
Date: Wed, 17 Sep 2008 17:01:22 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <20080917170122.7797E640A5@pipsqueak.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	<48450864.6080707@suse.cz>
	<48455619.6040608@suse.cz>
	<3877989d0806031916wf11bb2t3847aa630fb39e60@mail.gmail.com>
	<48465D5C.8000804@suse.cz>
	<3877989d0806041849vb903aaw221de929e2ab8cb9@mail.gmail.com>
	<1212664605.15747.16.camel@elijah.suse.cz>
	<20080627204954.34F8B154231@magilla.localdomain>
	<3877989d0809082006v496bae4i1c0736f5d55e9b9f@mail.gmail.com>
	<20080910055504.9A2A41541FE@magilla.localdomain>
	<3877989d0809160150y385edd59i231aca8b1073ce14@mail.gmail.com>
In-Reply-To: Luming Yu's message of  Tuesday, 16 September 2008 16:50:24 +0800 <3877989d0809160150y385edd59i231aca8b1073ce14@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

So is there or is there not any regression (change) in the kernel's behavior?

If you are now just talking about strace's own code, then the place for
that is strace-devel@lists.sourceforge.net, not any kernel lists.


Thanks,
Roland
