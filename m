From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 22:04:10 +0000
Subject: Re: [PATCH] - Delete duplicate SN2 definition of cpu_logical_id for non-SMP
Message-Id: <200501061404.10300.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106215324.GA22647@sgi.com>
In-Reply-To: <20050106215324.GA22647@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 6, 2005 1:53 pm, Jack Steiner wrote:
> Looks like this patch is needed to build non-SMP configurations.
>
> Delete duplicate / stale definition of cpu_logical_id for non-SMP
> configurations.

I think a lot more than that is needed to fix the UP build.  The patch Dann 
posted contains this hunk and several others (also move the physical_id macro 
out to a generic file).

Jesse
