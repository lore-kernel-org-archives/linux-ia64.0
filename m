From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Oct 2003 20:36:51 +0000
Subject: Re: [PATCH] kill two dead headers
Message-Id: <marc-linux-ia64-106573199519339@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451477025244@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451477025244@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, I was under the impression that Christoph was working with SGI's
approval.  I don't want to get into the middle of an SGI-internal
dispute so I'm proposing to do the following:

 - The patches that got accepted already will stay there.  In my
   opinion, they improve the state of the SN directories and
   personally I'm glad to see someone finally started to clean them
   up. I'm sorry if this causes some conflicts with an SGI-internal
   tree, but we have only the public tree to go by.  Hopefully, it's
   reasonably straightforward to merge Christoph's patches into your
   internal tree.

 - For the future, I'll accept patches for the SN tree only from Jesse
   Barnes (of course, you can delegate internally as you wish, but I
   prefer to have a single contact for the SN subdirectories and Jesse
   has proven responsive and responsible so far).  Of course, should
   there be complaints that contributed patches are not handled in a
   timely fashion (as Christoph alleged), then we may have to revise
   this decision.

Does this work for everyone?

	--david
