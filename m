From: Avi Kivity <avi@qumranet.com>
Date: Fri, 21 Dec 2007 06:31:23 +0000
Subject: Re: [PATCH] Export three symbols for kvm use.
Message-Id: <476B5DBB.5010400@qumranet.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCB139E3@pdsmsx415.ccr.corp.intel.com> <20071220170324.GA29209@infradead.org>
In-Reply-To: <20071220170324.GA29209@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: "Zhang, Xiantao" <xiantao.zhang@intel.com>, "Luck, Tony" <tony.luck@intel.com>, kvm-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> On Thu, Dec 20, 2007 at 01:57:01PM +0800, Zhang, Xiantao wrote:
>   
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
>>     
>
> Please submit this together with the actual kvm code as we don't export
> symbols for out of tree usage, thanks.
>   

1. kvm is not out of tree
2. I can't submit unacked ia64 patches in kvm.git
3. Even when this is in kvm.git, it's good to have it in the ia64 tree
to avoid conflicts when it hits mainline

Thanks.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

