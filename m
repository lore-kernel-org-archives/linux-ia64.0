From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 14 May 2003 05:29:21 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705777@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

tony.luck@intel.com schrieb:

 > It will be possible to extend this patch to split text and data into
 > separate sections to allow kernel text replication, but I left that
 > out for now to keep this patch to the bare minimum.
 >

If you plan to separate text and data of the kernel be aware of tpa only 
translating data addresses and not instruction addresses. We would need 
a tpa.d and tpa.i. I am wondering about the lack of "tpa.i" in the 
itanium architecture design.

Christian


