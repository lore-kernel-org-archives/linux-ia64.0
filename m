From: Andy Whitcroft <apw@shadowen.org>
Date: Tue, 30 Mar 2004 21:48:02 +0000
Subject: RE: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <13395305.1080686882@[192.168.0.89]>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403302004.i2UK4JF23059@unix-os.sc.intel.com>
In-Reply-To: <200403302004.i2UK4JF23059@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Ray Bryant <raybry@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

--On 30 March 2004 12:04 -0800 "Chen, Kenneth W" <kenneth.w.chen@intel.com> 
wrote:

> I can do:
> 	fd = open("/mnt/htlb/myhtlbfile", O_CREAT|O_RDWR, 0755);
> 	mmap(..., fd, offset);
>
> Accounting didn't happen in this case, (grep Huge /proc/meminfo):
>
> HugePages_Total:    10
> HugePages_Free:      9
> Hugepagesize:    262144 kB
> HugeCommitted_AS:     0 kB

Oooops.  Now I get you.  Thanks for pointing that out.  More work required.

-apw
