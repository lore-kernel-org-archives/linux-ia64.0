From: Bob Montgomery <bob.montgomery@hp.com>
Date: Wed, 16 Aug 2006 18:25:40 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <1155752740.26951.239.camel@amd.troyhebe>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-08-16 at 06:40 +0800, Zou Nan hai wrote:
> On Wed, 2006-08-16 at 01:39, Bob Montgomery wrote:
> > On Tue, 2006-08-15 at 08:47 +0800, Zou Nan hai wrote:

> 
>   If you are not seeing "I am in purgatory" in console, that probably
> means crash kernel segments and purgatory code was copied into some
> wrong physical address.
> 
>   Can you check the crashkernel="..." parameter
>   Thanks

Today, we have had success by changing the configuration of our kernels
from zx1 to tiger.  Now we'll try to figure out what it is about the zx1
config parameters that causes the crash_kexec path to break.

Bob Montgomery

