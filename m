From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 13 May 2004 15:32:51 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <1084462371.1417.20.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <012201c438f4$0cbb6580$39624c0f@india.hp.com>
In-Reply-To: <012201c438f4$0cbb6580$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>
Cc: 'Greg KH' <greg@kroah.com>, Matt_Domsch@dell.com, 'Matthew E Tolentino' <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, 'Linux Kernel Mailing List' <linux-kernel@vger.kernel.org>

On Thu, 2004-05-13 at 07:10, Sourav Sen wrote:
> + We're planning on doing this anyway for memory hotplug, so some of the
> + work and ideas are already there.  I'd be happy to point you to some
> + past discussions and code on the subject.  

Here was my sample implementation of how to export memory areas:

http://sourceforge.net/mailarchive/forum.php?thread_idA20609&forum_id"3

There was at least one other way to do the same thing on the lhms-devel
list.  I believe it was some time last month.

-- Dave

