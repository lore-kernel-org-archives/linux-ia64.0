From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Fri, 21 Dec 2007 07:44:16 +0000
Subject: Re: [kvm-devel] [1-5/17] Patch 1-10 of kvm/ia64 V2
Message-Id: <92C843A5499377takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCB139D3@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCB139D3-wq7ZOvIWXbMAbVU2wMM1CrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>

Hi, Xiantao

>> [3/17] Add firmware virtualization support.

+void kvm_sal_emul(struct kvm_vcpu *vcpu)
+{
+
+	struct sal_ret_values result;
+	u64 index, in1, in2, in3, in4, in5, in6, in7;
+
+	kvm_get_sal_call_data(vcpu, &index, &in1, &in2,
+			&in3, &in4, &in5, &in6, &in7);
+	if (index) {
+		result = sal_emulator(index, in1, in2, in3,
+						in4, in5, in6, in7);
+		set_sal_result(vcpu, result);
+	} else
+		printk(KERN_WARNING"kvm:Unsupported sal call called,"
+					" index:%d!\n", index);
+}
The printk always show index:0.
And set_sal_result() doesn't work at the time of index=0.
So I think the following code is better.

+void kvm_sal_emul(struct kvm_vcpu *vcpu)
+{
+
+	struct sal_ret_values result;
+	u64 index, in1, in2, in3, in4, in5, in6, in7;
+
+	kvm_get_sal_call_data(vcpu, &index, &in1, &in2,
+			&in3, &in4, &in5, &in6, &in7);
+	result = sal_emulator(index, in1, in2, in3,
+					in4, in5, in6, in7);
+	set_sal_result(vcpu, result);
+}

Best Regards,

Akio Takebe

