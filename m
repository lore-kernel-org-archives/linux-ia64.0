From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Sep 2002 03:32:43 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.32)
Message-Id: <marc-linux-ia64-105590701906037@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Sep 2002 13:25:06 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Here's a patch.  The problem was the struct initialisers
  Peter> change in other files --- they meant that the
  Peter> INIT_THREAD_IA32 macro didn't line up properly with the
  Peter> things it was meant to initialise.

I already have this fixed in my tree (2.5.35+, soon...).  I found it
because of a compiler warning, so I didn't realize this was
responsible for triggering the gcc2.96 problem.

	--david

