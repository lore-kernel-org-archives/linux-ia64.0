From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 22 Mar 2005 19:59:48 +0000
Subject: RE: [PATCH 2.6.11] AIO panic on PPC64 caused byis_hugepage_only_range()
Message-Id: <200503221959.j2MJxmg17815@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <1111519474.15956.40.camel@ibm-c.pdx.osdl.net>
References: <1111519474.15956.40.camel@ibm-c.pdx.osdl.net>
In-Reply-To: <1111519474.15956.40.camel@ibm-c.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Daniel McNeil' <daniel@osdl.org>, Andrew Morton <akpm@osdl.org>
Cc: linuxppc64-dev@ozlabs.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-ia64@vger.kernel.org

On Mon, 2005-03-21 at 18:41, Andrew Morton wrote:
> Did we fix this yet?
>

Daniel McNeil wrote on Tuesday, March 22, 2005 11:25 AM
> Here's a patch against 2.6.11 that fixes the problem.
> It changes is_hugepage_only_range() to take mm as an argument
> and then changes the places that call it to pass 'mm'.
> It includes a change for ia64 which has not been compiled.


Just a sanity check, tested the patch on ia64. Nothing blows up
and everything is working.


