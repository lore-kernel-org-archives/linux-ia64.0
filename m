From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 17 Jul 2008 05:38:37 +0000
Subject: Re: [PATCH 13/29] ia64/xen: add definitions necessary for xen	eventchannel.
Message-Id: <487EDADD.70804@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606623812-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606623812-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Akio Takebe wrote:
>> +enum ipi_vector {
>> +	XEN_RESCHEDULE_VECTOR,
>> +	XEN_IPI_VECTOR,
>> +	XEN_CMCP_VECTOR,
>> +	XEN_CPEP_VECTOR,
>> +
>> +	XEN_NR_IPIS,
>> +};
>> +
>>     
> Don't need empty line.
>   

It's preferred style.  XEN_NR_IPIS is the end sentinel, and nothing 
should be added after it.

    J
