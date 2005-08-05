From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 05 Aug 2005 11:36:54 +0000
Subject: Debian kernel and /proc/pal
Message-Id: <1123241814.30015.5.camel@uluru.grenoble.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I recently used an Itanium machine booted with a 2.6 Linux kernel.
The exact package is:
        kernel-image-2.6.11-1-mckinley-smp_2.6.11-6_ia64.deb

It does appear that this kernel is compiled without CONFIG_PALINFO
which means there is no /proc/pal/cpu* entries.

I don't quite understand what motivates this choice. There is no
sensitive kernel information in there, just processor information
such as cache size, tlb levels, firmware revision numbers. This
information is very useful, some applications make use of it,
such as pfmon for instance. I would hope this is an oversight
on the part of the package maintainer. It did not use to be 
like that.

Any idea as to what happened?

--
-Stephane

