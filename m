From: Horms <horms@verge.net.au>
Date: Wed, 13 Dec 2006 02:00:40 +0000
Subject: Re: [patch 3/5] Dont map PAL memory if physicall calls are going to be made
Message-Id: <20061213020039.GC22902@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061023090334.467483535@tabatha.lab.ultramonkey.org>
In-Reply-To: <20061023090334.467483535@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 24, 2006 at 02:47:38PM -0500, Jack Steiner wrote:
> On Mon, Oct 23, 2006 at 05:48:43PM +0900, Horms wrote:
> > There seems to be no reason to map the PAL code into memory if
> > physical calls are going to be made.
> 
> 
> If you don't map PAL, I assume that all PAL calls are going to be made in
> physical addressing mode. However, I don't see any code that actually forces
> PAL calls to be made in physical addressing mode. Is that your intent? 
> Don't you also need to save the PAL start address as a physical address.
> See the call to ia64_pal_handler_init().

Thanks. On furtuther investigation I think that this patch is bogus.
I will remove it from the series.

> In addition, it looks like slave cpus still call efi_map_pal_code()
> to map PAL - see start_secondary().

Just for the record, that itself is easy enough to get around by
checking for efi.mapped in efi_map_pal_code() or start_secondary().

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

