From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Fri, 04 Apr 2003 14:49:09 +0000
Subject: RE: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705418@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bleh.  I should have _looked at_ the code:

=
Consider the following example:

cpu1()
{
   spin_lock(&bleh);
   *a = foo;
   *b = bar;
   spin_unlock(&bleh);
}

cpu2()
{
   if (*b = bar)
      boink(*a);
}

=
No, this will not work: if you need it to work, you need to add a wmb
between the store to a and the store to b -- because cpu2 is NOT
acquiring "bleh", so it CAN see the writes out of order.  If you
were using "bleh" "properly" (ie, always acquiring it to access a/b)
then yes, it should work because the lock/unlock enforce memory
consistency.

Kevin

