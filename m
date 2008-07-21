From: Avi Kivity <avi@qumranet.com>
Date: Mon, 21 Jul 2008 08:12:27 +0000
Subject: Re: [PATCH 24/29] ia64/pv_ops/xen: implement xen pv_time_ops.
Message-Id: <488444EB.60708@qumranet.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606623288-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606623288-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jeremy Fitzhardinge wrote:
> Isaku Yamahata wrote:
>   
>> implement xen pv_time_ops to account steal time.
>>   
>>     
>
> I think you could just share arch/x86/xen/time.c, couldn't you?  I'd be 
> happy to accept a patch to move all the shareable bits into 
> drivers/xen/time.c.
>
>   
Or maybe, virt/xen/?


-- 
error compiling committee.c: too many arguments to function

