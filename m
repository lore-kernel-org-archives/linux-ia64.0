From: Gerald Pfeifer <gp@suse.de>
Date: Tue, 25 Jan 2005 23:58:37 +0000
Subject: Re: LKCD on 2.6 IA64 Linux Kernel
Message-Id: <Pine.LNX.4.61.0501260050240.26713@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <50C05B7AA7D6924FB5E384EF14BC647BCBBD63@inba1mx2.corp.emc.com>
In-Reply-To: <50C05B7AA7D6924FB5E384EF14BC647BCBBD63@inba1mx2.corp.emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sachithanantham_Saravanan@emc.com
Cc: linux-ia64@vger.kernel.org, yakker@sgi.com, yakker@turbolinux.com, yakker@alacritech.com, matt@aparity.com, linux-kernel@vger.kernel.org

On Tue, 25 Jan 2005 Sachithanantham_Saravanan@emc.com wrote:
> I tried using lkcd on a ia64 machine running on 2.6.5-7.111 SuSe Kernel for
> debugging.

I strongly recommend you switch to 2.6.5-7.139 (or later) which is the
SLES9 SP1 kernel as opposed to the SLES9 GA kernel.  The former has quite
some changes wrt. LKCD and SLES9 SP1 also comes with a updated lkcdutils.

Furthermore, this is probably more of an issue you may want to discuss 
with your contacts at SUSE/Novell rather than on the linux-ia64 list,
though if there's interest I'll be happy to post pointers to these kernel
and lkcdutils packages.

Gerald
