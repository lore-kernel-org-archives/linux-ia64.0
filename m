From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 07 Apr 2003 23:13:40 +0000
Subject: Re: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705432@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On 07 Apr 2003 18:09:44 -0400, Jes Sorensen <jes@wildopensource.com> said:
David> Oops, sorry, I got it exactly backwards. ;-( So much for giving
David> a "quick" reply...

Heh, for a quick answer you sure were very convincing. I have
convinced myself for and against this one several times so far ;-)

Jes> In other words we are only guarantied that [r2] is valid when
Jes> [r3] appears but have no guarantie that [r4] doesn't show up on
Jes> the bus prior to [r3]?

David> I wouldn't use the word "valid" here, but yes, (2) and (3) are
David> NOT ordered.

This is the situation I was trying to fix, adding a wmb() to
spin_unlock() seems the only way to get around it as far as I can see.
I take it you agree then?

Cheers,
Jes

