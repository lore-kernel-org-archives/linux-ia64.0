From: "Truong, Dan" <dan.truong@hp.com>
Date: Thu, 22 Dec 2005 13:31:09 +0000
Subject: RE: [perfmon] Re: quick overview of the perfmon2 interface
Message-Id: <3C87FFF91369A242B9C9147F8BD0908A02C69459@cacexc04.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219113140.GC2690@frankl.hpl.hp.com>
In-Reply-To: <20051219113140.GC2690@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eranian, Stephane" <stephane.eranian@hp.com>, Andrew Morton <akpm@osdl.org>
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

> Thanks to David, Dan and Phil for their comments.

Another note on the urgency of standardizing Perfmon:

Anarchy is not a good breeding ground for tools that need a
stable infrastructure to mature. Being "there" is what made
PAPI and perfctr popular and somewhat standard infrastructure.

Compilers, tools, JVMs... -you name it- are all moving
fast towards using hardware counters to get feedback,
tune, monitor or measure application behavior.

The PMU is becoming a standard commodity. Once Perfmon is
"the" Linux interface, all the tools can align on it and
coexist, push their R&D forward, and more importantly become
fully productized for businesses usage. Hopefully Perfmon's
interface is powerful enough to support future needs.

Good luck Stephane :)

Cheers,

Dan-
