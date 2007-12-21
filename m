From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 21 Dec 2007 02:11:43 +0000
Subject: RE: [PATCH] Export three symbols for kvm use.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCB13BF3@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCB139E3@pdsmsx415.ccr.corp.intel.com> <20071220170324.GA29209@infradead.org>
In-Reply-To: <20071220170324.GA29209@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> On Thu, Dec 20, 2007 at 01:57:01PM +0800, Zhang, Xiantao wrote:
>> Hi Tony,
>> 	In order to build kvm source successfully, we need to export
>> three symbols for kvm use. Please review. Maybe Avi can check-in to
>> kvm.git upstream first. 
>> 
>> Thanks
>> Xiantao
>> From: Zhang Xiantao <xiantao.zhang@intel.com>
>> Date: Thu, 20 Dec 2007 09:37:41 +0800
>> Subject: [PATCH] ia64: Export three symbols for module use
>> 
>> Since kvm/module needs to use some unexported functions in kernel,
>> so export them with this patch.
> 
> Please submit this together with the actual kvm code as we don't
> export symbols for out of tree usage, thanks.

Sure, I have submitted  them together with this patch to both mailing
lists. You know, this patch should go into kvm tree first, but need ia64
arch maintainer 's nod :)

Xiantao
