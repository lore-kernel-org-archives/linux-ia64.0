From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 22 Sep 2004 01:44:17 +0000
Subject: Re: [PATCH] ia32 support for NX when sigaction->sa_restorer == NULL
Message-Id: <4150D8F1.3040008@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4141D3B2.2030106@intel.com>
In-Reply-To: <4141D3B2.2030106@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/21/2004 2:56 PM, Andreas Schwab wrote:
> Arun Sharma <arun.sharma@intel.com> writes:
> 
>> When userland doesn't specify sigaction->sa_restorer, we try to put
>> the restorer code on the stack. But this breaks ia32 binaries with
>> non-executable stacks. We now put the restorer code on a gate page.
> 
> Does this work with nested signal handlers?

I don't see why not. The gate page is read-only.

	-Arun
