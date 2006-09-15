From: Don Zickus <dzickus@redhat.com>
Date: Fri, 15 Sep 2006 14:09:06 +0000
Subject: Re: [Fastboot] [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
Message-Id: <20060915140906.GD3512@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
In-Reply-To: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 15, 2006 at 10:55:49AM +0800, Zou Nan hai wrote:
> 
> Hi,
>    Here is a new version of IA64 Kexec/Kdump patch.
>    Update since last patch.
> 
>    1. Ignore offset in crashkernel=size@offset kernel parameter. kernel
> will find crashkernel region according to size at boot time. However
> crashkernel parameter format is not changed to keep compatibility with
> other archs

Just for conversation purposes:

Having offset determined at boot-time seems convienant and more scalable.
Is there a reason why we can't apply this to all archs?  Is it because we
lose some flexibility?

Cheers,
Don

