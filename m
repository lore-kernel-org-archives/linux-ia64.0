From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 23 Jan 2003 17:14:09 +0000
Subject: Re: [Linux-ia64] Epca patches
Message-Id: <marc-linux-ia64-105590709805743@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805740@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805740@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The first, epca-1.50-1.diff.gz, is against the Digiboard software package
>   It contains modifications for both driver and supporting tools,
>   mainly the digiDload command.

I don't know who maintains the Digiboard software package, but this
patch doesn't look ia64-related.  This list is primarily for ia64 kernel
issues.

> The second, epca-1.50-1_ia-64_2.4.19.diff.gz, is against 2.4.19 kernel tree

This patch is not ia64-specific in the sense that it doesn't touch
anything under arch/ia64 or include/asm-ia64.  It does have a
number of IA64 ifdefs, but they don't appear to be real dependencies
on ia64-only features, so I think this should be sent to the Digi
epca driver maintainer.  Here's the entry from the MAINTAINERS file:

    DIGI INTL. EPCA DRIVER
    P:      Chad Schwartz
    M:      support@dgii.com
    M:      chads@dgii.com
    L:      digilnux@dgii.com
    S:      Maintained

Actually, Chad would probably be a good place to send the Digiboard
patch, too.

Bjorn

