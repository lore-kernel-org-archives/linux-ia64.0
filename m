From: Jes Sorensen <jes@sgi.com>
Date: Mon, 31 Mar 2008 11:41:45 +0000
Subject: Re: [03/15][PATCH] kvm/ia64: Add header files for kvm/ia64. V8
Message-Id: <47F0CDF9.3040202@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048243@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01048243@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org, Carsten Otte <cotte@de.ibm.com>

Hi Xiantao,

Some more nit-picking, though some of this is a bit more important
to fixup.

Cheers,
Jes


> +typedef struct thash_data {

Urgh! argh! Please avoid typedefs unless you really need them, see
Chapter 5 of Documentation/CodingStyle for details.

> diff --git a/include/asm-ia64/kvm_host.h b/include/asm-ia64/kvm_host.h
> new file mode 100644
> index 0000000..522bde0
> --- /dev/null
> +++ b/include/asm-ia64/kvm_host.h
> @@ -0,0 +1,530 @@
> +/* -*-  Mode:C; c-basic-offset:4; tab-width:4; indent-tabs-mode:nil -*-
> */

The standard indentation for Linux is 8 characters using tabs. If
possible it's preferred to comply with that to make the entire kernel
tree easier for everybody to deal with. See CodingStyle for details.

> +struct kvm_mmio_req {
> +	uint64_t addr;          /*  physical address		*/
> +	uint64_t size;          /*  size in bytes		*/
> +	uint64_t data;          /*  data (or paddr of data)     */
> +	uint8_t state:4;
> +	uint8_t dir:1;          /*  1=read, 0=write             */
> +};
> +typedef struct kvm_mmio_req mmio_req_t;

More typedefs

> +/*Pal data struct */
> +typedef struct pal_call{

and again.

> +	/*In area*/
> +	uint64_t gr28;
> +	uint64_t gr29;
> +	uint64_t gr30;
> +	uint64_t gr31;
> +	/*Out area*/
> +	struct ia64_pal_retval ret;
> +} pal_call_t;
> +
> +/* Sal data structure */
> +typedef struct sal_call{
and again...

> +	/*In area*/
> +	uint64_t in0;
> +	uint64_t in1;
> +	uint64_t in2;
> +	uint64_t in3;
> +	uint64_t in4;
> +	uint64_t in5;
> +	uint64_t in6;
> +	uint64_t in7;
> +	/*Our area*/
> +	struct sal_ret_values ret;
> +} sal_call_t;
