From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 04 Dec 2003 23:31:34 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107058199512694@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 4 Dec 2003 17:25:28 -0500, Bill Nottingham <notting@redhat.com> said:

  Bill> Comparing readelf output, one big difference is where it loads
  Bill> the percpu data segment:

That should be OK though.  elilo only ever looks at the physical addresses.
Do you have a stale version of elilo by chance?

	--david
