From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 Jul 2004 18:36:35 +0000
Subject: Re: [netfilter-core] strict rejection of init -> core references causes problems
Message-Id: <16622.58803.909534.754777@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16622.17154.117052.31601@napali.hpl.hp.com>
In-Reply-To: <16622.17154.117052.31601@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 9 Jul 2004 10:01:27 +0200, Harald Welte <laforge@netfilter.org> said:

  Harald> Initially Rusty wrote the modules like this, and I very much
  Harald> agree with this decision to not replicate the same code in
  Harald> module_init() and _exit() functions. (which would have to be
  Harald> kept in sync every time some item is added to the
  Harald> initialization chain).

Seems to me the maintainance aspect could be taken care of with inline
functions.  No?

  >> it's common practice, I suppose we don't have much choice but to allow
  >> calls from core to init sections again.  Perhaps someone from the
  >> netfilter team could comment?

  Harald> I wuold very much appreciate if this was still possible in
  Harald> the future.

We don't have much of a choice, but I think it would be worthwhile to
consider whether netfilter could avoid doing this in the future.  It
really is very easy to make a mistake when allowing core->init calls.

	--david
