From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 Jan 2004 18:43:17 +0000
Subject: Re: [patch] 2.6.1-mm5 compile do not use shared extable code for ia64
Message-Id: <16398.51269.149031.241526@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
In-Reply-To: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@trained-monkey.org>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Paul Mackerras <paulus@samba.org>

>>>>> On Tue, 20 Jan 2004 07:23:49 -0500, Jes Sorensen <jes@trained-monkey.org> said:

  Jes> Hi,
  Jes> The new sort_extable and shares search_extable code doesn't work on
  Jes> ia64. I have introduced two new #defines that archs can define to avoid
  Jes> the common code being built. ARCH_HAS_SEARCH_EXTABLE and
  Jes> ARCH_HAS_SORT_EXTABLE.

  Jes> With this patch, 2.6.1-mm5 builds again on ia64.

What's this about?  Isn't the only reason this doesn't work because
the "insn" member is called "addr" on ia64?  If so, surely it would
make more sense to do a little renaming?

	--david
