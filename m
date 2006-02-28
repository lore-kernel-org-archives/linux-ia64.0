From: Jes Sorensen <jes@sgi.com>
Date: Tue, 28 Feb 2006 09:49:15 +0000
Subject: Re: [patch] option to quite unaligned trap warnings
Message-Id: <yq0hd6jhkys.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0hd772nhj.fsf@jaguar.mkp.net>
In-Reply-To: <yq0hd772nhj.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

Jes> Hi, This patch is an attempt to find a good compromise to the
Jes> somewhat contentious issue of the unaligned usertrap warnings.

>> I haven't seen any negative reactions to this one yet and it's been
>> a week so far. Tony any chance you would apply it to your tree?

Tony> Yes, though I might trim the printk() message back a bit, it
Tony> seems a bit[1] over the top.  How about just:

Hi Tony,

I didn't see this one go in yet. Were you waiting for me to do an
updated patch?

Admittedly it's something I'd like to see go into 2.6.16.

Cheers,
Jes
