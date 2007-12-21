From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Fri, 21 Dec 2007 07:07:06 +0000
Subject: Re: [kvm-devel] [1-5/17] Patch 1-10 of kvm/ia64 V2
Message-Id: <8FC843A018A012takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCB139D3@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCB139D3-wq7ZOvIWXbMAbVU2wMM1CrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>

Hi, Xiantao

I got reading kvm-ia64 started. :)
Which member is p2m table?

> [2/17] Add kvm-ia64.c to support kvm module on Itanium processors.
Some trivial comments.

+int kvm_arch_init(void *opaque)
+{
+	int r;
+	struct kvm_vmm_info *vmm_info = (struct kvm_vmm_info *)opaque;
+
+	if (kvm_vmm_info) {
+		printk(KERN_ERR "kvm: already loaded the other module!\n");
+		r = -EEXIST;
+		goto out;
+	}
+
+	r =  -ENOMEM;
extra white space.

+	kvm_vmm_info = kzalloc(sizeof(struct kvm_vmm_info), GFP_KERNEL);
+	if (!kvm_vmm_info)
+		goto out;
+
Can we get the message of shortage of memory by qemu?

+	if (!vti_cpu_has_kvm_support()) {
+		printk(KERN_ERR "kvm: no hardware support\n");
+		r = -EOPNOTSUPP;
+		goto out_free0;
+	}
+
We had better check vti support at the first.

+	kvm_hack_insert_tr();
+
+	if (kvm_alloc_vmm_area())
+		goto out_free0;
+
r = kvm_alloc_vmm_area() is better.

+	r = kvm_relocate_vmm(vmm_info, vmm_info->module);
+	if (r)
+		goto out_free1;
+
+	return 0;
+
+out_free1:
+	kvm_free_vmm_area();
+out_free0:
+	kfree(kvm_vmm_info);
+out:
+	return r;
+}
+
+void kvm_arch_exit(void)
+{
+	kvm_free_vmm_area();
+	kfree(kvm_vmm_info);
+	kvm_vmm_info = 0;
+}
kvm_vmm_info = (void *)0?

Best Regards,

Akio Takebe

