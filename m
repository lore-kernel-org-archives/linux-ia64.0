From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 22 Mar 2005 02:03:45 +0000
Subject: Re: [PATCH] move cnodeid_to_nasid_table out of pda
Message-Id: <Pine.LNX.4.58.0503211802260.10426@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <423F2342.mailxGRL11RVD3@aqua.americas.sgi.com>
In-Reply-To: <423F2342.mailxGRL11RVD3@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Mar 2005, Dean Nelson wrote:

> Another step in the effort to eliminate the SN pda structure.
> This patch moves the cnodeid_to_nasid_table field out of the pda,
> making it a standalone per-cpu data item, and exports it so it can
> be accessed by kernel modules.

I have verified that Dean's patch also fixes the problem that the mmtimer
driver (clock driver for SN2 RTC) cannot be build as a module.
