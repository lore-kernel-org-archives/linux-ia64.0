From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 18 Aug 2005 05:09:12 +0000
Subject: RE: Looking for MCA/INIT register test program
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F042C785A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5289.1124337382@kao2.melbourne.sgi.com>
In-Reply-To: <5289.1124337382@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I have a dim, distant memory that somebody (Tony Luck?) wrote a program
>that loaded all the registers, generated a recoverable MCA or INIT then
>verified that the registers still matched.  Google did not find it.
>Any pointers?

I wrote a program that sounds a lot like that.  It does the bit
about saving registers, and checking them.  But it is left as
an exercise for the user to generate the MCA.

The program is at:

 http://www.kernel.org/pub/linux/kernel/people/aegl/ia64regcheck.tgz

-Tony
