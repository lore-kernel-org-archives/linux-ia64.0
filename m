From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Fri, 01 Dec 2006 14:12:07 +0000
Subject: Mapping IIP value to Kernel Symbols
Message-Id: <5e0a1fd80612010600q37908483n83de1ddf1d89255f@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi All.

    I have a value of IIP that I recovered from an MCA. I want to
figure out which instruction in the Kernel resulted in the MCA. Please
let me know how I can find this information. I don't have a 'Kernel
Dump'. I am using the kernel that shipped with RHEL Release 4 Update
2. Since I wanted a relocatable kernel, I gunzip'ed the kernel. The
kernel didn't load at the default address.

    I am not familiar with the Kernel Debugging tools on Linux. I will
be grateful if you can provide suitable pointers.

Thanks & Regards,
Karthik
