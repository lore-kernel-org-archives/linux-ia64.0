From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 07 Mar 2003 19:36:01 +0000
Subject: Re: [Discontig-devel] Re: [Linux-ia64] discontigmem patch for 2.4.20
Message-Id: <marc-linux-ia64-105590709806004@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805999@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805999@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> And about problems on HP machines, I guess the reason is that
> the current CONFIG_NUMA kernel doesn't work right on a system
> which needs the VIRTUAL_MEM_MAP function.

Ah, it looks like you enforce this in the 2.5 config files:

    config VIRTUAL_MEM_MAP
            bool "Enable Virtual Mem Map"
            depends on !NUMA

Unfortunately, 2.4 doesn't have VIRTUAL_MEM_MAP as a config
option (it's enabled automatically if needed), so we can't do
that directly.

> ... it would better if CONFIG_NUMA kernel works on all types
> of machines. So I'll try to find out a solution for this issue.

That would be ideal.  Seems like there ought to be opportunities
for unification of DISCONTIGMEM, VIRTUAL_MEM_MAP, and parts of
NUMA.  The current scheme feels a little clunky, especially for
configuring a "generic" kernel.  (It sounds like it isn't even
possible to configure a kernel generic enough for both SGI SNx
and HP zx1 boxes.)

Bjorn


