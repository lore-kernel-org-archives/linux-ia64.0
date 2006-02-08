From: Kyle McMartin <kyle@mcmartin.ca>
Date: Wed, 08 Feb 2006 23:59:44 +0000
Subject: Re: [PATCH] registration for new system call unshare
Message-Id: <20060208235944.GB28312@quicksilver.road.mcmartin.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <1139440466.2535.2.camel@hobbes.atlanta.ibm.com>
In-Reply-To: <1139440466.2535.2.camel@hobbes.atlanta.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 08, 2006 at 06:14:41PM -0500, JANAK DESAI wrote:
> [PATCH] unshare system call: system call registration for ia64

> +#define __NR_ni_syscall			1294
> +#define __NR_ni_syscall			1295
>

These should be __NR_sys_pselect and __NR_sys_ppoll otherwise you will
get warnings...
