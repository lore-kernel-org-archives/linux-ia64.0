From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 29 Mar 2004 20:45:49 +0000
Subject: RE: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <200403292045.i2TKjnF11402@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <11580712.1080567019@42.150.104.212.access.eclipse.net.uk>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Andy Whitcroft' <apw@shadowen.org>, "Martin J. Bligh" <mbligh@aracnet.com>, Ray Bryant <raybry@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

>>>> Andy Whitcroft wrote on Mon, March 29, 2004 4:30 AM
> Indeed.  The previous patches I submitted only address #1.  Attached is
> another patch which should address #2, it supplies hugetlb commit
> accounting.  This is checked and applied when the segment is created.  It
> also supplements the meminfo information to display this new commitment.
> The patch only implments strict commitment, but as has been stated here
> often, it is not clear that overcommit of unswappable memory makes any
> sense in the absence of demand allocation.  When that is implemented then
> this will likely need a policy.
>
> Patch applies on top of my previous patch and has been tested on i386.


+int hugetlbfs_report_meminfo(char *buf)
+{
+	long htlb = atomic_read(&hugetlb_committed_space);
+	return sprintf(buf, "HugeCommited_AS: %5lu\n", htlb);
+}

"HugeCommited_AS", typo?? Should that be double "t"?  Also can we print
in terms of kB instead of num pages to match all other entries? Something
Like: htlb<<(PAGE_SHIFT-10)?

overcomit is not checked for hugetlb mmap, is it intentional here?

- Ken


