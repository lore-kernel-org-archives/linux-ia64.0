From: "DESAI,RAJESH (HP-Cupertino,ex1)" <rajesh-n.desai@hp.com>
Date: Fri, 23 May 2003 18:37:00 +0000
Subject: RE: [Linux-ia64] [PATCH] 2.5 - Another user stack size patch
Message-Id: <marc-linux-ia64-105590723706009@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706006@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706006@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Any idea - what kind of apps? 

-R
--
On Fri, May 23, 2003 at 02:22:56PM -0400, DESAI,RAJESH (HP-Cupertino,ex1)
wrote:
> So, what kind of apps need 1 TB stacks?

People from within SGI are claiming that some of their apps require 2GB
of stack per processor, so even with existing systems we're looking at
128GB of stack space.  I imagine that the high-end SSI NUMA clusters
will get even bigger in the next while.  The 1TB number was just a nice
round number.

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com

