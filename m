From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 26 Jul 2004 04:46:53 +0000
Subject: Re: take2: [PATCH] Vector sharing (Large I/O system support)
Message-Id: <41048CBD.3050609@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE09B5.7020109@jp.fujitsu.com>
In-Reply-To: <40FE09B5.7020109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Kenji> This is the updated patch for vector sharing.  Summary of
>   Kenji> changes: - Changed the name of some data structures.  -
>   Kenji> Removed '__cacheline_aligned' from iosapic_intr_info
> 
> I'm mostly OK with the patch, but I don't like the list handling very
> much.  For example, maintaining a separate "count" field for the list
> just seems unnecessary and error-prone.  It would be nicer if you
> could restructure the code such that you can use list_empty() instead.

Thanks for comments.
I'll restructure the code and post it again.

Thanks,
Kenji Kaneshige


