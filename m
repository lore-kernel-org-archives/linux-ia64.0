From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Mar 2006 10:19:09 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05FAAA03@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We have quoted several times the SDM:
> 
> "The visibility of the itc instruction to generated purges (ptc.g, ptc.ga) must occur \
> before subsequent memory operations. From a software perspective, this is similar to \
> acquire semantics. Serialization is still required to observe the side-effects of the \
> translation being present."
> 
> What do you think the statement "Serialization is still required..." means
> if not a "srlz.d" (or "rfi") ?

I'm trying to get some clarifications on this ... my personal interpretation
of this section is that it only refers to memory references that will use
the translation that is being inserted by the itc.d instruction. But I agree
that there are lots of ways to read these three sentences.

-Tony
