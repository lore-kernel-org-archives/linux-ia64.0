From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Fri, 03 Sep 2004 22:02:17 +0000
Subject: Re: [PATCH resent] arch/ia64/sn: use seq_file in sn_proc_fs.c
Message-Id: <20040903150217.449bf2fe.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0409031150050.4971-100000@woolami.melbourne.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0409031150050.4971-100000@woolami.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 3 Sep 2004 12:05:49 +1000 (EST) Mark Goodwin wrote:

| 
| convert arch/ia64/sn/kernel/sn2/sn_proc_fs.c to use the seq_file API
| 
| Signed-off-by: Mark Goodwin <markgw@sgi.com>
| ---
| 
| --- 2.6.8-rc2/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Tue Aug 17 11:45:18 2004
| +++ 2.6.8-rc2-seq_file/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Wed Aug 18 07:22:24 2004

Hi-
This no longer applies cleanly to current tree (2.6.9-rc1 or -mm3).

Please use tabs instead of spaces...

Have you run any of this thru sparse?
It may be clean as is, but I thought that I saw a couple of
questionable items in it.

Thanks,
--
~Randy
