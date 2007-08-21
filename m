From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 21 Aug 2007 09:21:46 +0000
Subject: Re: [perfmon] perfmon2 kernel: git tree up and running
Message-Id: <20070821092146.GB11173@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070820131605.GE8667@frankl.hpl.hp.com> <16D5B9AB904B0B46B22A27002EE3A8C8C9712C@scsmsx415.amr.corp.intel.com> <46C9D90B.3040001@redhat.com>
In-Reply-To: <46C9D90B.3040001@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de

Hello All,

I have found the source of the problem for the tree not showing
up at http://git.kernel.org. The tree top dir needs to have the
.git suffix. I fixed that now and you can now browse the code online.

I am sorry about the inconvenience but I was not aware of the
restriction.

Anyway, to get a of copy of the perfmon2 kernel tree:

	git clone git://git.kernel.org/pub/scm/linux/kernel/git/eranian/linux-2.6.git

Thanks.

--
-Stephane
