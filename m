From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 12 May 2004 11:43:59 +0000
Subject: RE: Who owns those locks ?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F013CCAF0@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A1F4BE.4A298352@nospam.org>
In-Reply-To: <40A1F4BE.4A298352@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>The first reason to use a shift of 12 bits is:
>you can see easily what the address of the owner's task structure is.
>In addition, with page size of 16 Kbytes, you've got only 16 Tbytes
>in the identity mapped kernel address space any way.
>Should we move to a page size of 64 Kbytes, you can use a shift of
>16 bits and you keep the address human readable ;-)

Human readable is nice.

The identity mapped kernel space is not limited by the pagesize.
Mappings in region 7[*] are provided by the Alt-dtlb miss handler,
which just inserts a kernel granule sized mapping into the TLB
to cover any TLB miss.

-Tony

[*] except for the percpu area in the top 64k of region 7 which is
mapped by a locked entry in a DTR register.
