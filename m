From: Al Viro <viro@ftp.linux.org.uk>
Date: Mon, 27 Aug 2007 16:13:28 +0000
Subject: Re: [PATCH 1/4] export __put_task_struct for XPMEM
Message-Id: <20070827161327.GG21089@ftp.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827155622.GA25589@sgi.com> <20070827155933.GB25589@sgi.com>
In-Reply-To: <20070827155933.GB25589@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com

On Mon, Aug 27, 2007 at 10:59:33AM -0500, Dean Nelson wrote:
> This patch exports __put_task_struct as it is needed by XPMEM.
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>
> 
> ---
> 
> One struct file_operations registered by XPMEM, xpmem_open(), calls
> 'get_task_struct(current->group_leader)' and another, xpmem_flush(), calls
> 'put_task_struct(tg->group_leader)'.

Does it?  Well, then open the file in question and start doing close(dup(fd))
in a loop.  Won't take long for an oops...
