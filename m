From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 20 Oct 2003 15:35:45 +0000
Subject: Re: [PATCH] fix topology init take 2
Message-Id: <marc-linux-ia64-106666451508513@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641524132220@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641524132220@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 20, 2003 at 05:17:29PM +0200, Xavier Bru wrote:
> 
> Jesse Barnes writes:
>  > Populate topology directories correctly now that NUMA kernels work.
>  > 
>  > Jesse
>  > 
> 
> Jesse,
> 
> Thanks for the patch. Just one question about it:
> 
> Are there relevant informations that can be used apart from:
>     node*/meminfo
>     node*/cpumap
> 
> We find some node*/memblk* and cpu/cpu* that are empty directories.
> 
> Should they sometimes provide some informations like LID (for cpu*) or 
> physical block addr & length (for memblk) ? I suppose this is part of
> the discussion on libnuma & hwgfs ?

Those seem like reasonable things to export in those directories, is
there anything else that would be nice to have?

Jesse
