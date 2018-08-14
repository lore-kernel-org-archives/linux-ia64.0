From: Joe Perches <golf@perches.com>
Date: Tue, 14 Aug 2018 04:49:36 +0000
Subject: Re: [PATCH 2/2] powerpc: Use ARRAY_SIZE to replace its implementation
Message-Id: <c998658f11cd202fffa4b96b97af196049d78ec0.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1534214814-9043-1-git-send-email-zhongjiang@huawei.com>
         <1534214814-9043-3-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1534214814-9043-3-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: zhong jiang <zhongjiang@huawei.com>, tony.luck@intel.com, fenghua.yu@intel.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, oleg@redhat.com, rppt@linux.vnet.ibm.com, dhowells@redhat.com, akpm@linux-foundation.org, viro@zeniv.linux.org.uk
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, 2018-08-14 at 10:46 +0800, zhong jiang wrote:
> Use ARRAY_SIZE instead of dividing sizeof array with sizeof an element.
> So just replace it.

Better to remove the extern and the const altogether here as well.

$ git grep -w powerpc_num_opcodes
arch/powerpc/xmon/ppc-dis.c:  opcode_end = powerpc_opcodes + powerpc_num_opcodes;
arch/powerpc/xmon/ppc-opc.c:const int powerpc_num_opcodes arch/powerpc/xmon/ppc.h:extern const int powerpc_num_opcodes;

And this one could be removed instead:

$ git grep -w vle_num_opcodes
arch/powerpc/xmon/ppc-opc.c:const int vle_num_opcodes arch/powerpc/xmon/ppc.h:extern const int vle_num_opcodes;

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  arch/powerpc/xmon/ppc-opc.c | 12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/powerpc/xmon/ppc-opc.c b/arch/powerpc/xmon/ppc-opc.c
> index ac2b55b..f3f57a1 100644
> --- a/arch/powerpc/xmon/ppc-opc.c
> +++ b/arch/powerpc/xmon/ppc-opc.c
> @@ -966,8 +966,7 @@
>    { 0xff, 11, NULL, NULL, PPC_OPERAND_SIGNOPT },
>  };
>  
> -const unsigned int num_powerpc_operands = (sizeof (powerpc_operands)
> -					   / sizeof (powerpc_operands[0]));
> +const unsigned int num_powerpc_operands = ARRAY_SIZE(powerpc_operands);
>  
>  /* The functions used to insert and extract complicated operands.  */
>  
> @@ -6980,8 +6979,7 @@
>  {"fcfidu.",	XRC(63,974,1),	XRA_MASK, POWER7|PPCA2,	PPCVLE,		{FRT, FRB}},
>  };
>  
> -const int powerpc_num_opcodes > -  sizeof (powerpc_opcodes) / sizeof (powerpc_opcodes[0]);
> +const int powerpc_num_opcodes = ARRAY_SIZE(powerpc_opcodes);
>  
>  /* The VLE opcode table.
>  
> @@ -7219,8 +7217,7 @@
>  {"se_bl",	BD8(58,0,1),	BD8_MASK,	PPCVLE,	0,		{B8}},
>  };
>  
> -const int vle_num_opcodes > -  sizeof (vle_opcodes) / sizeof (vle_opcodes[0]);
> +const int vle_num_opcodes = ARRAY_SIZE(vle_opcodes);
>  
>  /* The macro table.  This is only used by the assembler.  */
>  
> @@ -7288,5 +7285,4 @@
>  {"e_clrlslwi",4, PPCVLE, "e_rlwinm %0,%1,%3,(%2)-(%3),31-(%3)"},
>  };
>  
> -const int powerpc_num_macros > -  sizeof (powerpc_macros) / sizeof (powerpc_macros[0]);
> +const int powerpc_num_macros = ARRAY_SIZE(powerpc_macros);
