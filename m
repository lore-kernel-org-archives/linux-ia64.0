From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 21 Dec 2007 07:44:58 +0000
Subject: RE: [kvm-devel] [1-5/17] Patch 1-10 of kvm/ia64 V2
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCB13D6A@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCB139D3@pdsmsx415.ccr.corp.intel.com> <8FC843A018A012takebe_akio@jp.fujitsu.com>
In-Reply-To: <8FC843A018A012takebe_akio@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Avi Kivity <avi@qumranet.com>

Hi Akio,
	Thank you for your comments.
Xiantao
Akio Takebe wrote:
> Hi, Xiantao
m: already loaded the other module!\n");
> +		r = -EEXIST;
> +		goto out;
> +	}
> +
> +	r =  -ENOMEM;
> extra white space.

Yes.  One more white space here.

> +	kvm_vmm_info = kzalloc(sizeof(struct kvm_vmm_info), GFP_KERNEL);
> +	if (!kvm_vmm_info)
> +		goto out;
> +
> Can we get the message of shortage of memory by qemu?

The memory allocation here is just for vmm module initialization, and no
qemu/vm created so far. 
Memory shortage here, will leads to module insert fail, and this is our
expectable result.  

> +	if (!vti_cpu_has_kvm_support()) {
> +		printk(KERN_ERR "kvm: no hardware support\n");
> +		r = -EOPNOTSUPP;
> +		goto out_free0;
> +	}
> +
> We had better check vti support at the first.

OK,  I will move it to first in arch_init. :)

> +}
> kvm_vmm_info = (void *)0?

Maybe NULL is better :)

> 
>
------------------------------------------------------------------------
-
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> kvm-devel mailing list
> kvm-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/kvm-devel

