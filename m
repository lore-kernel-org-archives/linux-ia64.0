From: Bernhard Walle <bwalle@suse.de>
Date: Fri, 12 Sep 2008 07:55:48 +0000
Subject: Re: [PATCH]IA64: assign a distinguishable label to uncached memory
Message-Id: <20080912095548.54471a93@kepler.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <48C9A2F8.3060308@sgi.com>
In-Reply-To: <48C9A2F8.3060308@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jay Lan <jlan@sgi.com>
Cc: kexec@lists.infradead.org, Jack Steiner <steiner@sgi.com>, linux-ia64@vger.kernel.org

* Jay Lan <jlan@sgi.com> [2008-09-11]: 

> -				} else {
> -					name = "System RAM";
> -				}
> +				} else if (md->attribute = EFI_MEMORY_UC)
> +						name = "Uncached RAM";
> +					else
> +						name = "System RAM";
                                ^^^^^^^^

Isn't that too much indent, i.e. shouldn't that be

--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -1232,9 +1232,10 @@ efi_initialize_iomem_resources(struct re
                                if (md->attribute & EFI_MEMORY_WP) {
                                        name = "System ROM";
                                        flags |= IORESOURCE_READONLY;
-                               } else {
+                               } else if (md->attribute =
EFI_MEMORY_UC)
+                                       name = "Uncached RAM";
+                               else
                                        name = "System RAM";
-                               }
                                break;



Bernhard
