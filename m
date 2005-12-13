From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 13 Dec 2005 15:43:51 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <439EEC37.3020205@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> 
> CONFIG_PPC_MULTIPLATFORM is just a meta config that enables you to
> configure for multiple platforms.  In this way it is perfectly comparable
> to CONFIG_IA64_GENERIC.  The only difference is that CONFIG_IA64_GENERIC
> enables _all_ platforms with one option, whereas CONFIG_PPC_MULTIPLATFORM
> still lets you chose which one of the platforms to support at all, but you
> can chose to support more than one in a single kernel.

Oh .. thanks :)

P.

> 
> Andreas.
> 

