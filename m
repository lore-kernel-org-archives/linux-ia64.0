From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 19:55:13 +0000
Subject: Re: [PATCH] linux-2.6.3_time-interpolator-fix_A0
Message-Id: <16442.23201.23710.686062@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077081648.985.27.camel@cog.beaverton.ibm.com>
	<1077086574.985.56.camel@cog.beaverton.ibm.com>
	<16435.3326.193311.110598@napali.hpl.hp.com>
	<1077565468.19860.78.camel@cog.beaverton.ibm.com>
In-Reply-To: <1077565468.19860.78.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: john stultz <johnstul@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Chris McDermott <lcm@us.ibm.com>, ia64 <linux-ia64@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, David Mosberger <davidm@hpl.hp.com>

>>>>> On Mon, 23 Feb 2004 11:44:29 -0800, john stultz <johnstul@us.ibm.com> said:

  John> This patch removes the incorrect call to
  John> time_interpolator_update and was found to resolve the time
  John> inconsistencies I had seen while developing the ia64-cyclone
  John> patch.

  John> Please consider for inclusion.

In case it isn't clear: this patch has my support.

	--david
