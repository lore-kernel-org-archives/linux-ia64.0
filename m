From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Nov 2002 19:26:31 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805374@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 8 Nov 2002 19:19:07 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Fri, Nov 08, 2002 at 12:05:30PM -0600, Van Maren, Kevin
  Matthew> wrote:
  >> Absolutely you should minimize the locking contention.  However,
  >> that isn't always possible, such as when you have 64 processors
  >> contending on the same resource.

  Matthew> if you've got 64 processors contending on the same
  Matthew> resource, maybe you need to split that resource up so they
  Matthew> can have a copy each.  all that cacheline bouncing can't do
  Matthew> your numa boxes any good.

Matthew, please understand that this is NOT a performance problem.
It's a correctness problem.  If livelock can resolut from read-write locks,
it's a huge security problem.  Period.

	--david

