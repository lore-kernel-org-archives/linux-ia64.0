From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 29 Mar 2004 20:49:57 +0000
Subject: RE: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <200403292049.i2TKnvF11443@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Andy Whitcroft' <apw@shadowen.org>, "'Martin J. Bligh'" <mbligh@aracnet.com>, 'Ray Bryant' <raybry@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

>>>>>> Chen, Kenneth W wrote on Mon, March 29, 2004 12:46 PM
> overcomit is not checked for hugetlb mmap, is it intentional here?

Just to follow up myself, I meant overcommit accounting is not done
for mmap hugetlb page.  (typical Monday morning symptom :))

- Ken


