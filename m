From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Jun 2003 18:41:55 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105613465619951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 20 Jun 2003 11:35:31 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> DISCONTIGMEM, NUMA, and ACPI_NUMA have to be turned on
  Jesse> automatically for generic kernels...

I thought the DISCONTIGMEM support is making assumptions about the
physical memory layout.  If this is still true, DISCONTIGMEM and
GENERIC cannot go together.

I suspect it would be more preferable if you could make it possible
for a non-NUMA kernel to boot on your machine.

	--david
