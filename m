From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 18 May 2005 16:52:59 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver
Message-Id: <428B72EB.6080601@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greg KH wrote:
> On Wed, May 18, 2005 at 09:57:13AM -0400, Prarit Bhargava wrote:

> 
> DDDD:BB:SS should be unique on it's own, right?

Greg,

I'm looking at the latest 2.6.12-rc4 sources and the IBM php code but don't see 
any references to additional sysfs files.  Some of the other drivers do 
implement extra sysfs files.  Can you give me a pointer to (as you said) a sane 
implementation?

Thanks,

P.
