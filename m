From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 16 Aug 2005 20:44:50 +0000
Subject: RE: Multiple virtual address mapping for the same code on IA-64 linux kernel.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04294461@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x4tbon0.fsf@sykes.suse.de>
In-Reply-To: <je1x4tbon0.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: vamsi krishna <vamsi.krishnak@gmail.com>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org


>I have been investigating a problem in which there has been a dramatic
> core size (complete program size) of a program running on a IA-64
>machine running kernel version 2.4.21-4.0.1 (A redhat advanced server
>distribution) compared to other 64-bit architectures like amd64 and
>EM64T. There has been an increase of around 20% of the size.

Itanium instruction set is not as compact as some other architectures,
so the same program will typically require more bytes of code.

-Tony
