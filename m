From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 00:57:22 +0000
Subject: Re: GENERIC still failing?
Message-Id: <marc-linux-ia64-106617945608706@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617635106445@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617635106445@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 14 Oct 2003 17:22:05 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> Looks like CONFIG_NUMA and CONFIG_DISCONTIGMEM are missing
  Jesse> from the config being built.  A generic kernel won't work
  Jesse> without them.

Shouldn't they be forced for GENERIC, then?

	--david
