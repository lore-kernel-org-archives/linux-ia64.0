From: David Howells <dhowells@redhat.com>
Date: Tue, 20 Jun 2017 08:30:14 +0000
Subject: Re: [PATCH 0/7] rwsem: Implement down_read_killable()
Message-Id: <2406.1497947414@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.10.1706191327190.95967@chino.kir.corp.google.com> <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
In-Reply-To: <alpine.DEB.2.10.1706191327190.95967@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Rientjes <rientjes@google.com>
Cc: dhowells@redhat.com, Kirill Tkhai <ktkhai@virtuozzo.com>, linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net

David Rientjes <rientjes@google.com> wrote:

> I would have expected to see down_read_killable() actually used somewhere 
> after its implementation as part of this patchset.

There are some places we should be using down_{read|write}_interruptible(), if
it existed, dressed as inode_lock{,_shared}_interruptible().

David
