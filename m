From: Joel Schopp <jschopp@austin.ibm.com>
Date: Fri, 10 Feb 2006 21:59:17 +0000
Subject: Re: [Lhms-devel] [RFC/PATCH: 002/010] Memory hotplug for new nodes
Message-Id: <43ED0CB5.2060104@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060210223841.C532.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060210223841.C532.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

> +	/* When hot-dadd, present page is 0 at this point.
> +	   So check spanned_pages instead of present_pages */
> +	return (!!zone->spanned_pages);
>  }

Typo in comment.
