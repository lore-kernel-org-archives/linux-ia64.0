From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 Feb 2004 02:07:58 +0000
Subject: Re: [RFC][PATCH] linux-2.6.3-rc2_ia64-cyclone_A0
Message-Id: <16428.12670.436074.979908@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076556140.795.119.camel@cog.beaverton.ibm.com>
In-Reply-To: <1076556140.795.119.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 12 Feb 2004 17:41:44 -0800, Chris McDermott <lcm@us.ibm.com> said:

  Chris> The x450/x455 doesn't set/implement the SAL ITC drift
  Chris> bit. Could you point us to where this is documentated?  The
  Chris> latest SAL spec (Dec 2003) didn't have reference to this flag
  Chris> being implemented in the Platform Features Descriptor Entry
  Chris> in the SST.

Hmmh, you're right: I don't see it either in the public documentation.
I got confirmation from Intel on 8 Nov 2001 that bit 3 of the
platform-feature vector will be defined as the ITC_DRIFT bit and the
SAL documentation was supposed to have been updated Q1 2002.  Looks to
me like something got lost along the way.  Can someone from Intel
clarify?

	--david
