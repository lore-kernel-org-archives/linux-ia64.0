From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 04 Apr 2003 15:13:25 +0000
Subject: Re: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705420@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Kevin" = Van Maren, Kevin <kevin.vanmaren@unisys.com> writes:

Kevin> Bleh.  I should have _looked at_ the code: =[snip]
Kevin> No, this will not work: if you need it to work, you need to add
Kevin> a wmb between the store to a and the store to b -- because cpu2
Kevin> is NOT acquiring "bleh", so it CAN see the writes out of order.
Kevin> If you were using "bleh" "properly" (ie, always acquiring it to
Kevin> access a/b) then yes, it should work because the lock/unlock
Kevin> enforce memory consistency.

Hi Kevin,

The first example I sent out was clearly bogus, please ignore it. I am
still pondering the second one. Jack pointed out in private email that
the release semantics of setting a volatible variable should take care
of it, but I am still trying to grasp it.

Now where did I leave my stash of aspirin.

Cheers,
Jes


