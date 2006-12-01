From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Fri, 01 Dec 2006 18:38:11 +0000
Subject: RE: Mapping IIP value to Kernel Symbols
Message-Id: <A29F7A5700A7EA4380E08C1F68C3B6D801AF8626@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80612010600q37908483n83de1ddf1d89255f@mail.gmail.com>
In-Reply-To: <5e0a1fd80612010600q37908483n83de1ddf1d89255f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>    I have a value of IIP that I recovered from an MCA. I want to
>figure out which instruction in the Kernel resulted in the MCA. Please
>let me know how I can find this information. 

You can disassemble kernel to find the instruction for the IIP. The
command is "objdump -d kernel_name". You might also find its system.map
(under /boot) useful.

Thanks.

-Fenghua
