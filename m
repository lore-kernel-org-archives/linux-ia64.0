From: "David Laight" <David.Laight@ACULAB.COM>
Date: Tue, 27 Aug 2013 09:20:50 +0000
Subject: RE: [PATCH 0/2] fs: supply inode uid/gid setting interface
Message-Id: <AE90C24D6B3A694183C094C60CF0A2F6026B7307@saturn3.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com> <20130823041010.GA12296@kroah.com> <5217100E.6080506@huawei.com>
In-Reply-To: <5217100E.6080506@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rui Xiang <rui.xiang@huawei.com>, Greg KH <gregkh@linuxfoundation.org>
Cc: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-rdma@vger.kernel.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, linuxppc-dev@lists.ozlabs.org

> Subject: Re: [PATCH 0/2] fs: supply inode uid/gid setting interface
> 
> On 2013/8/23 12:10, Greg KH wrote:
> > On Fri, Aug 23, 2013 at 10:48:36AM +0800, Rui Xiang wrote:
> >> This patchset implements an accessor functions to set uid/gid
> >> in inode struct. Just finish code clean up.
> >
> > Why?
> >
> It can introduce a new function to reduce some codes.
>  Just clean up.

In what sense is it a 'cleanup' ?

To my mind it just means that anyone reading the code has
to go and look at another file in order to see what the
function does (it might be expected to be more complex).

It also adds run time cost, while probably not directly
measurable I suspect it more than doubles the execution
time of that code fragment - do that everywhere and the
system will run like a sick pig.

The only real use for accessor functions is when you
don't want the structure offset to be public.
In this case that is obviously not the case since
all the drivers are directly accessing other members
of the structure.

	David



