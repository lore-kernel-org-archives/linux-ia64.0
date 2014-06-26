From: Sudeep Holla <sudeep.holla@arm.com>
Date: Thu, 26 Jun 2014 18:41:32 +0000
Subject: Re: [PATCH 2/9] drivers: base: support cpu cache information interface to userspace via sysfs
Message-Id: <53AC695C.2090406@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1403717444-23559-1-git-send-email-sudeep.holla@arm.com> <1403717444-23559-3-git-send-email-sudeep.holla@arm.com> <20140625222355.GK32514@n2100.arm.linux.org.uk>
In-Reply-To: <20140625222355.GK32514@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Sudeep Holla <sudeep.holla@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rob Herring <robh@kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "x86@kernel.org" <x86@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux390@de.ibm.com" <linux390@de.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi,

On 25/06/14 23:23, Russell King - ARM Linux wrote:
> On Wed, Jun 25, 2014 at 06:30:37PM +0100, Sudeep Holla wrote:
>> +		coherency_line_size: the minimum amount of data that gets transferred
>
> So, what value to do envision this taking for a CPU where the cache
> line size is 32 bytes, but each cache line has two dirty bits which
> allow it to only evict either the upper or lower 16 bytes depending
> on which are dirty?
>

IIUC most of existing implementations of cacheinfo on various architectures
are representing the cache line size as coherency_line_size, in which case I
need fix the definition in this file.

BTW will there be any architectural way of finding such configuration ?

Regards,
Sudeep

