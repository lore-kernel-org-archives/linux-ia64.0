From: Dean Nelson <dcn@sgi.com>
Date: Tue, 22 Jun 2004 18:17:07 +0000
Subject: Re: [PATCH 3/4] SGI Altix cross partition functionality
Message-Id: <20040622181707.GA26313@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040617183638.GA3712@sgi.com>
In-Reply-To: <20040617183638.GA3712@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 17, 2004 at 08:22:29PM +0100, Christoph Hellwig wrote:
> 
> +} xpc_vars_t;
> 
> please kill all the typedef gunk.

I'm in the process of ditching all of my typedef's. But before I axed the
following two I thought I'd ask if an exception should be made in their
case? Or are all typedef's deemed offlimits without exception?

	typedef void (*xpc_channel_func_t)(enum xpc_retval, partid_t, int,
						void *, void *);

	typedef void (*xpc_notify_func_t)(enum xpc_retval, partid_t, int,
						void *);

(Note: I had nothing to do with the partid_t typedef.)

Thanks,
Dean

