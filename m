From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 06 Aug 2004 21:06:03 +0000
Subject: RE: Hugetlb demanding paging for -mm tree
Message-Id: <200408062106.i76L63Y08492@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040805140455.GE16763@wotan.suse.de>
References: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
In-Reply-To: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Andi Kleen' <ak@suse.de>
Cc: 'William Lee Irwin III' <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Seth, Rohit" <rohit.seth@intel.com>

Andi Kleen wrote on Thursday, August 05, 2004 7:05 AM
> On Thu, Aug 05, 2004 at 06:42:15AM -0700, Chen, Kenneth W wrote:
> > +int hugetlb_acct_memory(long delta)
> > +{
> > +	atomic_add(delta, &hugetlbzone_resv);
> > +	if (delta > 0 && atomic_read(&hugetlbzone_resv) >
> > +			VMACCTPG(hugetlb_total_pages())) {
> > +		atomic_add(-delta, &hugetlbzone_resv);
> > +		return -ENOMEM;
> > +	}
> > +	return 0;
>
> Wouldn't this be safer with a bit of locking?
> Even if the current code works lockless it would be more safer
> for long term mainteance.

Patch at the end of the mail.  Is it better?


> > +}
> > +
> > +struct file_region {
> > +	struct list_head link;
> > +	int from;
> > +	int to;
>
> Shouldn't these be long instead of int?

Yes, it should be long.  Thank you.

>
> I remember writing very similar, but simpler code for NUMA API
> regions. The PAT patches also have similar code.
> It's also tricky to get right.
>
> Maybe it would be time to move variable length region list handling
> into a nice library in lib/, so that it can be used by other users.

Let me roll that up in the next couple of days along with the above struct
type change. For now I guess we can let it sit in hugetlbfs for a few days.


diff -Nurp linux-2.6.7/fs/hugetlbfs/inode.c linux-2.6.7.hugetlb/fs/hugetlbfs/inode.c
--- linux-2.6.7/fs/hugetlbfs/inode.c	2004-08-06 11:45:04.000000000 -0700
+++ linux-2.6.7.hugetlb/fs/hugetlbfs/inode.c	2004-08-06 13:46:11.000000000 -0700
@@ -36,17 +36,21 @@
 #define VMACCT(x) ((x) >> (HPAGE_SHIFT))
 #define VMACCTPG(x) ((x) >> (HPAGE_SHIFT - PAGE_SHIFT))

-atomic_t hugetlbzone_resv = ATOMIC_INIT(0);
+static long hugetlbzone_resv;
+static spinlock_t hugetlbfs_lock = SPIN_LOCK_UNLOCKED;

 int hugetlb_acct_memory(long delta)
 {
-	atomic_add(delta, &hugetlbzone_resv);
-	if (delta > 0 && atomic_read(&hugetlbzone_resv) >
-			VMACCTPG(hugetlb_total_pages())) {
-		atomic_add(-delta, &hugetlbzone_resv);
-		return -ENOMEM;
-	}
-	return 0;
+	int ret = 0;
+
+	spin_lock(&hugetlbfs_lock);
+	if (delta > 0 && (hugetlbzone_resv + delta) >
+			VMACCTPG(hugetlb_total_pages()))
+		ret = -ENOMEM;
+	else
+		hugetlbzone_resv += delta;
+	spin_unlock(&hugetlbfs_lock);
+	return ret;
 }

 struct file_region {
@@ -225,8 +229,7 @@ static void hugetlb_acct_release(struct

 int hugetlbfs_report_meminfo(char *buf)
 {
-	long htlb = atomic_read(&hugetlbzone_resv);
-	return sprintf(buf, "HugePages_Reserved: %5lu\n", htlb);
+	return sprintf(buf, "HugePages_Reserved: %5lu\n", hugetlbzone_resv);
 }

 static struct super_operations hugetlbfs_ops;


