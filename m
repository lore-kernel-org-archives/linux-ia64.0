From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 10 Feb 2004 21:58:09 +0000
Subject: Re: [PATCH] Add EXPORT_SYMBOL for physical_node_map
Message-Id: <20040210215809.GA864@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040203185728.GX13322@localhost>
In-Reply-To: <20040203185728.GX13322@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 10, 2004 at 01:51:43PM -0800, David Mosberger wrote:
> >>>>> On Tue, 3 Feb 2004 13:57:28 -0500, Martin Hicks <mort@wildopensource.com> said:
> 
>   Martin> Can you please include this EXPORT_SYMBOL in the next release.  A few
>   Martin> macros that use physical_node_map are used in modules.
> 
> I share Christoph's concern but since this code is SGI's and Jesse is
> apparently OK with it, I'd have applied it---if only the patch
> actually applied.  I think there is some whitespace breakage in your
> patch.

Yep, I'm ok with it.  The modules that depend on it should be released
under the GPL soon.  Robin is working on getting them into shape for
inclusion into the mainline tree.

Thanks,
Jesse
