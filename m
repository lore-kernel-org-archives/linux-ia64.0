From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 12 Nov 2003 19:17:32 +0000
Subject: Re: Odd IA32 mmap calls - Is this fixed
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010806070107060600020600"
Message-Id: <marc-linux-ia64-106866491021469@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106862063402317@msgid-missing>
In-Reply-To: <marc-linux-ia64-106862063402317@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010806070107060600020600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


There is no "safe" solution that I know of. The attached patch will fix this particular problem, but might create new ones. Try it at your own risk.

	-Arun

On 11/11/2003 11:03 PM, Shiju A Mathew wrote:
> Hi,
> The mummap is failing to unmap the pages allocated by
> mmap when a ia32 application ( 4k Pagesize) is run on
> ia64 system( 16k pagesize). This happens when the
> offset  in mmap does not fall on 16k boundary. The
> problem seems to be similar to the problem " Odd IA32
> mmap calls" (Calls to mmap/munmap where the length is
> a fraction of the page size cause a memory leak,
> eventually running out of VM for the IA32 process)
> listed in the ToDo list of ia64 homepage.I am doing
> the test on sles-8 running 2.4.19 kernel. Is this
> problem fixed in the 2.6 test kernel ? If it is not
> fixed are there anyone working on it to fix the
> problem?

--------------010806070107060600020600
Content-Type: text/plain;
 name="ia32_munmap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia32_munmap.patch"

--- linux-2.4.9/arch/ia64/ia32/sys_ia32.c	Tue Feb  5 22:08:20 2002
+++ linux-nk/arch/ia64/ia32/sys_ia32.c	Tue Feb  5 22:18:24 2002
@@ -549,8 +559,8 @@
 	if (start > end)
 		return -EINVAL;
 
-	start = PAGE_ALIGN(start);
-	end = PAGE_START(end);
+	start = PAGE_START(start);
+	end = PAGE_ALIGN(end);
 
 	if (start >= end)
 		return 0;

--------------010806070107060600020600--

