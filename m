From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 31 Mar 2004 08:51:45 +0000
Subject: RE: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <200403310851.i2V8pkF28306@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <27832908.1080701317@[192.168.0.89]>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Andy Whitcroft' <apw@shadowen.org>, "Martin J. Bligh" <mbligh@aracnet.com>, Ray Bryant <raybry@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

>>>> Andy Whitcroft wrote on Tuesday, March 30, 2004 5:49 PM
>>> 	fd = open("/mnt/htlb/myhtlbfile", O_CREAT|O_RDWR, 0755);
>>> 	mmap(..., fd, offset);
>>>
>>> Accounting didn't happen in this case, (grep Huge /proc/meminfo):
>
> O.k.  Try this one.  Should fix that case.  There is some uglyness in
> there which needs review, but my testing says this works.

Under common case, worked perfectly!  But there are always corner cases.

I can think of two ugliness:
1. very sparse hugetlb file.  I can mmap one hugetlb page, at offset
   512 GB.  This would account 512GB + 1 hugetlb page as committed_AS.
   But I only asked for one page mapping.  One can say it's a feature,
   but I think it's a bug.

2. There is no error checking (to undo the committed_AS accounting) after
   hugetlb_prefault(). hugetlb_prefault doesn't always succeed in allocat-
   ing all the pages user asked for due to disk quota limit.  It can have
   partial allocation which would put the committed_AS in a wedged state.

- Ken


