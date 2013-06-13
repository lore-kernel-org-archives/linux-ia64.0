From: Chen Gang <gang.chen@asianux.com>
Date: Thu, 13 Jun 2013 02:30:33 +0000
Subject: Re: [Suggestion] arch/*/include/asm/bitops.h: about __set_bit() API.
Message-Id: <51B92EC9.3050003@asianux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51B30285.6020503@asianux.com>
In-Reply-To: <51B30285.6020503@asianux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, "dhowells@redhat.com" <dhowells@redhat.com>, tony.luck@intel.com, fenghua.yu@intel.com, yasutake.koichi@jp.panasonic.com
Cc: linux-alpha@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-am33-list@redhat.com, Linux-Arch <linux-arch@vger.kernel.org>

On 06/08/2013 06:08 PM, Chen Gang wrote:
> Several architectures have different __set_bit() API to others, in
> standard API, 2nd param of __set_bit() is 'unsigned long *', but:
> 
>   in 'min10300', it is 'unsigned char *',

Oh, it is my fault, for 'mn10300' it is no issue, it is not 'unsigned
char *' (it is a generic one which can match any type).

Also 'min10300' --> 'mn10300'.



Thanks.
-- 
Chen Gang

Asianux Corporation
