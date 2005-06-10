From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 10 Jun 2005 10:31:14 +0000
Subject: Re: [PATCH 03/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42A96BF2.7070203@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com> <42A83B6D.8010703@jp.fujitsu.com> <20050609165719.GC9597@kroah.com>
In-Reply-To: <20050609165719.GC9597@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Greg KH wrote:
>> /* definition of ia64 iocookie */
>>-typedef unsigned long iocookie;
>>+struct __iocookie {
>>+	struct list_head	list;
>>+	struct pci_dev		*dev;	/* targeting device */
>>+	unsigned long		error;	/* error flag */
>>+};
>>+typedef struct __iocookie iocookie;
> 
> Hm, why not just make the thing be a "struct iocookie" in the first
> place, then we don't have to mess with a typedef at all.  And then each
> arch can define how the structure will look like in their private .c
> files, ensuring that no user can ever try to touch the structure
> themselves.

Aha.., maybe I understand it just now.
I don't know why, but I just stuck to typedef...

Thanks,
H.Seto

