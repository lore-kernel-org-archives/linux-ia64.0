From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 17 Feb 2004 22:32:40 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <20040217223240.GA9909@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 17, 2004 at 08:53:59AM -0500, Robert Picco wrote:
> +++ linux-2.6.2/arch/ia64/kernel/acpi.c	2004-02-17 
> 06:10:20.000000000 -0500
> @@ -338,11 +338,16 @@
> #undef SLIT_DEBUG
> 
> #define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
> +#define	PXM_MAGIC	(255)

Is this a reserved value in the ACPI SLIT spec?  I don't have it handy,
so I can't check that this would be a magic Linux-only value.

Also, I can't be sure (since my .muttrc is known to be weird), but I
think the patch got wrapped somehow, and doesn't seem to conform
entirely to Documentation/CodingStyle...  Haven't really looked at it
other than that yet.

Jesse
