From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 24 Jul 2001 19:27:12 +0000
Subject: RE: [Linux-ia64] heads up: ucd-snmp 64-bit problem
Message-Id: <marc-linux-ia64-105590693005905@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Jul 2001 07:50:41 -0500, Matt_Domsch@Dell.com said:

  >> I hope someone who's more familiar with SNMP can fix this.

  Matt> One of our server management guys has done a great deal of
  Matt> patching on this code.  In many many many places in the code,
  Matt> it's assumed that an IP address is a long, and it's not a
  Matt> simple change.

Yes, I have to say I was a bit shocked when I looked at the code.
Looks like straight from the seventies.  The code also ought to use
inet_aton() instead of inet_addr().

  Matt> You've basically got to track down everywhere an IP address
  Matt> value is used and fix it.  Given this is SNMP, that's a lot of
  Matt> places.  I'll forward this to him and see what can be done.

If he does work on this, could you ask him to cc any patches to
linux-ia64 so everybody can see them?

BTW: I think snmptrapd is suffering from similar problems.

Thanks,

	--david

