From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 08 Sep 2004 17:25:06 +0000
Subject: Re: [PATCH resent] arch/ia64/sn: use seq_file in sn_proc_fs.c
Message-Id: <20040908102506.331abb02.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0409031150050.4971-100000@woolami.melbourne.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0409031150050.4971-100000@woolami.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 6 Sep 2004 14:48:44 +1000 (EST) Mark Goodwin wrote:

| On Fri, 3 Sep 2004, Randy.Dunlap wrote:
| 
| > On Fri, 3 Sep 2004 12:05:49 +1000 (EST) Mark Goodwin wrote:
| > | ---
| > | 
| > | --- 2.6.8-rc2/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Tue Aug 17 11:45:18 2004
| > | +++ 2.6.8-rc2-seq_file/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Wed Aug 18 07:22:24 2004
| > 
| > Hi-
| > This no longer applies cleanly to current tree (2.6.9-rc1 or -mm3).
| 
| ok, I've redone the patch against 2.6.9-rc1 (actually top-of-tree bk),
| see below.
| 
| > Please use tabs instead of spaces...
| 
| ok
| 
| > Have you run any of this thru sparse?
| 
| No I hadn't, but have now. Using sparse from 
| http://www.codemonkey.org.uk/projects/bitkeeper/sparse/sparse-2004-09-05.tar.gz
| 
| It complains about all sorts of stuff in headers I'm including, but
| apparently no complaints in sn_proc_fs.c itself.
| 
| > It may be clean as is, but I thought that I saw a couple of
| > questionable items in it.
| > 
| Thanks for the review .. which items were questionable? Here's the revised
| patch for your consideration.

I don't recall, but I would trust sparse more than my eyes,
so don't worry about them.  I don't see any questionable bits now.

Thanks for the update.

--
~Randy
