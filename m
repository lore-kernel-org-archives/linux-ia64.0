From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Mar 2004 18:52:49 +0000
Subject: RE: Abnormal behaviour towards "INIT" interrupt management
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6FE5D586@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40691B80.9070309@Ext.Bull.Net>
In-Reply-To: <40691B80.9070309@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> What I've noticed using traces (and further an ITP tool) is that for 
>> each processor the "ia64_monarch_init_handler" is ever called. :-(
>
>Are you saying that more than one processor calls
>ia64_monarch_init_handler()?  If so, I think something
>is broken.

Or are you saying that NO processor gets to ia64_monarch_init_handler?

Just a sanity check ... when you set the ITP breakpoint to catch
the entry ... you did set it at the *physical* address of this function?

-Tony
