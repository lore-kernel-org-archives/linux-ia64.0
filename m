From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 03 Jun 2005 21:21:06 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <17056.51650.526508.2673@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 3 Jun 2005 16:09:25 -0500 (CDT), Russ Anderson <rja@sgi.com> said:

  Russ> Tony Luck wrote:

  >>  >It was my understanding from
  >> linux/Documentation/DocBook/kernel-hacking.tmpl >that
  >> '__initdata' meant that the variable shub_1_1_found was not
  >> initialized >to anything (unlike ordinary static data).

  >> I'd never noticed that ... but it does make sense.

Is it really true though?  .init.data is a section that is loaded from
the ELF file and AFAIK the toolchain zeroes data not explicitly
initialized.

	--david
